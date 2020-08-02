public with sharing class AssessmentDefItemTriggerHelper {

    public static void processBeforeInsert(List<Assessment_Definition_Item__c> newRecords) {
        setRecordTypeIds(newRecords);
    }

    private static void setRecordTypeIds(List<Assessment_Definition_Item__c> newRecords) {
        AssessmentDefItemTriggerHelper.WithoutSharingOps wsops = new AssessmentDefItemTriggerHelper.WithoutSharingOps();
        Map<String, Id> typeToRTIdMap = wsops.getItemTypeToRecordTypeIdMap();
        for (Assessment_Definition_Item__c r : newRecords) {
            r.RecordTypeId = typeToRTIdMap.get(r.Type__c);
        }
    }

    private without sharing class WithoutSharingOps {
        public Map<String, Id> getItemTypeToRecordTypeIdMap() {
            Map<String, Id> result = new Map<String, Id>();
            for(RecordType rt : [select Id, DeveloperName From RecordType where sobjecttype = 'Assessment_Definition_Item__c']){
                result.put(rt.DeveloperName, rt.Id);
            }
            return result;
        }
    }

}