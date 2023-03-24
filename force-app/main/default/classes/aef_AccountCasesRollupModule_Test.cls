/**
 * @description       : Test class for aef_AccountCasesRollupModule
 * @group             : Test Classes
 * @author            : Nick Guia
 * @last modified on  : 24-03-2023
 * @last modified by  : Nick Guia
**/
@IsTest(isParallel=true)
private class aef_AccountCasesRollupModule_Test {

    /**
     * @description
     *  Test scenario of rolling up Case summary on parent Account after they are inserted.
     *  This will also cater for inserting Closed cases to ensure we keep data integrity during
     *  data migration i.e. migrating Closed clases into the system
     */
    @isTest
    static void shouldRollupCaseSummaryOnInsert() {

        // GIVEN

        // create accounts
        List<Account> accounts = aef_ApplicationTestDataFactory.getAccounts(1, true);
        accounts[0].Total_Open_Cases__c = 0;
        accounts[0].Total_Closed_Cases__c = 0;

        // create cases
        List<Case> cases = aef_ApplicationTestDataFactory.getCases(2, null, false);
        cases[0].AccountId = accounts[0].Id;
        cases[0].Status = 'New';

        cases[1].AccountId = accounts[0].Id;
        cases[1].Status = 'Closed';

        // expected outcome
        List<Account> accountsWithTotal = new List<Account> { accounts[0].clone(true) };
        accountsWithTotal[0].Total_Open_Cases__c = 1;
        accountsWithTotal[0].Total_Closed_Cases__c = 1;

        // stubbing - start
        aef_ApplicationUnitOfWork mockUow = (aef_ApplicationUnitOfWork) aef_MockUtility.mockUtility(aef_ApplicationUnitOfWork.class);
        aef_AccountsSelector mockAccountsSelector = (aef_AccountsSelector) aef_MockUtility.mockSelector(aef_AccountsSelector.class);

        aef_MockUtility.Mocks.startStubbing();

        // catch account update
        aef_MockUtility.Mocks
            .when(mockUOW.registerDirty((Account) fflib_Match.anySObject()))
            .thenAnswer(new aef_MockUtility.AnswerGenericRegisterUnitOfWorkDML());

        // catch account query
        aef_MockUtility.Mocks
            .when(mockAccountsSelector.selectById((Set<Id>) fflib_Match.anyObject()))
            .thenReturn(accounts);

        aef_MockUtility.Mocks.stopStubbing();
        // stubbing - end

        Test.startTest();

        // WHEN
        aef_AccountCasesRollupModule acModule = aef_AccountCasesRollupModule.newInstance();
        acModule.onAfterInsert(cases, mockUOW);

        Test.stopTest();

        // THEN

        // capture arguments
        fflib_ArgumentCaptor accountUpdateCapture = fflib_ArgumentCaptor.forClass(List<Account>.class);

        // verify the number of times the update ran
        ((aef_ApplicationUnitOfWork) aef_MockUtility.Mocks.verify(mockUOW, aef_MockUtility.Mocks.times(1)))
            .registerDirty((Account) accountUpdateCapture.capture());

        // verify number of accounts that were updated
		List<Object> accountUpdateList = (List<Object>) accountUpdateCapture.getAllValues();
        Account accountWithTotal = accountsWithTotal[0];
        Account accountUpdate = (Account) accountUpdateList[0];
		System.assertEquals(1, accountUpdateList.size(), 'Unexpected number of Accounts updated');

        // verify that Account total cases were updated correctly
        Assert.areEqual(accountWithTotal.Id, accountUpdate.Id, 'Unexpected Account record captured');
        Assert.areEqual(accountWithTotal.Total_Open_Cases__c, accountUpdate.Total_Open_Cases__c, 'Unexpected number of calculated Open Cases');
        Assert.areEqual(accountWithTotal.Total_Closed_Cases__c, accountUpdate.Total_Closed_Cases__c, 'Unexpected number of calculated Closed Cases');
    }

