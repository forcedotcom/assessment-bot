@isTest
public with sharing class TestAssessmentUtil {

    public static final String TEST_QUEUE_ID = '00G3D000003TivRUAS';
    public static final String TEST_BOT_ID = '0Xx3D0000004CGnSAM';
    public static final String TEST_ASSESSMENT_ID = 'Test_Assessment_Id';

    public static String getTimestamp() {
        return String.valueof(Datetime.now().getTime());
    }

    public static String getTestTransferTargetId(String transferType) {
        String testId = null;
        if (transferType == AssessmentConstants.TRANSFER_TYPE_BOT) {
            testId = TEST_QUEUE_ID;
        } else if (transferType == AssessmentConstants.TRANSFER_TYPE_QUEUE) {
            testId = TEST_BOT_ID;
        } else if (transferType == AssessmentConstants.TRANSFER_TYPE_ASSESSMENT) {
            testId = TEST_ASSESSMENT_ID;
        }
        return testId;
    }

    public static List<Assessment_Definition__c> createAssessmentDefinitions(Integer totalDefinitions, String initialItemName) {
        List<Assessment_Definition__c> results = fillAssessmentDefinitions(totalDefinitions, initialItemName);
        insert results;
        return results;
    }

    public static List<Assessment_Definition__c> fillAssessmentDefinitions(Integer totalDefinitions, String initialItemName) {
        List<Assessment_Definition__c> results = new List<Assessment_Definition__c>();
        for (Integer i = 0; i < totalDefinitions; i++){
            Assessment_Definition__c ad = new Assessment_Definition__c();
            ad.Name = 'TestAD'+i+getTimestamp();
            ad.Active__c = true;
            ad.Assessment_Definition_Id__c = ad.Name;
            ad.Initial_Item_Name__c = initialItemName;
            ad.Delete_Transcript_on_Completion__c = true;
            results.add(ad);
        }
        return results;
    }

    public static Map<String, Assessment_Definition_Signal__c> createAssessmentDefinitionSignals(String definitionId, List<String> signalNames) {
        Map<String, Assessment_Definition_Signal__c> results = fillAssessmentDefinitionSignals(definitionId, signalNames);
        insert results.values();
        return results;
    }

    public static Map<String, Assessment_Definition_Signal__c> fillAssessmentDefinitionSignals(String definitionId, List<String> signalNames) {
        Map<String, Assessment_Definition_Signal__c> results = new Map<String, Assessment_Definition_Signal__c>();
        for (String signalName  : signalNames) {
            Assessment_Definition_Signal__c sig = new Assessment_Definition_Signal__c();
            sig.Assessment_Definition__c = definitionId;
            sig.Name = signalName;
            results.put(sig.Name, sig);
        }
        return results;
    }

    public static Assessment_Definition_Item__c fillDecisionItem(String definitionId, String name, String nextItemName,
        String nextItemCondition, String nextItemNameOther) {

        Assessment_Definition_Item__c item = new Assessment_Definition_Item__c();
        item.Name = name;
        item.Assessment_Definition__c = definitionId;
        item.Type__c = AssessmentConstants.ITEM_TYPE_DECISION;
        item.Next_Item_Name__c = nextItemName;
        item.Next_Item_Outcome_Condition__c = nextItemCondition;
        item.Next_Item_Name_Other_Outcome__c = nextItemNameOther;
        return item;
    }

    public static Assessment_Definition_Item__c fillAlertItem(String definitionId, String name, String message, String nextItemName) {

        Assessment_Definition_Item__c item = new Assessment_Definition_Item__c();
        item.Name = name;
        item.Assessment_Definition__c = definitionId;
        item.Type__c = AssessmentConstants.ITEM_TYPE_ALERT;
        item.Message__c = message;
        item.Next_Item_Name__c = nextItemName;
        return item;
    }

    public static Assessment_Definition_Item__c fillMessageItem(String definitionId, String name, String message, String nextItemName) {

        Assessment_Definition_Item__c item = new Assessment_Definition_Item__c();
        item.Name = name;
        item.Assessment_Definition__c = definitionId;
        item.Type__c = AssessmentConstants.ITEM_TYPE_MESSAGE;
        item.Message__c = message;
        item.Next_Item_Name__c = nextItemName;
        return item;
    }

    public static Assessment_Definition_Item__c fillQuestionItem(String definitionId, String name, String questionType ,String message,
            String nextItemName, String nextItemConditionOperator, String nextItemConditionValue, String nextItemNameOther) {

        Assessment_Definition_Item__c item = new Assessment_Definition_Item__c();
        item.Name = name;
        item.Assessment_Definition__c = definitionId;
        item.Type__c = AssessmentConstants.ITEM_TYPE_QUESTION;
        item.Question_Type__c = questionType;
        item.Message__c = message;
        item.Next_Item_Name__c = nextItemName;
        item.Next_Item_Condition_Operator__c = nextItemConditionOperator;
        item.Next_Item_Outcome_Condition__c = nextItemConditionValue;
        item.Next_Item_Name_Other_Outcome__c = nextItemNameOther;
        return item;
    }

    public static Assessment_Definition_Item__c fillTransferItem(String definitionId, String name, String transferType ,String transferTargetName) {
        Assessment_Definition_Item__c item = new Assessment_Definition_Item__c();
        item.Name = name;
        item.Assessment_Definition__c = definitionId;
        item.Type__c = AssessmentConstants.ITEM_TYPE_TRANSFER;
        item.Transfer_Type__c = transferType;
        item.Transfer_Target_Name__c = transferTargetName;
        return item;
    }

    public static List<Assessment_Definition_Item_Choice__c> fillQuestionItemChoices(String itemId, List<Map<String, String>> choices) {
        List<Assessment_Definition_Item_Choice__c> results = new List<Assessment_Definition_Item_Choice__c>();
        for (Integer i = 0; i < choices.size(); i++) {
            Assessment_Definition_Item_Choice__c ch = new Assessment_Definition_Item_Choice__c();
            Map<String, String> choiceParams = choices[i];
            ch.Assessment_Definition_Item__c = itemId;
            ch.Value__c = choiceParams.get('value');
            ch.Label__c = choiceParams.get('label') != null ? choiceParams.get('label') : ch.Value__c;
            ch.Assessment_Definition_Signal__c = choiceParams.get('signalId');
            ch.Next_Item_Name__c = choiceParams.get('nextItemName');
            ch.Order__c = i;
            results.add(ch);
        }
        return results;
    }

    public static List<Assessment_Definition_Decision_Signal__c> fillDecisionItemSignals(String itemId, List<String> signalIds) {
        List<Assessment_Definition_Decision_Signal__c> results = new List<Assessment_Definition_Decision_Signal__c>();
        for (Integer i = 0; i < signalIds.size(); i++) {
            Assessment_Definition_Decision_Signal__c ds = new Assessment_Definition_Decision_Signal__c();
            ds.Assessment_Definition_Item__c = itemId;
            ds.Assessment_Definition_Signal__c = signalIds[i];
            ds.Order__c = i;
            results.add(ds);
        }
        return results;
    }

    public static List<Assessment_Definition_Item_Event__c> fillItemEvents(String itemId, Map<String, Set<Id>> typeToSignalsMap) {
        List<Assessment_Definition_Item_Event__c> results = new List<Assessment_Definition_Item_Event__c>();
        for (String type : typeToSignalsMap.keySet()) {
            for(String signalId : typeToSignalsMap.get(type)) {
                Assessment_Definition_Item_Event__c ev = new Assessment_Definition_Item_Event__c();
                ev.Assessment_Definition_Item__c = itemId;
                ev.Type__c = type;
                ev.Assessment_Definition_Signal__c = signalId;
                results.add(ev);
            }
        }
        return results;
    }

    public static Assessment_Session__c createAssessmentSession(String assessmentDefinitionId, String status) {
        return createAssessmentSession(assessmentDefinitionId, status, null);
    }

    public static Assessment_Session__c createAssessmentSession(String assessmentDefinitionId, String status, String transcriptId) {
        Assessment_Session__c result = fillAssessmentSession(assessmentDefinitionId, status, transcriptId);
        insert result;
        return result;
    }

    public static Assessment_Session__c fillAssessmentSession(String assessmentDefinitionId, String status, String transcriptId) {
        Assessment_Session__c sess = new Assessment_Session__c();
        sess.Assessment_Definition__c = assessmentDefinitionId;
        sess.Source_Transcript_Id__c = transcriptId;
        sess.Status__c = status;
        return sess;
    }

    public static List<Assessment_Session_Signal__c> createAssessmentSessionSignals(String assessmentSessionId, List<Id> signalIds) {
        List<Assessment_Session_Signal__c> result = new List<Assessment_Session_Signal__c>();
        for (String signalId : signalIds) {
            Assessment_Session_Signal__c asi = new Assessment_Session_Signal__c();
            asi.Assessment_Session__c = assessmentSessionId;
            asi.Assessment_Definition_Signal__c = signalId;
            result.add(asi);
        }
        insert result;
        return result;
    }

    public static Map<String, Assessment_Definition_Item__c>  getAssessmentDefinitionItemsByIds(Set<String> assessmentDefinitionItemIds){
        Map<String, Assessment_Definition_Item__c> result = new Map<String, Assessment_Definition_Item__c>();
        List<Assessment_Definition_Item__c> items = [select Id,
                                                            Name,
                                                            Assessment_Definition__c,
                                                            Message__c,
                                                            Next_Item_Name__c,
                                                            Next_Item_Name_Other_Outcome__c,
                                                            Next_Item_Outcome_Condition__c,
                                                            Question_Type__c,
                                                            Type__c,
                                                            (select Id, Label__c, Value__c, Assessment_Definition_Signal__c, Next_Item_Name__c
                                                                from Assessment_Definition_Item_Choices__r order by Order__c asc),
                                                            (select Id, Assessment_Definition_Signal__c, Order__c
                                                                from Assessment_Definition_Decision_Signals__r order by Order__c asc)
                                                            from Assessment_Definition_Item__c
                                                            where Id in :assessmentDefinitionItemIds];
        if (!items.isEmpty()) {
            for (Assessment_Definition_Item__c item : items) {
                result.put(item.Id, item);
            }
        }
        return result;
    }

    public static Map<String, Assessment_Definition_Item__c> getAssessmentDefinitionItemsByNames(String assessmentDefinitionId, Set<String> names){
        Map<String, Assessment_Definition_Item__c> result = new Map<String, Assessment_Definition_Item__c>();
        List<Assessment_Definition_Item__c> items = [select Id,
                                                            Name,
                                                            Assessment_Definition__c,
                                                            Message__c,
                                                            Next_Item_Name__c,
                                                            Next_Item_Name_Other_Outcome__c,
                                                            Next_Item_Outcome_Condition__c,
                                                            Question_Type__c,
                                                            Type__c,
                                                            (select Id, Label__c, Value__c, Assessment_Definition_Signal__c, Next_Item_Name__c
                                                                from Assessment_Definition_Item_Choices__r order by Order__c asc),
                                                            (select Id, Assessment_Definition_Signal__c, Order__c
                                                                from Assessment_Definition_Decision_Signals__r order by Order__c asc)
                                                            from Assessment_Definition_Item__c
                                                            where Assessment_Definition__c = :assessmentDefinitionId
                                                            and Name in : names];
        if (!items.isEmpty()) {
            for (Assessment_Definition_Item__c item : items) {
                result.put(item.Name, item);
            }
        }
        return result;
    }

    public static Map<String, Assessment_Definition_Signal__c> getAssessmentDefinitionSignalsByNames(String assessmentDefinitionId, Set<String> names){
        Map<String, Assessment_Definition_Signal__c> result = new Map<String, Assessment_Definition_Signal__c>();
        List<Assessment_Definition_Signal__c> defSignals = [select Id,
                                                            Name
                                                            from Assessment_Definition_Signal__c
                                                            where Assessment_Definition__c = :assessmentDefinitionId
                                                            and Name in : names];
        if (!defSignals.isEmpty()) {
            for (Assessment_Definition_Signal__c defSignal : defSignals) {
                result.put(defSignal.Name, defSignal);
            }
        }
        return result;
    }

    public static List<Assessment_Session__c> getAssessmentSessionsByDefinitionIds(Set<Id> assessmentDefinitionIds){
        List<Assessment_Session__c> sessions = [select Id,
                                                        Name,
                                                        Source_Transcript_Id__c,
                                                        Source_Transcript_Deletion_Status__c,
                                                        Source_Transcript_Deletion_Error__c,
                                                        Processed__c,
                                                        Status__c,
                                                        Assessment_Definition__c,
                                                        (select Id, Assessment_Definition_Signal__c from Assessment_Session_Signals__r)
                                                        from Assessment_Session__c
                                                        where Assessment_Definition__c in :assessmentDefinitionIds];
        return sessions;
    }

    public static List<Assessment_Session__c> getAssessmentSessions(Set<Id> assessmentSessionIds){
        List<Assessment_Session__c> sessions = [select Id,
                                                        Name,
                                                        Assessment_Definition__c,
                                                        Status__c,
                                                        (select Id, Assessment_Definition_Signal__c from Assessment_Session_Signals__r)
                                                        from Assessment_Session__c
                                                        where Id in :assessmentSessionIds];
        return sessions;
    }

    public static void assertAssessmentSessionSignals(String assessmentSessionId, Set<String> expectedAssessmentDefinitionSignalIds) {
        List<Assessment_Session__c> sessions = getAssessmentSessions(new Set<Id>{assessmentSessionId});
        System.assertEquals(1, sessions.size());
        Assessment_Session__c session = sessions.get(0);
        List<Assessment_Session_Signal__c> sessionSignals = session.Assessment_Session_Signals__r;
        Set<String> currentSessionSignals = new Set<String>();
        for (Assessment_Session_Signal__c s : sessionSignals) {
            currentSessionSignals.add(s.Assessment_Definition_Signal__c);
        }
        System.assertEquals(expectedAssessmentDefinitionSignalIds.size(), currentSessionSignals.size());
        expectedAssessmentDefinitionSignalIds.removeAll(currentSessionSignals);
        System.assert(expectedAssessmentDefinitionSignalIds.size() == 0, 'Expected signals are not covered by the current session');
    }

    public static Assessment_Definition__c createTestAssessmentDefinition() {
        List<Assessment_Definition__c> definitions = createAssessmentDefinitions(1, 'C19_Initial_Message');
        System.assertEquals(1, definitions.size());
        Assessment_Definition__c def = definitions.get(0); 
        Map<String, Assessment_Definition_Signal__c> definitionSignals = createAssessmentDefinitionSignals(def.Id,
                                                                                                            new List<String>{
                                                                                                                'Symptomatic',
                                                                                                                'Non-Symptomatic',
                                                                                                                'NoConsent',
                                                                                                                'NoFever',
                                                                                                                'HighFever',
                                                                                                                'VeryHighFever',
                                                                                                                'Over65'});

        Map<String, Assessment_Definition_Item__c> itemsMap = new Map<String, Assessment_Definition_Item__c>{
            'C19_Initial_Message' => fillMessageItem(def.Id, 'C19_Initial_Message', 'a msg', 'C19_Greeting'),
            'C19_Greeting' => fillMessageItem(def.Id, 'C19_Greeting', 'a msg', 'C19_Greeting_2'),
            'C19_Greeting_2' => fillMessageItem(def.Id, 'C19_Greeting_2', 'a msg', 'C19_Consent'),
            'C19_Consent' => fillQuestionItem(def.Id, 'C19_Consent',AssessmentConstants.QUESTION_TYPE_TRUEFALSE, 'a msg', 'C19_Symptom_Screen1', AssessmentConstants.OPERATOR_EQUAL_TO, 'true', 'C19_No_Consent'),
            'C19_No_Consent' => fillMessageItem(def.Id, 'C19_No_Consent','a msg', null),
            'C19_Symptom_Screen1' => fillQuestionItem(def.Id, 'C19_Symptom_Screen1' ,'Choices', 'body temp choices', null, null, null, null),
            'C19_Call_911' => fillAlertItem(def.Id, 'C19_Call_911', 'a msg', null),
            'C19_Symptom_Screen2' => fillQuestionItem(def.Id, 'C19_Symptom_Screen2',AssessmentConstants.QUESTION_TYPE_TRUEFALSE, 'a msg', 'C19_Symptom_Screen3', AssessmentConstants.OPERATOR_EQUAL_TO, 'false', 'C19_Call_911'),
            'C19_Symptom_Screen3' => fillQuestionItem(def.Id, 'C19_Symptom_Screen3',AssessmentConstants.QUESTION_TYPE_TRUEFALSE, 'a msg', 'C19_Symptom_Screen4', AssessmentConstants.OPERATOR_EQUAL_TO, 'false', 'C19_Call_911'),
            'C19_Symptom_Screen4' => fillQuestionItem(def.Id, 'C19_Symptom_Screen4',AssessmentConstants.QUESTION_TYPE_TRUEFALSE, 'a msg', 'C19_Symptom_Screen5', AssessmentConstants.OPERATOR_EQUAL_TO, 'true', 'C19_Symptom_Screen6'),
            'C19_Symptom_Screen5' => fillQuestionItem(def.Id, 'C19_Symptom_Screen5',AssessmentConstants.QUESTION_TYPE_TRUEFALSE, 'a msg', 'C19_Symptomatic', AssessmentConstants.OPERATOR_EQUAL_TO, 'true', 'C19_Symptom_Screen6'),
            'C19_Symptom_Screen6' => fillQuestionItem(def.Id, 'C19_Symptom_Screen6',AssessmentConstants.QUESTION_TYPE_TRUEFALSE, 'a msg', 'C19_Symptomatic', AssessmentConstants.OPERATOR_EQUAL_TO, 'true', 'C19_Symptom_Screen7'),
            'C19_Symptom_Screen7' => fillMessageItem(def.Id, 'C19_Symptom_Screen7', 'a msg', 'C19_Symptom_Screen7_2'),
            'C19_Symptom_Screen7_2' => fillQuestionItem(def.Id, 'C19_Symptom_Screen7_2',AssessmentConstants.QUESTION_TYPE_TRUEFALSE, 'a msg', 'C19_Symptomatic', AssessmentConstants.OPERATOR_EQUAL_TO, 'true', 'C19_No_Action'),
            'C19_Symptomatic' => fillMessageItem(def.Id, 'C19_Symptomatic', 'a msg', 'C19_Symptomatic_2'),
            'C19_Symptomatic_2' => fillAlertItem(def.Id, 'C19_Symptomatic_2', 'a msg', null),
            'C19_No_Action' => fillMessageItem(def.Id, 'C19_No_Action', 'a msg', 'C19_No_Action_2'),
            'C19_No_Action_2' => fillAlertItem(def.Id, 'C19_No_Action_2', 'a msg', null),
            'C19_Fever_Age_Decision' => fillDecisionItem(def.Id, 'C19_Fever_Age_Decision', 'C19_Fever_Age_Decision_911', AssessmentConstants.AND_DECISION, 'C19_No_Action'),
            'C19_Fever_Age_Decision_911' => fillDecisionItem(def.Id, 'C19_Fever_Age_Decision_911', 'C19_Call_911', AssessmentConstants.AND_DECISION, 'C19_Symptomatic'),
            'C19_Age_Question' => fillQuestionItem(def.Id, 'C19_Age_Question', AssessmentConstants.QUESTION_TYPE_NUMBER, 'age question', 'C19_Call_911', AssessmentConstants.OPERATOR_EQUAL_TO, '60', 'C19_No_Action'),
            'C19_Age_Question_GT_Op' => fillQuestionItem(def.Id, 'C19_Age_Question_GT_Op', AssessmentConstants.QUESTION_TYPE_NUMBER, 'age question', 'C19_Call_911', AssessmentConstants.OPERATOR_GREATER_THAN, '60', 'C19_No_Action'),
            'C19_Age_Question_LT_Op' => fillQuestionItem(def.Id, 'C19_Age_Question_LT_Op', AssessmentConstants.QUESTION_TYPE_NUMBER, 'age question', 'C19_Call_911', AssessmentConstants.OPERATOR_LESS_THAN, '60', 'C19_No_Action'),
            'C19_Date_Question' => fillQuestionItem(def.Id, 'C19_Date_Question', AssessmentConstants.QUESTION_TYPE_DATE, 'date question', 'C19_Call_911', AssessmentConstants.OPERATOR_EQUAL_TO, '2020-08-22', 'C19_No_Action'),
            'C19_Date_Question_GT_Op' => fillQuestionItem(def.Id, 'C19_Date_Question_GT_Op', AssessmentConstants.QUESTION_TYPE_DATE, 'date question', 'C19_Call_911', AssessmentConstants.OPERATOR_GREATER_THAN, '2020-08-22', 'C19_No_Action'),
            'C19_Date_Question_LT_Op' => fillQuestionItem(def.Id, 'C19_Date_Question_LT_Op', AssessmentConstants.QUESTION_TYPE_DATE, 'date question', 'C19_Call_911', AssessmentConstants.OPERATOR_LESS_THAN, '2020-08-22', 'C19_No_Action'),
            'C19_Transfer_To_Agent' => fillTransferItem(def.Id, 'C19_Transfer_To_Agent',AssessmentConstants.TRANSFER_TYPE_AGENT, null),
            'C19_Transfer_To_Queue' => fillTransferItem(def.Id, 'C19_Transfer_To_Queue',AssessmentConstants.TRANSFER_TYPE_QUEUE, 'AssessTestQueue'+getTimestamp()),
            'C19_Transfer_To_Bot' => fillTransferItem(def.Id, 'C19_Transfer_To_Bot',AssessmentConstants.TRANSFER_TYPE_BOT, 'AssessTestBot'+getTimestamp()),
            'C19_Transfer_To_Assessment' => fillTransferItem(def.Id, 'C19_Transfer_To_Assessment',AssessmentConstants.TRANSFER_TYPE_ASSESSMENT, 'AssessmentDefinition'+getTimestamp())
        };
        insert itemsMap.values();

        List<Assessment_Definition_Item_Choice__c> assessmentItemChoices = new List<Assessment_Definition_Item_Choice__c>();

        assessmentItemChoices.addAll(fillQuestionItemChoices(itemsMap.get('C19_Symptom_Screen1').Id, new List<Map<String, String>>{
            new Map<String, String>{'value'=>'Normal', 'signalId' => definitionSignals.get('NoFever').Id, 'nextItemName' => 'C19_No_Action'},
            new Map<String, String>{'value'=>'High', 'signalId' => definitionSignals.get('HighFever').Id, 'nextItemName' => 'C19_Symptom_Screen2'},
            new Map<String, String>{'value'=>'VeryHigh', 'signalId' => definitionSignals.get('VeryHighFever').Id, 'nextItemName' => 'C19_Symptom_Screen2'}
        }));

        insert assessmentItemChoices;

        List<Assessment_Definition_Decision_Signal__c> assessmentItemDecisionSignals = new List<Assessment_Definition_Decision_Signal__c>();

        assessmentItemDecisionSignals.addAll(fillDecisionItemSignals(itemsMap.get('C19_Fever_Age_Decision').Id, new List<String>{
            definitionSignals.get('HighFever').Id,
            definitionSignals.get('Over65').Id
        }));
        assessmentItemDecisionSignals.addAll(fillDecisionItemSignals(itemsMap.get('C19_Fever_Age_Decision_911').Id, new List<String>{
            definitionSignals.get('VeryHighFever').Id
        }));

        insert assessmentItemDecisionSignals;

        List<Assessment_Definition_Item_Event__c> assessmentItemEvents = new List<Assessment_Definition_Item_Event__c>();
        assessmentItemEvents.addAll(fillItemEvents(itemsMap.get('C19_No_Consent').Id, new Map<String, Set<Id>>{
            AssessmentConstants.EVENT_TYPE_ON_ENTRY => new Set<Id>{definitionSignals.get('NoConsent').Id}}));
        assessmentItemEvents.addAll(fillItemEvents(itemsMap.get('C19_Symptomatic').Id, new Map<String, Set<Id>>{
            AssessmentConstants.EVENT_TYPE_ON_ENTRY => new Set<Id>{definitionSignals.get('Symptomatic').Id}}));
        assessmentItemEvents.addAll(fillItemEvents(itemsMap.get('C19_No_Action').Id, new Map<String, Set<Id>>{
            AssessmentConstants.EVENT_TYPE_ON_ENTRY => new Set<Id>{definitionSignals.get('Non-Symptomatic').Id}}));

        insert assessmentItemEvents;

        return def;

    }

}
