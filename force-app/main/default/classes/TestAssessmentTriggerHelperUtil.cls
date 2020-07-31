@isTest
private with sharing class TestAssessmentTriggerHelperUtil {

    @isTest
    static void testAssessmentDefinitionDecisionSignal() {

        List<Assessment_Definition__c> definitions = TestAssessmentUtil.createAssessmentDefinitions(1, 'DecisionItem');
        System.assertEquals(1, definitions.size());
        Assessment_Definition__c def = definitions.get(0); 
        Map<String, Assessment_Definition_Signal__c> definitionSignals = TestAssessmentUtil.createAssessmentDefinitionSignals(def.Id,
                                                                                                            new List<String>{
                                                                                                                'Signal1',
                                                                                                                'Signal2'});

        Map<String, Assessment_Definition_Item__c> itemsMap = new Map<String, Assessment_Definition_Item__c>{
            'DecisionItem' => TestAssessmentUtil.fillDecisionItem(def.Id, 'DecisionItem', 'PositiveOutcome', AssessmentConstants.AND_DECISION, 'NegativeOutcome'),
            'PositiveOutcome' => TestAssessmentUtil.fillMessageItem(def.Id, 'PositiveOutcome','a msg', null),
            'NegativeOutcome' => TestAssessmentUtil.fillMessageItem(def.Id, 'NegativeOutcome','a msg', null)
        };
        insert itemsMap.values();

        List<Assessment_Definition_Decision_Signal__c> assessmentItemDecisionSignals = new List<Assessment_Definition_Decision_Signal__c>();
        assessmentItemDecisionSignals.addAll(TestAssessmentUtil.fillDecisionItemSignals(itemsMap.get('DecisionItem').Id, new List<String>{
            definitionSignals.get('Signal1').Id,
            definitionSignals.get('Signal2').Id
        }));
        insert assessmentItemDecisionSignals;

        assertChildDefinitionIdUpdates(def.Id,
                assessmentItemDecisionSignals,
                Assessment_Definition_Decision_Signal__c.SObjectType,
                Schema.Assessment_Definition_Decision_Signal__c.Assessment_Definition__c);

    }

    @isTest
    static void testAssessmentDefinitionItemChoices() {

        List<Assessment_Definition__c> definitions = TestAssessmentUtil.createAssessmentDefinitions(1, 'ChoicesItem');
        System.assertEquals(1, definitions.size());
        Assessment_Definition__c def = definitions.get(0); 
        Map<String, Assessment_Definition_Signal__c> definitionSignals = TestAssessmentUtil.createAssessmentDefinitionSignals(def.Id,
                                                                                                            new List<String>{
                                                                                                                'Signal1',
                                                                                                                'Signal2'});

        Map<String, Assessment_Definition_Item__c> itemsMap = new Map<String, Assessment_Definition_Item__c>{
            'ChoicesItem' => TestAssessmentUtil.fillQuestionItem(def.Id, 'ChoicesItem' ,'Choices', 'choices msg', null, null, null, null)
        };
        insert itemsMap.values();

        List<Assessment_Definition_Item_Choice__c> assessmentItemChoices = new List<Assessment_Definition_Item_Choice__c>();
        assessmentItemChoices.addAll(TestAssessmentUtil.fillQuestionItemChoices(itemsMap.get('ChoicesItem').Id, new List<Map<String, String>>{
            new Map<String, String>{'value'=>'Choice 1', 'signalId' => definitionSignals.get('Signal1').Id, 'nextItemName' => null},
            new Map<String, String>{'value'=>'Choice 2', 'signalId' => definitionSignals.get('Signal2').Id, 'nextItemName' => null}
        }));
        insert assessmentItemChoices;

        assertChildDefinitionIdUpdates(def.Id,
                assessmentItemChoices,
                Assessment_Definition_Item_Choice__c.SObjectType,
                Schema.Assessment_Definition_Item_Choice__c.Assessment_Definition__c);

    }

    @isTest
    static void testAssessmentDefinitionItemEvents() {

        List<Assessment_Definition__c> definitions = TestAssessmentUtil.createAssessmentDefinitions(1, 'MessageItem');
        System.assertEquals(1, definitions.size());
        Assessment_Definition__c def = definitions.get(0); 
        Map<String, Assessment_Definition_Signal__c> definitionSignals = TestAssessmentUtil.createAssessmentDefinitionSignals(def.Id,
                                                                                                            new List<String>{
                                                                                                                'Signal1',
                                                                                                                'Signal2'});

        Map<String, Assessment_Definition_Item__c> itemsMap = new Map<String, Assessment_Definition_Item__c>{
            'MessageItem' => TestAssessmentUtil.fillMessageItem(def.Id, 'MessageItem','a msg', null)
        };
        insert itemsMap.values();

        List<Assessment_Definition_Item_Event__c> assessmentItemEvents = new List<Assessment_Definition_Item_Event__c>();
        assessmentItemEvents.addAll(TestAssessmentUtil.fillItemEvents(itemsMap.get('MessageItem').Id, new Map<String, Set<Id>>{
            AssessmentConstants.EVENT_TYPE_ON_ENTRY => new Set<Id>{definitionSignals.get('Signal1').Id}}));

        insert assessmentItemEvents;

        assertChildDefinitionIdUpdates(def.Id,
                assessmentItemEvents,
                Assessment_Definition_Item_Event__c.SObjectType,
                Schema.Assessment_Definition_Item_Event__c.Assessment_Definition__c);

    }

    private static void assertChildDefinitionIdUpdates(Id definitionId, List<SObject> records, Schema.SobjectType childSObjectType, Schema.SobjectField definitionFieldId) {
        Set<Id> recordIds = new Set<Id>();
        for (SObject r : records) {
            recordIds.add(r.Id);
        }
        String soql = 'select Id, '+definitionFieldId.getDescribe().getName()+' from '+childSObjectType.getDescribe().getName()+' where Id in :recordIds';
        List<SObject> insertedRecords = Database.query(soql);
        for (SObject r : insertedRecords) {
            System.assertEquals(definitionId, (Id)r.get(definitionFieldId));
            r.put(definitionFieldId,null);
        }
        update insertedRecords;
        List<SObject> updatedRecords = Database.query(soql);
        for (SObject r : updatedRecords) {
            System.assertEquals(definitionId, (Id)r.get(definitionFieldId));
        }
    }

}
