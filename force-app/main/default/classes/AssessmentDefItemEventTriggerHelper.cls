public with sharing class AssessmentDefItemEventTriggerHelper {

    public static void processBeforeInsert(List<Assessment_Definition_Item_Event__c> newRecords) {
        setAssessmentDefinitionIds(newRecords);
    }

    public static void processBeforeUpdate(Map<Id, Assessment_Definition_Item_Event__c> oldRecordsMap, Map<Id, Assessment_Definition_Item_Event__c> newRecordsMap) {
        setAssessmentDefinitionIds(newRecordsMap.values());
    }

    private static void setAssessmentDefinitionIds(List<Assessment_Definition_Item_Event__c> records) {
        AssessmentTriggerHelperUtil.setDefinitionId(records,
            Schema.Assessment_Definition_Item_Event__c.Assessment_Definition__c,
            Schema.Assessment_Definition_Item_Event__c.Assessment_Definition_Item__c);
    }

}
