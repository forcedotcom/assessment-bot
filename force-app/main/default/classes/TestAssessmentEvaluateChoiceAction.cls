@isTest
private with sharing class TestAssessmentEvaluateChoiceAction {

    @isTest
    static void testAction() {

        Assessment_Definition__c def = TestAssessmentUtil.createTestAssessmentDefinition();
        Assessment_Session__c sess = TestAssessmentUtil.createAssessmentSession(def.Id, 'In Progress');
        System.assertNotEquals(null, sess);

        Map<String, Assessment_Definition_Item__c> itemsMap = TestAssessmentUtil.getAssessmentDefinitionItemsByNames(
            def.Id,
            new Set<String>{'C19_Symptom_Screen1'});

        Assessment_Definition_Item__c currentItem = itemsMap.get('C19_Symptom_Screen1');
        System.assertNotEquals(null, currentItem);


        Test.startTest();

            AssessmentItemChoice selectedChoice = new AssessmentItemChoice();
            selectedChoice.label = 'test label';
            selectedChoice.value = 'test value';

            AssessmentEvaluateChoiceRequest req = new AssessmentEvaluateChoiceRequest();
            req.assessmentSessionId = sess.Id;
            req.assessmentItemId = currentItem.Id;
            req.choiceObject = selectedChoice;

            List<AssessmentEvaluateChoiceResponse> resp = AssessmentEvaluateChoiceAction.evaluateChoiceResponse(new List<AssessmentEvaluateChoiceRequest>{req});
            System.assertEquals(1, resp.size());

        Test.stopTest();

    }

}
