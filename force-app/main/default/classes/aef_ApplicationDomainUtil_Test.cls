/**
 * @description       : Test class for aef_ApplicationDomainUtil
 * @author            : Nick Guia
 * @group             : Test Classes
 * @last modified on  : 22-03-2023
 * @last modified by  : Nick Guia
**/
@isTest(isParallel=true)
private class aef_ApplicationDomainUtil_Test {

    /**
     * @description
     *  This tests if isFieldChanged method properly checks field differences of
     *  two SObjects. In this context, the first SObject is primarily used to represent
     *  a Trigger.new record, and the second is the old record.
     * 
     *  This scenario tests for a field change scenario
     */
    @isTest
    static void shouldReturnTrueIfFieldChanged() {

        // GIVEN
        List<Case> caseList = aef_ApplicationTestDataFactory.getCases(2, null, true);

        // ensure statuses are different
        Case newRec = caseList[0];
        newRec.Status = 'New';

        Case oldRec = caseList[1];
        oldRec.Status = 'Closed';

        Boolean isChanged;

        Test.startTest();

        // WHEN
        isChanged = aef_ApplicationDomainUtil.isFieldChanged(newRec, oldRec, new Set<SObjectField> { Case.Status });

        Test.stopTest();

        // THEN
        Assert.isTrue(isChanged, 'Unable to detect field difference');
    }

    /**
     * @description
     *  This tests if isFieldChanged method properly checks field differences of
     *  two SObjects. In this context, the first SObject is primarily used to represent
     *  a Trigger.new record, and the second is the old record.
     * 
     *  This scenario tests for a field unchanged scenario
     */
    @isTest
    static void shouldReturnFalseIfFieldUnchanged() {

        // GIVEN
        List<Case> caseList = aef_ApplicationTestDataFactory.getCases(2, null, true);

        // ensure both statuses are set to 'New'
        Case newRec = caseList[0];
        newRec.Status = 'New';

        Case oldRec = caseList[1];
        oldRec.Status = 'New';

        Boolean isChanged;

        Test.startTest();

        // WHEN
        isChanged = aef_ApplicationDomainUtil.isFieldChanged(newRec, oldRec, new Set<SObjectField>{ Case.Status });

        Test.stopTest();

        // THEN
        Assert.isFalse(isChanged, 'Invalid field change detection on similar values');
    }

    /**
     * @description
     *  Test exception handling when passing null parameters to the utility
     */
    @isTest
    static void shouldThrowExceptionWithNullParameter() {

        // GIVEN
        Case newRec;
        Case oldRec;

        Boolean isChanged;

        Test.startTest();

        // WHEN
        try {
            isChanged = aef_ApplicationDomainUtil.isFieldChanged(newRec, oldRec, new Set<SObjectField>{ Case.Status });
            Assert.fail('Unexpected continuation after passing null parameters');
        } catch(aef_ApplicationDomainUtil.aef_ApplicationDomainUtilException e) {
            Assert.isNull(isChanged, 'Unexpected valid return after an Exception');
        } catch(Exception e) {
            Assert.fail('Expecting to throw an aef_ApplicationDomainUtilException');
        }
        
        Test.stopTest();
    }
}