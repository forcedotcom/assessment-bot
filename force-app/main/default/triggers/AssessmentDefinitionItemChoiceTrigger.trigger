trigger AssessmentDefinitionItemChoiceTrigger on Assessment_Definition_Item_Choice__c (before insert, before update) {

    if (Trigger.isBefore){
        if (Trigger.isInsert) {
            AssessmentDefItemChoiceTriggerHelper.processBeforeInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            AssessmentDefItemChoiceTriggerHelper.processBeforeUpdate(Trigger.oldMap, Trigger.newMap);
        }
    }

}
