/**
 * @description       : Hypothetical Domain for all Accounts that will receive a Secret Key on creation.
 *                      In real scenario, this could be defined by a business rule
 * @author            : Nick Guia
 * @last modified on  : 24-03-2023
 * @last modified by  : Nick Guia
**/
public inherited sharing class aef_SecretAccountsDomain extends aef_ApplicationDomain {

    // initialise instance
    public static aef_SecretAccountsDomain newInstance(List<SObject> sObjectList) {
		return (aef_SecretAccountsDomain) aef_ApplicationDomain.newInstance(aef_SecretAccountsDomain.class, sObjectList);
	}

    public override void registerModules() {
        registerModule(aef_AccountURLCalloutModule.class);
	}

    /**
     * Filter criteria:
     *  -   no criteria since there are no rules
     */
    // public override List<SObject> filter(List<SObject> records) {
        
    // }
}