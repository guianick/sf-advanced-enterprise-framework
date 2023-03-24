/**
 * @description       : Test class for aef_AccountsSelector
 * @group             : Test Classes
 * @author            : Nick Guia
 * @last modified on  : 22-03-2023
 * @last modified by  : Nick Guia
**/
@IsTest(isParallel=true)
private class aef_AccountsSelector_Test {
    
    /**
     * @description
     *  Test initialising the Account selector with a blank constructor.
     *  The test class should be able to report if this fails for some reason.
     */
    @isTest
    static void shouldInitialiseWithBlankConstructor() {

        // GIVEN
        aef_AccountsSelector selector;

        Test.startTest();

        // WHEN
        try {
            selector = aef_AccountsSelector.newInstance();
        } catch(Exception e) {
            Assert.fail('Unable to initialise aef_AccountsSelector : ' + e.getStackTraceString());
        }

        Test.stopTest();
        
    }

    /**
     * @description
     *  Test query Account records filtered by their IDs.
     */
    @isTest
    static void shouldSelectAccountByIds() {

        // GIVEN
        aef_MockUtility.disableTriggerExecution();
        Integer accountCount = 5;

        // insert accounts
        List<Account> accList = aef_ApplicationTestDataFactory.getAccounts(accountCount, false);
        insert accList;

        List<Account> result = new List<Account>();

        Test.startTest();

        // WHEN
        result = aef_AccountsSelector.newInstance().selectById(new Map<Id, Account>(accList).keySet());

        Test.stopTest();

        // THEN
        Assert.areEqual(accountCount, result.size(), 'Unexpected number of records in result set');
    }

    /**
     * @description
     *  Ensure that the selector class returns Account SObject Type
     */
    @isTest
    static void shouldReturnAccountSObjectType() {

        // GIVEN
        aef_AccountsSelector accSelector = aef_AccountsSelector.newInstance();
        SObjectType accSObjType;

        Test.startTest();

        // WHEN
        accSObjType = accSelector.getSObjectType();

        Test.stopTest();

        // THEN
        Assert.areEqual(Account.SObjectType, accSObjType, 'Unexpected SObjectType returned by the selector');
    }

    /**
     * @description
     *  In this scenario, we nominate an arbitrary field that is typically not included
     *  in the default fields being queried by the selector.
     * 
     * NOTE: This test class will fail in the instance of the arbitrary field being
     *       added in the selector. This is the trade-off of this test. If that happens,
     *       An error is immediately thrown in the GIVEN clause, and you need to change the field.
     */
    @isTest
    static void shouldThrowSObjectExceptionWhenExcludedFieldIsRetrieved() {
        
        // GIVEN
        SObjectField arbitraryField = Account.Tradestyle; // bump this up here for better visibility

        // setup the Selector
        aef_AccountsSelector accSelector = aef_AccountsSelector.newInstance();
        Set<SObjectField> defaultSelectorFields = accSelector.getSObjectFieldList();
        Assert.isTrue(!defaultSelectorFields.contains(arbitraryField), 'Arbitrary field was added to getSObjectFieldList(), you need to pick something else');

        // insert an account
        aef_MockUtility.disableTriggerExecution();

        List<Account> accList = aef_ApplicationTestDataFactory.getAccounts(1, false);
        insert accList;

        List<Account> result = new List<Account>();

        Test.startTest();

        // WHEN
        result = accSelector.selectById(new Map<Id, Account>(accList).keySet());

        Test.stopTest();

        // THEN
        Assert.isTrue(!result.isEmpty(), 'Unable to retrieve Account record');

        try {
            Account resultAcc = result[0];
            String tradeStyle = resultAcc.Tradestyle;
            Assert.fail('Failed to throw an exception while retrieving an unqueried field');
        } catch(SObjectException  e) {
            Assert.isTrue(true);
        } catch(Exception e) {
            Assert.fail('Expecting to throw an SObjectException');
        }
    }
}