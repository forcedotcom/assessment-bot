@isTest
private with sharing class TestAssessmentServiceImpl {

    @isTest
    static void testInitialItemResponse() {
        Assessment_Definition__c def = TestAssessmentUtil.createTestAssessmentDefinition();

        Test.startTest();
        AssessmentInitialItemRequest initialItemRequest = new AssessmentInitialItemRequest();
        initialItemRequest.assessmentDefinitionId = def.Assessment_Definition_Id__c;
        AssessmentService service = new AssessmentServiceImpl();
        AssessmentInitialItemResponse initialResponse = service.getInitialItemResponse(initialItemRequest);
        Test.stopTest();

        System.assertEquals(true, initialResponse.isActive);
        System.assertNotEquals(null, initialResponse.initalAssessmentItemId);

        Map<String, Assessment_Definition_Item__c> itemsMap = TestAssessmentUtil.getAssessmentDefinitionItemsByIds(
            new Set<String>{initialResponse.initalAssessmentItemId});

        Assessment_Definition_Item__c item = itemsMap.get(initialResponse.initalAssessmentItemId);
        System.assertEquals('C19_Initial_Message', item.Name);
        System.assertNotEquals(null, initialResponse.assessmentSessionId);
    }

    @isTest
    static void testGetNextItemResponseMessageWithSignal() {
        Assessment_Definition__c def = TestAssessmentUtil.createTestAssessmentDefinition();
        Assessment_Session__c sess = TestAssessmentUtil.createAssessmentSession(def.Id, 'In Progress');
        System.assertNotEquals(null, sess);

        Map<String, Assessment_Definition_Item__c> itemsMap = TestAssessmentUtil.getAssessmentDefinitionItemsByNames(
            def.Id,
            new Set<String>{'C19_No_Consent'});

        Assessment_Definition_Item__c currentItem = itemsMap.get('C19_No_Consent');
        System.assertNotEquals(null, currentItem);

        Map<String, Assessment_Definition_Signal__c> signalsMap = TestAssessmentUtil.getAssessmentDefinitionSignalsByNames(
            def.Id,
            new Set<String>{'NoConsent'});

        Test.startTest();

        AssessmentNextItemRequest req = new AssessmentNextItemRequest();
        req.assessmentSessionId = sess.Id;
        req.assessmentItemId = currentItem.Id;

        AssessmentService service = new AssessmentServiceImpl();
        AssessmentNextItemResponse nextItemResponse = service.getNextItemResponse(req);
        Test.stopTest();

        System.assertEquals('Message', nextItemResponse.type);
        System.assertEquals('a msg', nextItemResponse.message);
        System.assertEquals(currentItem.Id, nextItemResponse.assessmentItemId);
        System.assertEquals(0, nextItemResponse.choices.size());
        TestAssessmentUtil.assertAssessmentSessionSignals(sess.Id, new Set<String>{signalsMap.get('NoConsent').Id});
    }

    @isTest
    static void testGetNextItemResponseQuestionTrueFalse() {
        Assessment_Definition__c def = TestAssessmentUtil.createTestAssessmentDefinition();
        Assessment_Session__c sess = TestAssessmentUtil.createAssessmentSession(def.Id, 'In Progress');
        System.assertNotEquals(null, sess);

        Map<String, Assessment_Definition_Item__c> itemsMap = TestAssessmentUtil.getAssessmentDefinitionItemsByNames(
            def.Id,
            new Set<String>{'C19_Consent'});

        Assessment_Definition_Item__c currentItem = itemsMap.get('C19_Consent');
        System.assertNotEquals(null, currentItem);

        Test.startTest();

        AssessmentNextItemRequest req = new AssessmentNextItemRequest();
        req.assessmentSessionId = sess.Id;
        req.assessmentItemId = currentItem.Id;

        AssessmentService service = new AssessmentServiceImpl();
        AssessmentNextItemResponse nextItemResponse = service.getNextItemResponse(req);
        Test.stopTest();

        System.assertEquals('Question', nextItemResponse.type);
        System.assertEquals('TrueOrFalse', nextItemResponse.answerType);
        System.assertEquals('a msg', nextItemResponse.message);
        System.assertEquals(currentItem.Id, nextItemResponse.assessmentItemId);
        System.assertEquals(0, nextItemResponse.choices.size());
    }

    @isTest
    static void testGetNextItemResponseQuestionChoices() {
        Assessment_Definition__c def = TestAssessmentUtil.createTestAssessmentDefinition();
        Assessment_Session__c sess = TestAssessmentUtil.createAssessmentSession(def.Id, 'In Progress');
        System.assertNotEquals(null, sess);

        Map<String, Assessment_Definition_Item__c> itemsMap = TestAssessmentUtil.getAssessmentDefinitionItemsByNames(
            def.Id,
            new Set<String>{'C19_Symptom_Screen1'});

        Assessment_Definition_Item__c currentItem = itemsMap.get('C19_Symptom_Screen1');
        System.assertNotEquals(null, currentItem);

        Test.startTest();

        AssessmentNextItemRequest req = new AssessmentNextItemRequest();
        req.assessmentSessionId = sess.Id;
        req.assessmentItemId = currentItem.Id;

        AssessmentService service = new AssessmentServiceImpl();
        AssessmentNextItemResponse nextItemResponse = service.getNextItemResponse(req);
        Test.stopTest();

        System.assertEquals('Question', nextItemResponse.type);
        System.assertEquals('Choices', nextItemResponse.answerType);
        System.assertEquals('body temp choices', nextItemResponse.message);
        System.assertEquals(currentItem.Id, nextItemResponse.assessmentItemId);
        System.assertEquals(3, nextItemResponse.choices.size());
    }

    @isTest
    static void testGetNextItemResponseDecision() {
        Assessment_Definition__c def = TestAssessmentUtil.createTestAssessmentDefinition();
        Assessment_Session__c sess = TestAssessmentUtil.createAssessmentSession(def.Id, 'In Progress');
        System.assertNotEquals(null, sess);

        Map<String, Assessment_Definition_Item__c> itemsMap = TestAssessmentUtil.getAssessmentDefinitionItemsByNames(
            def.Id,
            new Set<String>{'C19_Fever_Age_Decision', 'C19_No_Action'});

        Map<String, Assessment_Definition_Signal__c> signalsMap = TestAssessmentUtil.getAssessmentDefinitionSignalsByNames(
            def.Id,
            new Set<String>{'HighFever', 'Over65', 'VeryHighFever'});
            
        TestAssessmentUtil.createAssessmentSessionSignals(sess.Id, new List<String>{
            signalsMap.get('HighFever').Id
        });

        Assessment_Definition_Item__c currentItem = itemsMap.get('C19_Fever_Age_Decision');
        Assessment_Definition_Item__c expectedNextItem = itemsMap.get('C19_No_Action');

        System.assertNotEquals(null, currentItem);
        System.assertNotEquals(null, expectedNextItem);

        Test.startTest();

        AssessmentNextItemRequest req = new AssessmentNextItemRequest();
        req.assessmentSessionId = sess.Id;
        req.assessmentItemId = currentItem.Id;

        AssessmentService service = new AssessmentServiceImpl();
        AssessmentNextItemResponse nextItemResponse = service.getNextItemResponse(req);
        Test.stopTest();

        System.assertEquals('Message', nextItemResponse.type);
        System.assertEquals('a msg', nextItemResponse.message);
        System.assertEquals(expectedNextItem.Id, nextItemResponse.assessmentItemId);
        System.assertEquals(0, nextItemResponse.choices.size());
    }

    @isTest
    static void testGetNextItemResponseDecisionRecursive() {
        Assessment_Definition__c def = TestAssessmentUtil.createTestAssessmentDefinition();
        Assessment_Session__c sess = TestAssessmentUtil.createAssessmentSession(def.Id, 'In Progress');
        System.assertNotEquals(null, sess);

        Map<String, Assessment_Definition_Item__c> itemsMap = TestAssessmentUtil.getAssessmentDefinitionItemsByNames(
            def.Id,
            new Set<String>{'C19_Fever_Age_Decision', 'C19_Call_911'});

        Map<String, Assessment_Definition_Signal__c> signalsMap = TestAssessmentUtil.getAssessmentDefinitionSignalsByNames(
            def.Id,
            new Set<String>{'HighFever', 'Over65', 'VeryHighFever'});
            
        TestAssessmentUtil.createAssessmentSessionSignals(sess.Id, new List<String>{
            signalsMap.get('HighFever').Id,
            signalsMap.get('Over65').Id,
            signalsMap.get('VeryHighFever').Id
        });

        Assessment_Definition_Item__c currentItem = itemsMap.get('C19_Fever_Age_Decision');
        Assessment_Definition_Item__c expectedNextItem = itemsMap.get('C19_Call_911');

        System.assertNotEquals(null, currentItem);
        System.assertNotEquals(null, expectedNextItem);

        Test.startTest();

        AssessmentNextItemRequest req = new AssessmentNextItemRequest();
        req.assessmentSessionId = sess.Id;
        req.assessmentItemId = currentItem.Id;

        AssessmentService service = new AssessmentServiceImpl();
        AssessmentNextItemResponse nextItemResponse = service.getNextItemResponse(req);
        Test.stopTest();

        System.assertEquals('Alert', nextItemResponse.type);
        System.assertEquals('a msg', nextItemResponse.message);
        System.assertEquals(expectedNextItem.Id, nextItemResponse.assessmentItemId);
        System.assertEquals(0, nextItemResponse.choices.size());
    }

    @isTest
    static void testEvaluateItemResponseQuestionTrueFalse() {
        Assessment_Definition__c def = TestAssessmentUtil.createTestAssessmentDefinition();
        Assessment_Session__c sess = TestAssessmentUtil.createAssessmentSession(def.Id, 'In Progress');
        System.assertNotEquals(null, sess);

        Map<String, Assessment_Definition_Item__c> itemsMap = TestAssessmentUtil.getAssessmentDefinitionItemsByNames(
            def.Id,
            new Set<String>{'C19_Consent', 'C19_No_Consent'});

        Assessment_Definition_Item__c currentItem = itemsMap.get('C19_Consent');
        Assessment_Definition_Item__c expectedItem = itemsMap.get('C19_No_Consent');
        System.assertNotEquals(null, currentItem);
        System.assertNotEquals(null, expectedItem);

        Test.startTest();

        AssessmentEvaluateItemRequest req = new AssessmentEvaluateItemRequest();
        req.assessmentSessionId = sess.Id;
        req.assessmentItemId = currentItem.Id;
        req.responseTrueOrFalse = false;

        AssessmentService service = new AssessmentServiceImpl();
        AssessmentEvaluateItemResponse evaluateItemResponse = service.evaluateItemResponse(req);
        Test.stopTest();

        System.assertEquals(expectedItem.Id, evaluateItemResponse.nextAssessmentItemId);
    }

    @isTest
    static void testEvaluateItemResponseQuestionNumberEqualMatch() {
        Assessment_Definition__c def = TestAssessmentUtil.createTestAssessmentDefinition();
        Assessment_Session__c sess = TestAssessmentUtil.createAssessmentSession(def.Id, 'In Progress');
        System.assertNotEquals(null, sess);

        Map<String, Assessment_Definition_Item__c> itemsMap = TestAssessmentUtil.getAssessmentDefinitionItemsByNames(
            def.Id,
            new Set<String>{'C19_Age_Question', 'C19_Call_911', 'C19_No_Action'});

        Assessment_Definition_Item__c currentItem = itemsMap.get('C19_Age_Question');
        Assessment_Definition_Item__c expectedItem = itemsMap.get('C19_Call_911');
        System.assertNotEquals(null, currentItem);
        System.assertNotEquals(null, expectedItem);

        Test.startTest();

        AssessmentEvaluateItemRequest req = new AssessmentEvaluateItemRequest();
        req.assessmentSessionId = sess.Id;
        req.assessmentItemId = currentItem.Id;
        req.responseNumber = 60;

        AssessmentService service = new AssessmentServiceImpl();
        AssessmentEvaluateItemResponse evaluateItemResponse = service.evaluateItemResponse(req);
        Test.stopTest();

        System.assertEquals(expectedItem.Id, evaluateItemResponse.nextAssessmentItemId);
    }

    @isTest
    static void testEvaluateItemResponseQuestionNumberNotEqualMatch() {
        Assessment_Definition__c def = TestAssessmentUtil.createTestAssessmentDefinition();
        Assessment_Session__c sess = TestAssessmentUtil.createAssessmentSession(def.Id, 'In Progress');
        System.assertNotEquals(null, sess);

        Map<String, Assessment_Definition_Item__c> itemsMap = TestAssessmentUtil.getAssessmentDefinitionItemsByNames(
            def.Id,
            new Set<String>{'C19_Age_Question', 'C19_Call_911', 'C19_No_Action'});

        Assessment_Definition_Item__c currentItem = itemsMap.get('C19_Age_Question');
        Assessment_Definition_Item__c expectedItem = itemsMap.get('C19_No_Action');
        System.assertNotEquals(null, currentItem);
        System.assertNotEquals(null, expectedItem);

        Test.startTest();

        AssessmentEvaluateItemRequest req = new AssessmentEvaluateItemRequest();
        req.assessmentSessionId = sess.Id;
        req.assessmentItemId = currentItem.Id;
        req.responseNumber = 30;

        AssessmentService service = new AssessmentServiceImpl();
        AssessmentEvaluateItemResponse evaluateItemResponse = service.evaluateItemResponse(req);
        Test.stopTest();

        System.assertEquals(expectedItem.Id, evaluateItemResponse.nextAssessmentItemId);
    }

    @isTest
    static void testEvaluateItemResponseQuestionNumberGreaterThanMatch() {
        Assessment_Definition__c def = TestAssessmentUtil.createTestAssessmentDefinition();
        Assessment_Session__c sess = TestAssessmentUtil.createAssessmentSession(def.Id, 'In Progress');
        System.assertNotEquals(null, sess);

        Map<String, Assessment_Definition_Item__c> itemsMap = TestAssessmentUtil.getAssessmentDefinitionItemsByNames(
            def.Id,
            new Set<String>{'C19_Age_Question_GT_Op', 'C19_Call_911', 'C19_No_Action'});

        Assessment_Definition_Item__c currentItem = itemsMap.get('C19_Age_Question_GT_Op');
        Assessment_Definition_Item__c expectedItem = itemsMap.get('C19_Call_911');
        System.assertNotEquals(null, currentItem);
        System.assertNotEquals(null, expectedItem);

        Test.startTest();

        AssessmentEvaluateItemRequest req = new AssessmentEvaluateItemRequest();
        req.assessmentSessionId = sess.Id;
        req.assessmentItemId = currentItem.Id;
        req.responseNumber = 61;

        AssessmentService service = new AssessmentServiceImpl();
        AssessmentEvaluateItemResponse evaluateItemResponse = service.evaluateItemResponse(req);
        Test.stopTest();

        System.assertEquals(expectedItem.Id, evaluateItemResponse.nextAssessmentItemId);
    }

    @isTest
    static void testEvaluateItemResponseQuestionNumberGreaterThanNoMatch() {
        Assessment_Definition__c def = TestAssessmentUtil.createTestAssessmentDefinition();
        Assessment_Session__c sess = TestAssessmentUtil.createAssessmentSession(def.Id, 'In Progress');
        System.assertNotEquals(null, sess);

        Map<String, Assessment_Definition_Item__c> itemsMap = TestAssessmentUtil.getAssessmentDefinitionItemsByNames(
            def.Id,
            new Set<String>{'C19_Age_Question_GT_Op', 'C19_Call_911', 'C19_No_Action'});

        Assessment_Definition_Item__c currentItem = itemsMap.get('C19_Age_Question_GT_Op');
        Assessment_Definition_Item__c expectedItem = itemsMap.get('C19_No_Action');
        System.assertNotEquals(null, currentItem);
        System.assertNotEquals(null, expectedItem);

        Test.startTest();

        AssessmentEvaluateItemRequest req = new AssessmentEvaluateItemRequest();
        req.assessmentSessionId = sess.Id;
        req.assessmentItemId = currentItem.Id;
        req.responseNumber = 59;

        AssessmentService service = new AssessmentServiceImpl();
        AssessmentEvaluateItemResponse evaluateItemResponse = service.evaluateItemResponse(req);
        Test.stopTest();

        System.assertEquals(expectedItem.Id, evaluateItemResponse.nextAssessmentItemId);
    }

    @isTest
    static void testEvaluateItemResponseQuestionNumberLessThanMatch() {
        Assessment_Definition__c def = TestAssessmentUtil.createTestAssessmentDefinition();
        Assessment_Session__c sess = TestAssessmentUtil.createAssessmentSession(def.Id, 'In Progress');
        System.assertNotEquals(null, sess);

        Map<String, Assessment_Definition_Item__c> itemsMap = TestAssessmentUtil.getAssessmentDefinitionItemsByNames(
            def.Id,
            new Set<String>{'C19_Age_Question_LT_Op', 'C19_Call_911', 'C19_No_Action'});

        Assessment_Definition_Item__c currentItem = itemsMap.get('C19_Age_Question_LT_Op');
        Assessment_Definition_Item__c expectedItem = itemsMap.get('C19_Call_911');
        System.assertNotEquals(null, currentItem);
        System.assertNotEquals(null, expectedItem);

        Test.startTest();

        AssessmentEvaluateItemRequest req = new AssessmentEvaluateItemRequest();
        req.assessmentSessionId = sess.Id;
        req.assessmentItemId = currentItem.Id;
        req.responseNumber = 59;

        AssessmentService service = new AssessmentServiceImpl();
        AssessmentEvaluateItemResponse evaluateItemResponse = service.evaluateItemResponse(req);
        Test.stopTest();

        System.assertEquals(expectedItem.Id, evaluateItemResponse.nextAssessmentItemId);
    }

    @isTest
    static void testEvaluateItemResponseQuestionNumberLessThanNoMatch() {
        Assessment_Definition__c def = TestAssessmentUtil.createTestAssessmentDefinition();
        Assessment_Session__c sess = TestAssessmentUtil.createAssessmentSession(def.Id, 'In Progress');
        System.assertNotEquals(null, sess);

        Map<String, Assessment_Definition_Item__c> itemsMap = TestAssessmentUtil.getAssessmentDefinitionItemsByNames(
            def.Id,
            new Set<String>{'C19_Age_Question_LT_Op', 'C19_Call_911', 'C19_No_Action'});

        Assessment_Definition_Item__c currentItem = itemsMap.get('C19_Age_Question_LT_Op');
        Assessment_Definition_Item__c expectedItem = itemsMap.get('C19_No_Action');
        System.assertNotEquals(null, currentItem);
        System.assertNotEquals(null, expectedItem);

        Test.startTest();

        AssessmentEvaluateItemRequest req = new AssessmentEvaluateItemRequest();
        req.assessmentSessionId = sess.Id;
        req.assessmentItemId = currentItem.Id;
        req.responseNumber = 61;

        AssessmentService service = new AssessmentServiceImpl();
        AssessmentEvaluateItemResponse evaluateItemResponse = service.evaluateItemResponse(req);
        Test.stopTest();

        System.assertEquals(expectedItem.Id, evaluateItemResponse.nextAssessmentItemId);
    }

    @isTest
    static void testEvaluateItemResponseQuestionDateEqualMatch() {
        Assessment_Definition__c def = TestAssessmentUtil.createTestAssessmentDefinition();
        Assessment_Session__c sess = TestAssessmentUtil.createAssessmentSession(def.Id, 'In Progress');
        System.assertNotEquals(null, sess);

        Map<String, Assessment_Definition_Item__c> itemsMap = TestAssessmentUtil.getAssessmentDefinitionItemsByNames(
            def.Id,
            new Set<String>{'C19_Date_Question', 'C19_Call_911', 'C19_No_Action'});

        Assessment_Definition_Item__c currentItem = itemsMap.get('C19_Date_Question');
        Assessment_Definition_Item__c expectedItem = itemsMap.get('C19_Call_911');
        System.assertNotEquals(null, currentItem);
        System.assertNotEquals(null, expectedItem);

        Test.startTest();

        AssessmentEvaluateItemRequest req = new AssessmentEvaluateItemRequest();
        req.assessmentSessionId = sess.Id;
        req.assessmentItemId = currentItem.Id;
        req.responseDate = Date.newInstance(2020,8,22);

        AssessmentService service = new AssessmentServiceImpl();
        AssessmentEvaluateItemResponse evaluateItemResponse = service.evaluateItemResponse(req);
        Test.stopTest();

        System.assertEquals(expectedItem.Id, evaluateItemResponse.nextAssessmentItemId);
    }

    @isTest
    static void testEvaluateItemResponseQuestionDateNotEqualMatch() {
        Assessment_Definition__c def = TestAssessmentUtil.createTestAssessmentDefinition();
        Assessment_Session__c sess = TestAssessmentUtil.createAssessmentSession(def.Id, 'In Progress');
        System.assertNotEquals(null, sess);

        Map<String, Assessment_Definition_Item__c> itemsMap = TestAssessmentUtil.getAssessmentDefinitionItemsByNames(
            def.Id,
            new Set<String>{'C19_Date_Question', 'C19_Call_911', 'C19_No_Action'});

        Assessment_Definition_Item__c currentItem = itemsMap.get('C19_Date_Question');
        Assessment_Definition_Item__c expectedItem = itemsMap.get('C19_No_Action');
        System.assertNotEquals(null, currentItem);
        System.assertNotEquals(null, expectedItem);

        Test.startTest();

        AssessmentEvaluateItemRequest req = new AssessmentEvaluateItemRequest();
        req.assessmentSessionId = sess.Id;
        req.assessmentItemId = currentItem.Id;
        req.responseDate = Date.newInstance(2020,8,21);

        AssessmentService service = new AssessmentServiceImpl();
        AssessmentEvaluateItemResponse evaluateItemResponse = service.evaluateItemResponse(req);
        Test.stopTest();

        System.assertEquals(expectedItem.Id, evaluateItemResponse.nextAssessmentItemId);
    }

    @isTest
    static void testEvaluateItemResponseQuestionDateGreaterThanMatch() {
        Assessment_Definition__c def = TestAssessmentUtil.createTestAssessmentDefinition();
        Assessment_Session__c sess = TestAssessmentUtil.createAssessmentSession(def.Id, 'In Progress');
        System.assertNotEquals(null, sess);

        Map<String, Assessment_Definition_Item__c> itemsMap = TestAssessmentUtil.getAssessmentDefinitionItemsByNames(
            def.Id,
            new Set<String>{'C19_Date_Question_GT_Op', 'C19_Call_911', 'C19_No_Action'});

        Assessment_Definition_Item__c currentItem = itemsMap.get('C19_Date_Question_GT_Op');
        Assessment_Definition_Item__c expectedItem = itemsMap.get('C19_Call_911');
        System.assertNotEquals(null, currentItem);
        System.assertNotEquals(null, expectedItem);

        Test.startTest();

        AssessmentEvaluateItemRequest req = new AssessmentEvaluateItemRequest();
        req.assessmentSessionId = sess.Id;
        req.assessmentItemId = currentItem.Id;
        req.responseDate = Date.newInstance(2020,8,23);

        AssessmentService service = new AssessmentServiceImpl();
        AssessmentEvaluateItemResponse evaluateItemResponse = service.evaluateItemResponse(req);
        Test.stopTest();

        System.assertEquals(expectedItem.Id, evaluateItemResponse.nextAssessmentItemId);
    }

    @isTest
    static void testEvaluateItemResponseQuestionDateGreaterThanNoMatch() {
        Assessment_Definition__c def = TestAssessmentUtil.createTestAssessmentDefinition();
        Assessment_Session__c sess = TestAssessmentUtil.createAssessmentSession(def.Id, 'In Progress');
        System.assertNotEquals(null, sess);

        Map<String, Assessment_Definition_Item__c> itemsMap = TestAssessmentUtil.getAssessmentDefinitionItemsByNames(
            def.Id,
            new Set<String>{'C19_Date_Question_GT_Op', 'C19_Call_911', 'C19_No_Action'});

        Assessment_Definition_Item__c currentItem = itemsMap.get('C19_Date_Question_GT_Op');
        Assessment_Definition_Item__c expectedItem = itemsMap.get('C19_No_Action');
        System.assertNotEquals(null, currentItem);
        System.assertNotEquals(null, expectedItem);

        Test.startTest();

        AssessmentEvaluateItemRequest req = new AssessmentEvaluateItemRequest();
        req.assessmentSessionId = sess.Id;
        req.assessmentItemId = currentItem.Id;
        req.responseDate = Date.newInstance(2020,8,21);

        AssessmentService service = new AssessmentServiceImpl();
        AssessmentEvaluateItemResponse evaluateItemResponse = service.evaluateItemResponse(req);
        Test.stopTest();

        System.assertEquals(expectedItem.Id, evaluateItemResponse.nextAssessmentItemId);
    }

    @isTest
    static void testEvaluateItemResponseQuestionDateLessThanMatch() {
        Assessment_Definition__c def = TestAssessmentUtil.createTestAssessmentDefinition();
        Assessment_Session__c sess = TestAssessmentUtil.createAssessmentSession(def.Id, 'In Progress');
        System.assertNotEquals(null, sess);

        Map<String, Assessment_Definition_Item__c> itemsMap = TestAssessmentUtil.getAssessmentDefinitionItemsByNames(
            def.Id,
            new Set<String>{'C19_Date_Question_LT_Op', 'C19_Call_911', 'C19_No_Action'});

        Assessment_Definition_Item__c currentItem = itemsMap.get('C19_Date_Question_LT_Op');
        Assessment_Definition_Item__c expectedItem = itemsMap.get('C19_Call_911');
        System.assertNotEquals(null, currentItem);
        System.assertNotEquals(null, expectedItem);

        Test.startTest();

        AssessmentEvaluateItemRequest req = new AssessmentEvaluateItemRequest();
        req.assessmentSessionId = sess.Id;
        req.assessmentItemId = currentItem.Id;
        req.responseDate = Date.newInstance(2020,8,21);

        AssessmentService service = new AssessmentServiceImpl();
        AssessmentEvaluateItemResponse evaluateItemResponse = service.evaluateItemResponse(req);
        Test.stopTest();

        System.assertEquals(expectedItem.Id, evaluateItemResponse.nextAssessmentItemId);
    }

    @isTest
    static void testEvaluateItemResponseQuestionDateLessThanNoMatch() {
        Assessment_Definition__c def = TestAssessmentUtil.createTestAssessmentDefinition();
        Assessment_Session__c sess = TestAssessmentUtil.createAssessmentSession(def.Id, 'In Progress');
        System.assertNotEquals(null, sess);

        Map<String, Assessment_Definition_Item__c> itemsMap = TestAssessmentUtil.getAssessmentDefinitionItemsByNames(
            def.Id,
            new Set<String>{'C19_Date_Question_LT_Op', 'C19_Call_911', 'C19_No_Action'});

        Assessment_Definition_Item__c currentItem = itemsMap.get('C19_Date_Question_LT_Op');
        Assessment_Definition_Item__c expectedItem = itemsMap.get('C19_No_Action');
        System.assertNotEquals(null, currentItem);
        System.assertNotEquals(null, expectedItem);

        Test.startTest();

        AssessmentEvaluateItemRequest req = new AssessmentEvaluateItemRequest();
        req.assessmentSessionId = sess.Id;
        req.assessmentItemId = currentItem.Id;
        req.responseDate = Date.newInstance(2020,8,23);

        AssessmentService service = new AssessmentServiceImpl();
        AssessmentEvaluateItemResponse evaluateItemResponse = service.evaluateItemResponse(req);
        Test.stopTest();

        System.assertEquals(expectedItem.Id, evaluateItemResponse.nextAssessmentItemId);
    }

    @isTest
    static void testEvaluateItemResponseQuestionChoiceWithSignal() {
        Assessment_Definition__c def = TestAssessmentUtil.createTestAssessmentDefinition();
        Assessment_Session__c sess = TestAssessmentUtil.createAssessmentSession(def.Id, 'In Progress');
        System.assertNotEquals(null, sess);

        Map<String, Assessment_Definition_Item__c> itemsMap = TestAssessmentUtil.getAssessmentDefinitionItemsByNames(
            def.Id,
            new Set<String>{'C19_Symptom_Screen1', 'C19_No_Action'});

        Assessment_Definition_Item__c currentItem = itemsMap.get('C19_Symptom_Screen1');
        Assessment_Definition_Item__c expectedItem = itemsMap.get('C19_No_Action');
        System.assertNotEquals(null, currentItem);
        System.assertNotEquals(null, expectedItem);

        Map<String, Assessment_Definition_Signal__c> signalsMap = TestAssessmentUtil.getAssessmentDefinitionSignalsByNames(
            def.Id,
            new Set<String>{'NoFever', 'Non-Symptomatic'});

        Test.startTest();

        AssessmentEvaluateItemRequest req = new AssessmentEvaluateItemRequest();
        req.assessmentSessionId = sess.Id;
        req.assessmentItemId = currentItem.Id;
        req.responseText = 'Normal';

        AssessmentService service = new AssessmentServiceImpl();
        AssessmentEvaluateItemResponse evaluateItemResponse = service.evaluateItemResponse(req);
        Test.stopTest();

        System.assertEquals(expectedItem.Id, evaluateItemResponse.nextAssessmentItemId);
        TestAssessmentUtil.assertAssessmentSessionSignals(sess.Id, new Set<String>{
            signalsMap.get('NoFever').Id});
    }

    @isTest
    static void testEvaluateChoiceResponse() {
        Assessment_Definition__c def = TestAssessmentUtil.createTestAssessmentDefinition();
        Assessment_Session__c sess = TestAssessmentUtil.createAssessmentSession(def.Id, 'In Progress');
        System.assertNotEquals(null, sess);

        Map<String, Assessment_Definition_Item__c> itemsMap = TestAssessmentUtil.getAssessmentDefinitionItemsByNames(
            def.Id,
            new Set<String>{'C19_Symptom_Screen1'});

        Assessment_Definition_Item__c currentItem = itemsMap.get('C19_Symptom_Screen1');
        System.assertNotEquals(null, currentItem);

        AssessmentService service = new AssessmentServiceImpl();

        AssessmentItemChoice selectedChoice = new AssessmentItemChoice();
        selectedChoice.label = 'test label';
        selectedChoice.value = 'test value';

        AssessmentEvaluateChoiceRequest req = new AssessmentEvaluateChoiceRequest();
        req.assessmentSessionId = sess.Id;
        req.assessmentItemId = currentItem.Id;
        req.choiceObject = selectedChoice;
        AssessmentEvaluateChoiceResponse res = service.evaluateChoiceResponse(req);
        System.assertEquals('test value', res.textResponse);
    }

}
