/**
 * @description       : Test class for aef_AccountCasesDomain
 * @group             : Test Classes
 * @author            : Nick Guia
 * @last modified on  : 24-03-2023
 * @last modified by  : Nick Guia
**/
@IsTest(isParallel=true)
private class aef_AccountCasesDomain_Test {

    /**
     * @description
     *  Test the domain filter. In this scenario, we filter out 2 Cases,
     *  1 with an associated Account, and 1 without. The filter should exclude
     *  any Cases without an associated Account
     */
    @isTest
    static void shouldFilterCasesWithContacts() {

        // GIVEN

        // create accounts
        List<Account> accounts = aef_ApplicationTestDataFactory.getAccounts(1, true);

        // create cases
        List<Case> cases = aef_ApplicationTestDataFactory.getCases(2, null, true);
        cases[0].AccountId = accounts[0].Id;

        Test.startTest();

        // WHEN
        aef_AccountCasesDomain domain = aef_AccountCasesDomain.newInstance(cases);

        Test.stopTest();

        // THEN
        Assert.areEqual(1, domain.records.size(), 'Unexpected result of domain filter');
        Assert.areEqual(cases[0].Id, domain.records[0].Id, 'Expected to filter Case with Contact');
    }
}