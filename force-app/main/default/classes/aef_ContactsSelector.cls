/**
 * @description       : Selector class for Contact object
 * @author            : Nick Guia
 * @group             : Selectors
 * @last modified on  : 22-03-2023
 * @last modified by  : Nick Guia
**/
public virtual inherited sharing class aef_ContactsSelector extends aef_ApplicationSelector {

    public static aef_ContactsSelector newInstance() {
		return (aef_ContactsSelector) aef_Application.Selectors.newInstance(aef_ContactsSelector.class);
	}

    /**
	 * @description get records based on Ids
	 */
	public List<Contact> selectById(Set<Id> ids) {
        aef_QueryBuilder qb = newQueryBuilder()
                                .addConditions()
                                    .add(new aef_QueryBuilder.SimpleCondition(Contact.Id + ' in :ids'))
                                .endConditions();
		return (List<Contact>) Database.query(qb.toSoqlString());
	}

    public override SObjectType getSObjectType() {
		return Contact.SObjectType;
	}

    public virtual override Set<SObjectField> getSObjectFieldList() {
		return new Set<SObjectField> {
			Contact.Id,
            Contact.AccountId,
            Contact.FirstName,
            Contact.LastName,
            Contact.OwnerId,
            Contact.Name,
            Contact.Email,
            Contact.Phone,
            Contact.Fax,
            Contact.MobilePhone,
            Contact.HomePhone,
            Contact.Salutation,
            Contact.Title,
            Contact.Total_Open_Cases__c, 
            Contact.Total_Closed_Cases__c
		};
	}
}