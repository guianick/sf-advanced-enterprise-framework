/**
 * @description       : Selector class for Account object
 * @author            : Nick Guia
 * @group             : Selectors
 * @last modified on  : 24-03-2023
 * @last modified by  : Nick Guia
**/
public virtual inherited sharing class aef_AccountsSelector extends aef_ApplicationSelector {
    
    public static aef_AccountsSelector newInstance() {
        return (aef_AccountsSelector) aef_Application.Selectors.newInstance(aef_AccountsSelector.class);
    }

    /**
     * @description get records based on Ids
     */
    public List<Account> selectById(Set<Id> ids) {
        aef_QueryBuilder qb = newQueryBuilder().addConditions()
                                .add(new aef_QueryBuilder.SimpleCondition(Account.Id + ' in :ids'))
                            .endConditions();
        return (List<Account>) Database.query(qb.toSoqlString());
    }

    public override SObjectType getSObjectType() {
        return Account.SObjectType;
    }

    public virtual override Set<SObjectField> getSObjectFieldList() {
		return new Set<SObjectField> {
            Account.Id, 
            Account.Name, 
            Account.Type, 
            Account.OwnerId,
            Account.BillingStreet, 
            Account.BillingCity, 
            Account.BillingState,
            Account.BillingPostalCode, 
            Account.Phone, 
            Account.BillingCountry,
            Account.ShippingStreet, 
            Account.ShippingCity, 
            Account.ShippingState,
            Account.ShippingPostalCode, 
            Account.ShippingCountry, 
            Account.AccountNumber,
            Account.Total_Open_Cases__c,
            Account.Total_Closed_Cases__c
		};
	}
}