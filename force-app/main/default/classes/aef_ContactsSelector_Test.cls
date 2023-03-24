/**
 * @description       : Test class for aef_ContactsSelector
 * @group             : Test Classes
 * @author            : Nick Guia
 * @last modified on  : 22-03-2023
 * @last modified by  : Nick Guia
**/
@IsTest(isParallel=true)
private class aef_ContactsSelector_Test {
    
    /**
     * @description
     *  Test initialising the Contact selector with a blank constructor.
     *  The test class should be able to report if this fails for some reason.
     */
    @isTest
    static void shouldInitialiseWithBlankConstructor() {

        // GIVEN
        aef_ContactsSelector conSelector;

        Test.startTest();

        // WHEN
        try {
            conSelector = aef_ContactsSelector.newInstance();
        } catch(Exception e) {
            Assert.fail('Unable to initialise aef_ContactsSelector : ' + e.getStackTraceString());
        }

        Test.stopTest();
        
    }

    /**
     * @description
     *  Test query contact records filtered by their IDs.
     */
    @isTest
    static void shouldSelectContactByIds() {

        // GIVEN
        aef_MockUtility.disableTriggerExecution();
        Integer contactCount = 5;

        // insert contacts
        List<Contact> conList = aef_ApplicationTestDataFactory.getContacts(contactCount, null, false);
        insert conList;

        List<Contact> result = new List<Contact>();

        Test.startTest();

        // WHEN
        result = aef_ContactsSelector.newInstance().selectById(new Map<Id, Contact>(conList).keySet());

        Test.stopTest();

        // THEN
        Assert.areEqual(contactCount, result.size(), 'Unexpected number of records in result set');
    }

    /**
     * @description
     *  Ensure that the selector class returns Contact SObject Type
     */
    @isTest
    static void shouldReturnContactSObjectType() {

        // GIVEN
        aef_ContactsSelector conSelector = aef_ContactsSelector.newInstance();
        SObjectType conSObjType;

        Test.startTest();

        // WHEN
        conSObjType = conSelector.getSObjectType();

        Test.stopTest();

        // THEN
        Assert.areEqual(Contact.SObjectType, conSObjType, 'Unexpected SObjectType returned by the selector');
    }

    /**
     * @description
     *  In this scenario, we nominate an arbitrary field that is typically not included
     *  in the default fields being queried by the selector.
     * 
     * NOTE: This test class will fail in the instance of the arbitrary field being
     *       added in the selector. This is the trade-off of this test. If that happens,
     *       An error is immediately thrown in the GIVEN clause, and you need to change the field.
     */
    @isTest
    static void shouldThrowSObjectExceptionWhenExcludedFieldIsRetrieved() {
        
        // GIVEN
        SObjectField arbitraryField = Contact.AssistantName; // bump this up here for better visibility

        // setup the Selector
        aef_ContactsSelector conSelector = aef_ContactsSelector.newInstance();
        Set<SObjectField> defaultSelectorFields = conSelector.getSObjectFieldList();
        Assert.isTrue(!defaultSelectorFields.contains(arbitraryField), 'Arbitrary field was added to getSObjectFieldList(), you need to pick something else');

        // insert a Contact
        aef_MockUtility.disableTriggerExecution();

        List<Contact> conList = aef_ApplicationTestDataFactory.getContacts(1, null, false);
        insert conList;

        List<Contact> result = new List<Contact>();

        Test.startTest();

        // WHEN
        result = conSelector.selectById(new Map<Id, Contact>(conList).keySet());

        Test.stopTest();

        // THEN
        Assert.isTrue(!result.isEmpty(), 'Unable to retrieve Contact record');

        try {
            Contact resultCon = result[0];
            String asstName = resultCon.AssistantName;
            Assert.fail('Failed to throw an exception while retrieving an unqueried field');
        } catch(SObjectException  e) {
            Assert.isTrue(true);
        } catch(Exception e) {
            Assert.fail('Expecting to throw an SObjectException');
        }
    }
}