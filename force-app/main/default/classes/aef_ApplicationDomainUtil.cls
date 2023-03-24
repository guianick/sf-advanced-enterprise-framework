/**
 * @description       : This is a utility class for any reusable logic that are useful for the Domain Layer
 * @author            : Nick Guia
 * @group             : Commons
 * @last modified on  : 22-03-2023
 * @last modified by  : Nick Guia
**/
public inherited sharing class aef_ApplicationDomainUtil {

    /**
    * @description This is correlated to the approach I took on the Module layer. A single record checking seems
    *   more applicable to reduce the number of iteration for this specific approach.
    * @author Nick Guia | 22-03-2023 
    * @param SObject newRec : single record from Trigger.new 
    * @param SObject oldRec : single record from Trigger.old / map
    * @param Set<SObjectField> fieldsToCheck : fields to check if they were updated
    * @return Boolean : returns true ONLY IF all fields indicated were changed (AND operator)
    **/
    public static Boolean isFieldChanged(SObject newRec, SObject oldRec, Set<SObjectField> fieldsToCheck) {
        Boolean isChanged;
        if(newRec != null && oldRec != null && fieldsToCheck != null) {
            for(SObjectField iField : fieldsToCheck) {
                if(newRec.get(iField) != oldRec.get(iField)) {
                    isChanged = true;
                } else {
                    // 1 or more fields to check didn't change
                    isChanged = false;
                    break;
                }
            }
        } else {
            throw new aef_ApplicationDomainUtilException('Invalid null parameter');
        }

        return isChanged;
    }

    public class aef_ApplicationDomainUtilException extends Exception { }
}