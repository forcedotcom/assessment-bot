public with sharing class AssessmentTriggerHelperUtil {

    public static void setDefinitionId(List<SObject> records, Schema.SobjectField definitionAssessmentFieldId, Schema.SobjectField itemDefinitionFieldId) {
        AssessmentTriggerHelperUtil.WithoutSharingOps wsops = new AssessmentTriggerHelperUtil.WithoutSharingOps();
        Map<Id, Assessment_Definition_Item__c> items = wsops.getAssessmentDefinitionItems(records, itemDefinitionFieldId);
        for (Sobject r : records) {
            Assessment_Definition_Item__c parentItem = items.get((Id)r.get(itemDefinitionFieldId));
            if (parentItem == null) continue;
            r.put(definitionAssessmentFieldId, (Id)parentItem.get(Schema.Assessment_Definition_Item__c.Assessment_Definition__c));
        }
    }

    private without sharing class WithoutSharingOps {

        public Map<Id, Assessment_Definition_Item__c> getAssessmentDefinitionItems(List<SObject> records, Schema.SobjectField fieldId) {

            Set<Id> assessmentItemIds = new Set<Id>();
            for (SObject r : records) {
                assessmentItemIds.add((Id)r.get(fieldId));
            }

            Map<Id, Assessment_Definition_Item__c> items = new Map<Id, Assessment_Definition_Item__c>(
                [SELECT Id, Assessment_Definition__c
                    FROM Assessment_Definition_Item__c
                    WHERE Id in :assessmentItemIds]
                );
            return items;

        }

    }

}
