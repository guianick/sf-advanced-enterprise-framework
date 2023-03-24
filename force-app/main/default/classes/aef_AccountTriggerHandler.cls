/**
 * @description       : Trigger Handler class for Account object
 * @author            : Nick Guia
 * @group             : Trigger Handlers
 * @last modified on  : 24-03-2023
 * @last modified by  : Nick Guia
**/
public inherited sharing class aef_AccountTriggerHandler extends aef_ApplicationDomainTriggerHandler {

    // this trigger handler's sobject type
    public override SObjectType getSObjectType() {
        return Account.SObjectType;
    }

    // inject domains
    public override List<Type> registerDomains() {
        return new List<Type>{
            aef_SecretAccountsDomain.class
        };
    }

    // initialise a UOW
    public override aef_ApplicationUnitOfWork newUnitOfWork() {
        return aef_ApplicationUnitOfWork.newInstance(getUnitOfWorkSObjectTypes());
    }

    // inject UOW Sobjects; update this as required
    public static List<SObjectType> getUnitOfWorkSObjectTypes() {
		return new List<SObjectType>{
            Account.SObjectType
		};
	}
}