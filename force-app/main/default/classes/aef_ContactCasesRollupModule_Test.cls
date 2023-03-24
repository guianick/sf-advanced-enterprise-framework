/**
 * @description       : Test class for aef_ContactCasesRollupModule
 * @group             : Test Classes
 * @author            : Nick Guia
 * @last modified on  : 24-03-2023
 * @last modified by  : Nick Guia
**/
@IsTest(isParallel=true)
private class aef_ContactCasesRollupModule_Test {

    /**
     * @description
     *  Test scenario of rolling up Case summary on parent Contact after they are inserted.
     *  This will also cater for inserting Closed cases to ensure we keep data integrity during
     *  data migration i.e. migrating Closed clases into the system
     */
    @isTest
    static void shouldRollupCaseSummaryOnInsert() {

        // GIVEN

        // create contacts
        List<Contact> contacts = aef_ApplicationTestDataFactory.getContacts(1, null, true);
        contacts[0].Total_Open_Cases__c = 0;
        contacts[0].Total_Closed_Cases__c = 0;

        // create cases
        List<Case> cases = aef_ApplicationTestDataFactory.getCases(2, null, false);
        cases[0].ContactId = contacts[0].Id;
        cases[0].Status = 'New';

        cases[1].ContactId = contacts[0].Id;
        cases[1].Status = 'Closed';

        // expected outcome
        List<Contact> contactsWithTotal = new List<Contact> { contacts[0].clone(true) };
        contactsWithTotal[0].Total_Open_Cases__c = 1;
        contactsWithTotal[0].Total_Closed_Cases__c = 1;

        // stubbing - start
        aef_ApplicationUnitOfWork mockUow = (aef_ApplicationUnitOfWork) aef_MockUtility.mockUtility(aef_ApplicationUnitOfWork.class);
        aef_ContactsSelector mockContactsSelector = (aef_ContactsSelector) aef_MockUtility.mockSelector(aef_ContactsSelector.class);

        aef_MockUtility.Mocks.startStubbing();

        // catch contact update
        aef_MockUtility.Mocks
            .when(mockUOW.registerDirty((Contact) fflib_Match.anySObject()))
            .thenAnswer(new aef_MockUtility.AnswerGenericRegisterUnitOfWorkDML());

        // catch contact query
        aef_MockUtility.Mocks
            .when(mockContactsSelector.selectById((Set<Id>) fflib_Match.anyObject()))
            .thenReturn(contacts);

        aef_MockUtility.Mocks.stopStubbing();
        // stubbing - end

        Test.startTest();

        // WHEN
        aef_ContactCasesRollupModule conModule = aef_ContactCasesRollupModule.newInstance();
        conModule.onAfterInsert(cases, mockUOW);

        Test.stopTest();

        // THEN

        // capture arguments
        fflib_ArgumentCaptor contactUpdateCapture = fflib_ArgumentCaptor.forClass(List<Contact>.class);

        // verify the number of times the update ran
        ((aef_ApplicationUnitOfWork) aef_MockUtility.Mocks.verify(mockUOW, aef_MockUtility.Mocks.times(1)))
            .registerDirty((Contact) contactUpdateCapture.capture());

        // verify number of contacts that were updated
		List<Object> contactUpdateList = (List<Object>) contactUpdateCapture.getAllValues();
        Contact contactWithTotal = contactsWithTotal[0];
        Contact contactUpdate = (Contact) contactUpdateList[0];
		System.assertEquals(1, contactUpdateList.size(), 'Unexpected number of Contacts updated');

        // verify that Contact total cases were updated correctly
        Assert.areEqual(contactWithTotal.Id, contactUpdate.Id, 'Unexpected Contact record captured');
        Assert.areEqual(contactWithTotal.Total_Open_Cases__c, contactUpdate.Total_Open_Cases__c, 'Unexpected number of calculated Open Cases');
        Assert.areEqual(contactWithTotal.Total_Closed_Cases__c, contactUpdate.Total_Closed_Cases__c, 'Unexpected number of calculated Closed Cases');
    }

