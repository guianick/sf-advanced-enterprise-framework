/**
 * @description       : This is the Case Rollup Module for Cases linked to an Account
 * @author            : Nick Guia
 * @group             : Modules
 * @last modified on  : 24-03-2023
 * @last modified by  : Nick Guia
**/
public inherited sharing class aef_AccountCasesRollupModule extends aef_ApplicationDomain.Module {

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

    public aef_AccountCasesRollupModule() {
		getTriggerEvents().enableAfterInsert().enableAfterUpdate().enableAfterDelete();
	}

    public static aef_AccountCasesRollupModule newInstance() {
		return (aef_AccountCasesRollupModule) aef_Application.Utilities.newInstance(aef_AccountCasesRollupModule.class);
	}
    
	public override void onAfterInsert(List<SObject> records, aef_ApplicationUnitOfWork uow) {
		rollupCaseSummary(records, false, uow);
	}

    public override void onAfterUpdate(List<SObject> records, Map<Id, SObject> existingRecords, aef_ApplicationUnitOfWork uow) {
        rollupCaseSummary((List<Case>) records, (Map<Id, Case>) existingRecords, uow);
    }

    public override void onAfterDelete(List<SObject> records, aef_ApplicationUnitOfWork uow) {
        rollupCaseSummary(records, true, uow);
    }

    /**
    * @description calculate new Case totals of Account on insert or delete. If isDelete is true,
    *   It will decrease the existing total based on the deleted case's status
    *   This method assumes that: 
    *       - ContactId will never be blank given the filter prior this module.
    *       - The logic captures insert or update events on Case Status. It does not include any logic
    *         to capture updates on parent Contact for the sake of simplicity for this challenge. In real scenario,
    *         This event should also be captured (as a rule) to keep the numbers accurate
    * @author Nick Guia | 24-03-2023 
    * @param List<Case> caseList : Trigger.new List
    * @param Boolean isDelete : Option if context is running on after delete
    * @param aef_ApplicationUnitOfWork uow : unit of work
    **/
    @TestVisible
    private void rollupCaseSummary(List<Case> caseList, Boolean isDelete, aef_ApplicationUnitOfWork uow) {

        Map<Id, Account> accountsToUpdate = new Map<Id, Account>();

        /** 
         * STEP 1: 
         * iterate through trigger list and capture change event if it is an update.
         * Figure out the open and closed cases, and collect their summary per parent Contact
         */
        for(Case iCase : caseList) {
            // if this is a delete, subtract. Otherwise, add
            Integer increment = (isDelete) ? -1 : 1;

            // consolidate per parent account
            Account acc = accountsToUpdate.get(iCase.AccountId);
            if(acc == null) {
                acc = initAccountWithBlankTotal(iCase.AccountId);
            }

            if(CASE_STATUS_OPEN.contains(iCase.Status)) {
                acc.Total_Open_Cases__c += increment;
                accountsToUpdate.put(acc.Id, acc);
            } else if(CASE_STATUS_CLOSED.contains(iCase.Status)) {
                acc.Total_Closed_Cases__c += increment;
                accountsToUpdate.put(acc.Id, acc);
            }
        }

        /** 
         * STEP 2:
         * If there are any accounts to update, query their existing values and update
         * with any changes in this event
         */
        if(!accountsToUpdate.isEmpty()) {
            updateAccountsWithNewTotal(accountsToUpdate, uow);
        }
    }

    /**
    * @description calculate new Case totals of Account on update
    *   This method assumes that: 
    *       - AccountId will never be blank given the filter prior this module.
    *       - The logic captures insert or update events on Case Status. It does not include any logic
    *         to capture updates on parent Account for the sake of simplicity for this challenge. In real scenario,
    *         This event should also be captured (as a rule) to keep the numbers accurate
    * @author Nick Guia | 24-03-2023 
    * @param List<Case> newCaseList : Trigger.new List
    * @param Map<Id Case> oldCaseMap : Trigger.oldMap
    * @param aef_ApplicationUnitOfWork uow : unit of work
    **/
    @TestVisible
    private void rollupCaseSummary(List<Case> newCaseList, Map<Id, Case> oldCaseMap, aef_ApplicationUnitOfWork uow) {

        Map<Id, Account> accountsToUpdate = new Map<Id, Account>();

        /** 
         * STEP 1: 
         * iterate through trigger list and capture change event if it is an update.
         * Figure out the open and closed cases, and collect their summary per parent Account
         */
        for(Case iCase : newCaseList) {

            // consolidate per parent account
            Account acc = accountsToUpdate.get(iCase.AccountId);
            if(acc == null) {
                acc = initAccountWithBlankTotal(iCase.AccountId);
            }

            Case oldRecord = oldCaseMap.get(iCase.Id);
            // this is an update - check for field changes
            if(aef_ApplicationDomainUtil.isFieldChanged(iCase, oldRecord, new Set<SObjectField> { Case.Status })) {
                if(CASE_STATUS_OPEN.contains(oldRecord.Status) && CASE_STATUS_CLOSED.contains(iCase.Status)) {
                    // if Case was updated from open to closed
                    acc.Total_Open_Cases__c--;
                    acc.Total_Closed_Cases__c++;
                    accountsToUpdate.put(acc.Id, acc);
                } else if(CASE_STATUS_CLOSED.contains(oldRecord.Status) && CASE_STATUS_OPEN.contains(iCase.Status)) {
                    // if Case was updated from closed to open (somehow)
                    acc.Total_Open_Cases__c++;
                    acc.Total_Closed_Cases__c--;
                    accountsToUpdate.put(acc.Id, acc);
                }
                
            }
        }

        /** 
         * STEP 2:
         * If there are any accounts to update, query their existing values and update
         * with any changes in this event
         */
        if(!accountsToUpdate.isEmpty()) {
            updateAccountsWithNewTotal(accountsToUpdate, uow);
        }
    }

    /**
    * @description updates Account record with new totals based on captured changes
    * @param Map<Id, Account> accountsToUpdate : map of Account records
    * @param aef_ApplicationUnitOfWork uow : Unit of work 
    **/
    @TestVisible
    private void updateAccountsWithNewTotal(Map<Id, Account> accountsToUpdate, aef_ApplicationUnitOfWork uow) {
        List<Account> existingAccounts = aef_AccountsSelector.newInstance()
                                                .selectById(accountsToUpdate.keySet());
        for(Account iAcc : existingAccounts) {
            Account contextAccount = accountsToUpdate.get(iAcc.Id);
            iAcc = updateTotalCases(iAcc, contextAccount);
            uow.registerDirty(iAcc);
        }
    }

    /**
    * @description initialise an Account with blank totals
    * @param Id accountId 
    * @return Account 
    **/
    @TestVisible
    private Account initAccountWithBlankTotal(Id accountId) {
        return new Account(
            Id = accountId,
            Total_Open_Cases__c = 0,
            Total_Closed_Cases__c = 0
        );
    }

    /**
     * @description logic for calculating new totals
     * @param  current : existing Account
     * @param  changes : new instance of an Account that captured the changes in total
     * @return Account with new calculated total. Will default to 0 if ended up as negative
     */
    @TestVisible
    private Account updateTotalCases(Account current, Account changes) {
        current.Total_Open_Cases__c = (current.Total_Open_Cases__c != null) ? current.Total_Open_Cases__c + changes.Total_Open_Cases__c : 0 + changes.Total_Open_Cases__c;
        current.Total_Closed_Cases__c = (current.Total_Closed_Cases__c != null) ? current.Total_Closed_Cases__c + changes.Total_Closed_Cases__c : 0 + changes.Total_Closed_Cases__c;
        return flushNegatives(current);
    }

    /**
     * @description this is an assumptive business rule, but would keep the data clean
     * resets the totals to 0 if it ended up being negative somehow due to bad data
     * @param acc : Account record
     * @return Account : updated Account
     */
    @TestVisible
    private Account flushNegatives(Account acc) {
        if(acc.Total_Open_Cases__c < 0) {
            acc.Total_Open_Cases__c = 0;
        }
        if(acc.Total_Closed_Cases__c < 0) {
            acc.Total_Closed_Cases__c = 0;
        }
        return acc;
    }
}