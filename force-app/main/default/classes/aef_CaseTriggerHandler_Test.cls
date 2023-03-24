/**
 * @description       : Test class for aef_CaseTriggerHandler
 * @group             : Test Classes
 * @author            : Nick Guia
 * @last modified on  : 25-03-2023
 * @last modified by  : Nick Guia
**/
@IsTest(isParallel=true)
private class aef_CaseTriggerHandler_Test {
    
    /**
     * @description
     *  No logic to test since this is a template
     */
    @IsTest
    static void shouldTestHandler() {

        //GIVEN
        aef_CaseTriggerHandler handler;
        SObjectType handlerSObject;

        Test.startTest();

        // WHEN
        handler = new aef_CaseTriggerHandler();
        handler.newUnitOfWork();
        handler.registerDomains();
        handlerSObject = handler.getSObjectType();

        Test.stopTest();

        // THEN
        Assert.areEqual(Case.SObjectType, handlerSObject, 'Unexpected SObjectType on CaseTriggerHandler');
    }

    /**
     * @description
     *  add test coverage on trigger (no logic).
     *  don't mock to make sure it goes through the trigger
     */
    @isTest
    static void shouldAddTriggerCoverage() {

        // GIVEN
        List<Case> caseList = aef_ApplicationTestDataFactory.getCases(1, null, false);

        Test.startTest();

        // WHEN
        insert caseList;

        Test.stopTest();

        // THEN
        Assert.isNotNull(caseList[0].Id, 'Unable to insert Case record');
    }
}