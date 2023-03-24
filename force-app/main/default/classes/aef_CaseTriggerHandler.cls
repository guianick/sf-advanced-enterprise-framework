/**
 * @description       : Trigger Handler class for Case object
 * @author            : Nick Guia
 * @group             : Trigger Handlers
 * @last modified on  : 22-03-2023
 * @last modified by  : Nick Guia
**/
public inherited sharing class aef_CaseTriggerHandler extends aef_ApplicationDomainTriggerHandler {

    // this trigger handler's sobject type
    public override SObjectType getSObjectType() {
        return Case.SObjectType;
    }

    // inject domains
    public override List<Type> registerDomains() {
        return new List<Type>{
            aef_AccountCasesDomain.class,
            aef_ContactCasesDomain.class
        };
    }

    // initialise a UOW
    public override aef_ApplicationUnitOfWork newUnitOfWork() {
        return aef_ApplicationUnitOfWork.newInstance(getUnitOfWorkSObjectTypes());
    }

    // inject UOW Sobjects; update this as required
    public static List<SObjectType> getUnitOfWorkSObjectTypes() {
		return new List<SObjectType>{
            Account.SObjectType,
            Contact.SObjectType,
			Case.SObjectType
		};
	}
}