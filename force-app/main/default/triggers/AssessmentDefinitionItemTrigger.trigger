trigger AssessmentDefinitionItemTrigger on Assessment_Definition_Item__c (before insert) {

    if (Trigger.isBefore){
        if (Trigger.isInsert) {
            AssessmentDefItemTriggerHelper.processBeforeInsert(Trigger.new);
        }
    }

}