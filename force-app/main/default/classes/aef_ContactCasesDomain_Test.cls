/**
 * @description       : Test class for aef_ContactCasesDomain
 * @group             : Test Classes
 * @author            : Nick Guia
 * @last modified on  : 24-03-2023
 * @last modified by  : Nick Guia
**/
@IsTest(isParallel=true)
private class aef_ContactCasesDomain_Test {

    /**
     * @description
     *  Test the domain filter. In this scenario, we filter out 2 Cases,
     *  1 with an associated Contact, and 1 without. The filter should exclude
     *  any Cases without an associated Contact
     */
    @isTest
    static void shouldFilterCasesWithContacts() {

        // GIVEN

        // create contacts
        List<Contact> contacts = aef_ApplicationTestDataFactory.getContacts(1, null, true);

        // create cases
        List<Case> cases = aef_ApplicationTestDataFactory.getCases(2, null, true);
        cases[0].ContactId = contacts[0].Id;

        Test.startTest();

        // WHEN
        aef_ContactCasesDomain domain = aef_ContactCasesDomain.newInstance(cases);

        Test.stopTest();

        // THEN
        Assert.areEqual(1, domain.records.size(), 'Unexpected result of domain filter');
        Assert.areEqual(cases[0].Id, domain.records[0].Id, 'Expected to filter Case with Contact');
    }
}