global with sharing class AssessmentEvaluateItemRequest {

    @InvocableVariable
    global String assessmentSessionId;
    
    @InvocableVariable
    global String assessmentItemId;

    @InvocableVariable
    global Boolean responseTrueOrFalse;
    
    @InvocableVariable
    global Date responseDate;
    
    @InvocableVariable
    global Double responseNumber;

    @InvocableVariable
    global String responseText;

}