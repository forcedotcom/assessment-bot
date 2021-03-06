global with sharing class AssessmentNextItemResponse {
    
    @InvocableVariable
    global String type;
    
    @InvocableVariable
    global String message;
    
    @InvocableVariable
    global String answerType;

    @InvocableVariable
    global List<AssessmentItemChoice> choices;

    @InvocableVariable
    global String assessmentItemId;

    @InvocableVariable
    global String transferType;

    @InvocableVariable
    global Id transferBotId;

    @InvocableVariable
    global Id transferQueueId;

    @InvocableVariable
    global String transferAssessmentId;

}