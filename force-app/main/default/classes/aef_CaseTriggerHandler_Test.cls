/**
 * @description       : Test class for aef_CaseTriggerHandler
 * @group             : Test Classes
 * @author            : Nick Guia
 * @last modified on  : 24-03-2023
 * @last modified by  : Nick Guia
**/
@IsTest(isParallel=true)
public with sharing class aef_CaseTriggerHandler_Test {
    
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
}