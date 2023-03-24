/**
 * @description       : This is the Case Rollup Module for Cases linked to a Contact
 * @author            : Nick Guia
 * @group             : Modules
 * @last modified on  : 24-03-2023
 * @last modified by  : Nick Guia
**/
public inherited sharing class aef_ContactCasesRollupModule extends aef_ApplicationDomain.Module {

    /** 
     * this can further be improved by centralising the definition of Open and Closed Status
     * somewhere else (like a static list, or custom metadata). This way you'll have a standard
     * definition across all domains
     */
    private static final Set<String> CASE_STATUS_OPEN = new Set<String> { 
        'New', 
        'Working', 
        'Escalated' 
    };
    private static final Set<String> CASE_STATUS_CLOSED = new Set<String> { 
        'Closed'
    };

    public aef_ContactCasesRollupModule() {
		getTriggerEvents().enableAfterInsert().enableAfterUpdate();
	}

    public static aef_ContactCasesRollupModule newInstance() {
		return (aef_ContactCasesRollupModule) aef_Application.Utilities.newInstance(aef_ContactCasesRollupModule.class);
	}
    
	public override void onAfterInsert(List<SObject> records, aef_ApplicationUnitOfWork uow) {
		rollupCaseSummary(records, null, uow);
	}

    public override void onAfterUpdate(List<SObject> records, Map<Id, SObject> existingRecords, aef_ApplicationUnitOfWork uow) {
        rollupCaseSummary((List<Case>) records, (Map<Id, Case>) existingRecords, uow);
    }

    /**
    * @description
    *   This method assumes that: 
    *       - ContactId will never be blank given the filter prior this module.
    *       - The logic captures insert or update events on Case Status. It does not include any logic
    *         to capture updates on parent Contact for the sake of simplicity for this challenge. In real scenario,
    *         This event should also be captured (as a rule) to keep the numbers accurate
    * @author Nick Guia | 24-03-2023 
    * @param List<Case> newCaseList : Trigger.new List
    * @param Map<Id Case> oldCaseMap : Trigger.oldMap
    * @param aef_ApplicationUnitOfWork uow : unit of work
    **/
    @TestVisible
    private void rollupCaseSummary(List<Case> newCaseList, Map<Id, Case> oldCaseMap, aef_ApplicationUnitOfWork uow) {

        Map<Id, Contact> contactsToUpdate = new Map<Id, Contact>();

        /** 
         * STEP 1: 
         * iterate through trigger list and capture change event if it is an update.
         * Figure out the open and closed cases, and collect their summary per parent Contact
         */
        for(Case iCase : newCaseList) {

            // consolidate per parent contact
            Contact con = contactsToUpdate.get(iCase.ContactId);
            if(con == null) {
                con = new Contact(
                    Id = iCase.ContactId,
                    Total_Open_Cases__c = 0,
                    Total_Closed_Cases__c = 0
                );
            }

            // check if this is an update
            if(oldCaseMap != null) {
                Case oldRecord = oldCaseMap.get(iCase.Id);
                // this is an update - check for field changes
                if(aef_ApplicationDomainUtil.isFieldChanged(iCase, oldRecord, new Set<SObjectField> { Case.Status })) {
                    if(CASE_STATUS_OPEN.contains(oldRecord.Status) && CASE_STATUS_CLOSED.contains(iCase.Status)) {
                        // if Case was updated from open to closed
                        con.Total_Open_Cases__c--;
                        con.Total_Closed_Cases__c++;
                    } else if(CASE_STATUS_CLOSED.contains(oldRecord.Status) && CASE_STATUS_OPEN.contains(iCase.Status)) {
                        // if Case was updated from closed to open (somehow)
                        con.Total_Open_Cases__c++;
                        con.Total_Closed_Cases__c--;
                    }
                    contactsToUpdate.put(con.Id, con);
                }
            } else {
                // this is an insert - simply count
                if(CASE_STATUS_OPEN.contains(iCase.Status)) {
                    con.Total_Open_Cases__c++;
                } else if(CASE_STATUS_CLOSED.contains(iCase.Status)) {
                    con.Total_Closed_Cases__c++;
                }
                contactsToUpdate.put(con.Id, con);
            }
        }

        /** 
         * STEP 2:
         * If there are any contacts to update, query their existing values and update
         * with any changes in this event
         */
        if(!contactsToUpdate.isEmpty()) {
            List<Contact> existingContacts = aef_ContactsSelector.newInstance()
                                                .selectById(contactsToUpdate.keySet());
            for(Contact iCon : existingContacts) {
                Contact contextContact = contactsToUpdate.get(iCon.Id);
                iCon.Total_Open_Cases__c += contextContact.Total_Open_Cases__c;
                iCon.Total_Closed_Cases__c += contextContact.Total_Closed_Cases__c;
                uow.registerDirty(iCon);
            }
        }
    }
}