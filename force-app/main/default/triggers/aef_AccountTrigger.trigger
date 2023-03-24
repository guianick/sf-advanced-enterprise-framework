/**
 * @description       : Trigger for Account object
 * @author            : Nick Guia
 * @group             : Triggers
 * @last modified on  : 24-03-2023
 * @last modified by  : Nick Guia
**/
trigger aef_AccountTrigger on Account (after insert) {

	// global mute
	if(!aef_SystemSettings__c.getInstance().DisableTriggers__c) {
		(new aef_AccountTriggerHandler()).dispatch();
	}
}