    /**
     * @description
     * In this scenario, we test an update on Case statuses.
     * The parent Contact would have two Cases, 1 open, and 1 Closed.
     * The scenario will Close the open Case, and will Re-open the closed one.
     * The expected outcome is that the number of open and closed cases = 1 each
     */
    @isTest
    static void shouldRollupCaseSummaryOnStatusUpdate() {

        // create contact
        List<Contact> contacts = aef_ApplicationTestDataFactory.getContacts(1, null, true);
        contacts[0].Total_Open_Cases__c = 1;
        contacts[0].Total_Closed_Cases__c = 1;

        // setup an "update case status" scenario
        List<Case> oldCases = aef_ApplicationTestDataFactory.getCases(2, null, true);

        // old state
        Case caseToBeClosed = oldCases[0];
        caseToBeClosed.ContactId = contacts[0].Id;
        caseToBeClosed.Status = 'New';

        Case caseToBeReopened = oldCases[1];
        caseToBeReopened.ContactId = contacts[0].Id;
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
        List<Contact> contactsWithNewTotal = new List<Contact> { contacts[0].clone(true) };
        contactsWithNewTotal[0].Total_Open_Cases__c = 1;
        contactsWithNewTotal[0].Total_Closed_Cases__c = 1;

        // stubbing - start
        aef_ApplicationUnitOfWork mockUow = (aef_ApplicationUnitOfWork) aef_MockUtility.mockUtility(aef_ApplicationUnitOfWork.class);
        aef_ContactsSelector mockContactsSelector = (aef_ContactsSelector) aef_MockUtility.mockSelector(aef_ContactsSelector.class);

        aef_MockUtility.Mocks.startStubbing();

        // catch contact update
        aef_MockUtility.Mocks
            .when(mockUOW.registerDirty((Contact) fflib_Match.anySObject()))
            .thenAnswer(new aef_MockUtility.AnswerGenericRegisterUnitOfWorkDML());

        // catch contact query
        aef_MockUtility.Mocks
            .when(mockContactsSelector.selectById((Set<Id>) fflib_Match.anyObject()))
            .thenReturn(contacts);

        aef_MockUtility.Mocks.stopStubbing();
        // stubbing - end

        Test.startTest();

        // WHEN
        aef_ContactCasesRollupModule conModule = aef_ContactCasesRollupModule.newInstance();
        conModule.onAfterUpdate(newCases, new Map<Id, Case>(oldCases), mockUOW);

        Test.stopTest();

        // THEN

        // capture arguments
        fflib_ArgumentCaptor contactUpdateCapture = fflib_ArgumentCaptor.forClass(List<Contact>.class);

        // verify the number of times the update ran
        ((aef_ApplicationUnitOfWork) aef_MockUtility.Mocks.verify(mockUOW, aef_MockUtility.Mocks.times(1)))
            .registerDirty((Contact) contactUpdateCapture.capture());

        // verify number of contacts that were updated
		List<Object> contactUpdateList = (List<Object>) contactUpdateCapture.getAllValues();
        Contact contactWithNewTotal = contactsWithNewTotal[0];
        Contact contactUpdate = (Contact) contactUpdateList[0];
		System.assertEquals(1, contactUpdateList.size(), 'Unexpected number of Contacts updated');

        // verify that Contact total cases were updated correctly
        Assert.areEqual(contactWithNewTotal.Id, contactUpdate.Id, 'Unexpected Contact record captured');
        Assert.areEqual(contactWithNewTotal.Total_Open_Cases__c, contactUpdate.Total_Open_Cases__c, 'Unexpected number of calculated Open Cases');
        Assert.areEqual(contactWithNewTotal.Total_Closed_Cases__c, contactUpdate.Total_Closed_Cases__c, 'Unexpected number of calculated Closed Cases');
    }

    /**
     * @description
     * This test ensures that the business logic does not blindly execute on
     * irrelevant field updates on Contact
     */
    @isTest
    static void shouldNotRollupCaseSummaryIfStatusIsUnchanged() {

        // create contact
        List<Contact> contacts = aef_ApplicationTestDataFactory.getContacts(1, null, true);
        contacts[0].Total_Open_Cases__c = 1;
        contacts[0].Total_Closed_Cases__c = 1;

        // setup an "update case status" scenario
        List<Case> oldCases = aef_ApplicationTestDataFactory.getCases(1, null, true);

        // old state
        oldCases[0].ContactId = contacts[0].Id;
        oldCases[0].Status = 'New';

        // new state (no updates)
        List<Case> newCases = new List<Case> { oldCases[0].clone(true) };

        // stubbing - start
        aef_ApplicationUnitOfWork mockUow = (aef_ApplicationUnitOfWork) aef_MockUtility.mockUtility(aef_ApplicationUnitOfWork.class);
        aef_ContactsSelector mockContactsSelector = (aef_ContactsSelector) aef_MockUtility.mockSelector(aef_ContactsSelector.class);

        aef_MockUtility.Mocks.startStubbing();

        // catch contact update
        aef_MockUtility.Mocks
            .when(mockUOW.registerDirty((Contact) fflib_Match.anySObject()))
            .thenAnswer(new aef_MockUtility.AnswerGenericRegisterUnitOfWorkDML());

        // catch contact query
        aef_MockUtility.Mocks
            .when(mockContactsSelector.selectById((Set<Id>) fflib_Match.anyObject()))
            .thenReturn(contacts);

        aef_MockUtility.Mocks.stopStubbing();
        // stubbing - end

        Test.startTest();

        // WHEN
        aef_ContactCasesRollupModule conModule = aef_ContactCasesRollupModule.newInstance();
        conModule.onAfterUpdate(newCases, new Map<Id, Case>(oldCases), mockUOW);

        Test.stopTest();

        // THEN

        // capture arguments
        fflib_ArgumentCaptor contactUpdateCapture = fflib_ArgumentCaptor.forClass(List<Contact>.class);

        // verify that no updates happened
        ((aef_ApplicationUnitOfWork) aef_MockUtility.Mocks.verify(mockUOW, aef_MockUtility.Mocks.times(0)))
            .registerDirty((Contact) contactUpdateCapture.capture());

    }
}