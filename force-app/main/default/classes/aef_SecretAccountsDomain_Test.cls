/**
 * @description       : Test class for aef_SecretAccountsDomain
 * @group             : Test Classes
 * @author            : Nick Guia
 * @last modified on  : 24-03-2023
 * @last modified by  : Nick Guia
**/
@IsTest(isParallel=true)
private class aef_SecretAccountsDomain_Test {

    /**
     * @description
     *  Test the domain filter. In this scenario, since we don't
     *  have any filter conditions, we expect that all Accounts
     *  will be processed
     */
    @isTest
    static void shouldNotFilterAccounts() {

        // GIVEN

        // create accounts
        List<Account> accounts = aef_ApplicationTestDataFactory.getAccounts(2, true);

        Test.startTest();

        // WHEN
        aef_SecretAccountsDomain domain = aef_SecretAccountsDomain.newInstance(accounts);

        Test.stopTest();

        // THEN
        Assert.areEqual(2, domain.records.size(), 'Unexpected result of domain filter');
        Assert.areEqual(accounts[0].Id, domain.records[0].Id, 'Unexpected exclusion of record');
        Assert.areEqual(accounts[1].Id, domain.records[1].Id, 'Unexpected exclusion of record');
    }
}