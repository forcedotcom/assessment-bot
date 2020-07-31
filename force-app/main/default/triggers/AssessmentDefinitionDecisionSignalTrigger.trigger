trigger AssessmentDefinitionDecisionSignalTrigger on Assessment_Definition_Decision_Signal__c (before insert, before update) {

    if (Trigger.isBefore){
        if (Trigger.isInsert) {
            AssessmentDefDecisionSignalTriggerHelper.processBeforeInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            AssessmentDefDecisionSignalTriggerHelper.processBeforeUpdate(Trigger.oldMap, Trigger.newMap);
        }
    }

}