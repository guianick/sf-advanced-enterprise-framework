/**
 * @description       : Test class for aef_AccountTriggerHandler
 * @group             : Test Classes
 * @author            : Nick Guia
 * @last modified on  : 25-03-2023
 * @last modified by  : Nick Guia
**/
@IsTest(isParallel=true)
private class aef_AccountTriggerHandler_Test {

    /**
     * @description
     *  No logic to test since this is a template
     */
    @IsTest
    static void shouldTestHandler() {

        //GIVEN
        aef_AccountTriggerHandler handler;
        SObjectType handlerSObject;

        Test.startTest();

        // WHEN
        handler = new aef_AccountTriggerHandler();
        handler.newUnitOfWork();
        handler.registerDomains();
        handlerSObject = handler.getSObjectType();

        Test.stopTest();

        // THEN
        Assert.areEqual(Account.SObjectType, handlerSObject, 'Unexpected SObjectType on CaseTriggerHandler');
    }

    /**
     * @description
     *  add test coverage on trigger (no logic).
     *  don't mock to make sure it goes through the trigger
     */
    @isTest
    static void shouldAddTriggerCoverage() {

        // GIVEN
        List<Account> accList = aef_ApplicationTestDataFactory.getAccounts(1, false);

        Test.startTest();

        // WHEN
        insert accList;

        Test.stopTest();

        // THEN
        Assert.isNotNull(accList[0].Id, 'Unable to insert Account record');
    }
}