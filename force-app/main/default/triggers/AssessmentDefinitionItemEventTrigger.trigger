trigger AssessmentDefinitionItemEventTrigger on Assessment_Definition_Item_Event__c (before insert, before update) {

    if (Trigger.isBefore){
        if (Trigger.isInsert) {
            AssessmentDefItemEventTriggerHelper.processBeforeInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            AssessmentDefItemEventTriggerHelper.processBeforeUpdate(Trigger.oldMap, Trigger.newMap);
        }
    }

}