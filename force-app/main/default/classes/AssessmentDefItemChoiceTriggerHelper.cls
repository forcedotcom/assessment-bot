public with sharing class AssessmentDefItemChoiceTriggerHelper {

    public static void processBeforeInsert(List<Assessment_Definition_Item_Choice__c> newRecords) {
        setAssessmentDefinitionIds(newRecords);
    }

    public static void processBeforeUpdate(Map<Id, Assessment_Definition_Item_Choice__c> oldRecordsMap, Map<Id, Assessment_Definition_Item_Choice__c> newRecordsMap) {
        setAssessmentDefinitionIds(newRecordsMap.values());
    }

    private static void setAssessmentDefinitionIds(List<Assessment_Definition_Item_Choice__c> records) {
        AssessmentTriggerHelperUtil.setDefinitionId(records,
            Schema.Assessment_Definition_Item_Choice__c.Assessment_Definition__c,
            Schema.Assessment_Definition_Item_Choice__c.Assessment_Definition_Item__c);
    }

}
