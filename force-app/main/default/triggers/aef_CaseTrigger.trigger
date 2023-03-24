/**
 * @description       : Trigger for Case object
 * @author            : Nick Guia
 * @group             : Triggers
 * @last modified on  : 24-03-2023
 * @last modified by  : Nick Guia
**/
trigger aef_CaseTrigger on Case (after insert, after update, after delete) {

	// global mute
	if(!aef_SystemSettings__c.getInstance().DisableTriggers__c) {
		(new aef_CaseTriggerHandler()).dispatch();
	}
}