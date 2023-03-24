/**
 * @description       : Domain class for all Cases linked to an Account
 *
 * - In real-life scenario, these domain classes serve better by having one for each business / support process.
 * - For the sake of this challenge, The code assumes that there are no business rules around mandatory fields for either 
 *      Account or Contact, though arguably Contact should exist at minimum.
 * - This model simply illustrates a basic example on how we can separate the concerns for each Account and Contact linked to the Case
 *
 * @author            : Nick Guia
 * @group             : Domains
 * @last modified on  : 24-03-2023
 * @last modified by  : Nick Guia
**/
public inherited sharing class aef_AccountCasesDomain extends aef_ApplicationDomain {

    // initialise instance
    public static aef_AccountCasesDomain newInstance(List<SObject> sObjectList) {
        return (aef_AccountCasesDomain) aef_ApplicationDomain.newInstance(aef_AccountCasesDomain.class, sObjectList);
    }

    public override void registerModules() {
        registerModule(aef_AccountCasesRollupModule.class);
    }

    /**
     * Domain-specific Filter criteria:
     *  -   Account is not null
     *  -   < ADD AS REQUIRED >
     */
    public override List<SObject> filter(List<SObject> records) {
        List<Case> input = (List<Case>) records;
        List<Case> output = new List<Case>();

        for(Case iCase : input) {
            if(iCase.AccountId != null) {
                output.add(iCase);
            }
        }

        return output;
    }
}