    /**
     * @description
     * In this scenario, we test an update on Case statuses.
     * The parent account would have two Cases, 1 open, and 1 Closed.
     * The scenario will Close the open Case, and will Re-open the closed one.
     * The expected outcome is that the number of open and closed cases = 1 each
     */
    @isTest
    static void shouldRollupCaseSummaryOnStatusUpdate() {

        // create accounts
        List<Account> accounts = aef_ApplicationTestDataFactory.getAccounts(1, true);
        accounts[0].Total_Open_Cases__c = 1;
        accounts[0].Total_Closed_Cases__c = 1;

        // setup an "update case status" scenario
        List<Case> oldCases = aef_ApplicationTestDataFactory.getCases(2, null, true);

        // old state
        Case caseToBeClosed = oldCases[0];
        caseToBeClosed.AccountId = accounts[0].Id;
        caseToBeClosed.Status = 'New';

        Case caseToBeReopened = oldCases[1];
        caseToBeReopened.AccountId = accounts[0].Id;
        caseToBeReopened.Status = 'Closed';

        // new state
        List<Case> newCases = new List<Case>();

        Case caseClosed = caseToBeClosed.clone(true);
        caseClosed.Status = 'Closed';
        newCases.add(caseClosed);

        Case caseReopened = caseToBeReopened.clone(true);
        caseReopened.Status = 'New';
        newCases.add(caseReopened);
    

        // expected outcome (same as setup, but keeping it here incase we decide to change the scenario)
        List<Account> accountsWithNewTotal = new List<Account> { accounts[0].clone(true) };
        accountsWithNewTotal[0].Total_Open_Cases__c = 1;
        accountsWithNewTotal[0].Total_Closed_Cases__c = 1;

        // stubbing - start
        aef_ApplicationUnitOfWork mockUow = (aef_ApplicationUnitOfWork) aef_MockUtility.mockUtility(aef_ApplicationUnitOfWork.class);
        aef_AccountsSelector mockAccountsSelector = (aef_AccountsSelector) aef_MockUtility.mockSelector(aef_AccountsSelector.class);

        aef_MockUtility.Mocks.startStubbing();

        // catch account update
        aef_MockUtility.Mocks
            .when(mockUOW.registerDirty((Account) fflib_Match.anySObject()))
            .thenAnswer(new aef_MockUtility.AnswerGenericRegisterUnitOfWorkDML());

        // catch account query
        aef_MockUtility.Mocks
            .when(mockAccountsSelector.selectById((Set<Id>) fflib_Match.anyObject()))
            .thenReturn(accounts);

        aef_MockUtility.Mocks.stopStubbing();
        // stubbing - end

        Test.startTest();

        // WHEN
        aef_AccountCasesRollupModule acModule = aef_AccountCasesRollupModule.newInstance();
        acModule.onAfterUpdate(newCases, new Map<Id, Case>(oldCases), mockUOW);

        Test.stopTest();

        // THEN

        // capture arguments
        fflib_ArgumentCaptor accountUpdateCapture = fflib_ArgumentCaptor.forClass(List<Account>.class);

        // verify the number of times the update ran
        ((aef_ApplicationUnitOfWork) aef_MockUtility.Mocks.verify(mockUOW, aef_MockUtility.Mocks.times(1)))
            .registerDirty((Account) accountUpdateCapture.capture());

        // verify number of accounts that were updated
		List<Object> accountUpdateList = (List<Object>) accountUpdateCapture.getAllValues();
        Account accountWithNewTotal = accountsWithNewTotal[0];
        Account accountUpdate = (Account) accountUpdateList[0];
		System.assertEquals(1, accountUpdateList.size(), 'Unexpected number of Accounts updated');

        // verify that Account total cases were updated correctly
        Assert.areEqual(accountWithNewTotal.Id, accountUpdate.Id, 'Unexpected Account record captured');
        Assert.areEqual(accountWithNewTotal.Total_Open_Cases__c, accountUpdate.Total_Open_Cases__c, 'Unexpected number of calculated Open Cases');
        Assert.areEqual(accountWithNewTotal.Total_Closed_Cases__c, accountUpdate.Total_Closed_Cases__c, 'Unexpected number of calculated Closed Cases');
    }

    /**
     * @description
     * This test ensures that the business logic does not blindly execute on
     * irrelevant field updates on Account
     */
    @isTest
    static void shouldNotRollupCaseSummaryIfStatusIsUnchanged() {

        // create accounts
        List<Account> accounts = aef_ApplicationTestDataFactory.getAccounts(1, true);
        accounts[0].Total_Open_Cases__c = 1;
        accounts[0].Total_Closed_Cases__c = 1;

        // setup an "update case status" scenario
        List<Case> oldCases = aef_ApplicationTestDataFactory.getCases(1, null, true);

        // old state
        oldCases[0].AccountId = accounts[0].Id;
        oldCases[0].Status = 'New';

        // new state (no updates)
        List<Case> newCases = new List<Case> { oldCases[0].clone(true) };

        // stubbing - start
        aef_ApplicationUnitOfWork mockUow = (aef_ApplicationUnitOfWork) aef_MockUtility.mockUtility(aef_ApplicationUnitOfWork.class);
        aef_AccountsSelector mockAccountsSelector = (aef_AccountsSelector) aef_MockUtility.mockSelector(aef_AccountsSelector.class);

        aef_MockUtility.Mocks.startStubbing();

        // catch account update
        aef_MockUtility.Mocks
            .when(mockUOW.registerDirty((Account) fflib_Match.anySObject()))
            .thenAnswer(new aef_MockUtility.AnswerGenericRegisterUnitOfWorkDML());

        // catch account query
        aef_MockUtility.Mocks
            .when(mockAccountsSelector.selectById((Set<Id>) fflib_Match.anyObject()))
            .thenReturn(accounts);

        aef_MockUtility.Mocks.stopStubbing();
        // stubbing - end

        Test.startTest();

        // WHEN
        aef_AccountCasesRollupModule acModule = aef_AccountCasesRollupModule.newInstance();
        acModule.onAfterUpdate(newCases, new Map<Id, Case>(oldCases), mockUOW);

        Test.stopTest();

        // THEN

        // capture arguments
        fflib_ArgumentCaptor accountUpdateCapture = fflib_ArgumentCaptor.forClass(List<Account>.class);

        // verify that no updates happened
        ((aef_ApplicationUnitOfWork) aef_MockUtility.Mocks.verify(mockUOW, aef_MockUtility.Mocks.times(0)))
            .registerDirty((Account) accountUpdateCapture.capture());

    }
}