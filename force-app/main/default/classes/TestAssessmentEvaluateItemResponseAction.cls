@isTest
private with sharing class TestAssessmentEvaluateItemResponseAction {

    @isTest
    static void testAction() {

        Assessment_Definition__c def = TestAssessmentUtil.createTestAssessmentDefinition();
        Assessment_Session__c sess = TestAssessmentUtil.createAssessmentSession(def.Id, 'In Progress');
        System.assertNotEquals(null, sess);

        Map<String, Assessment_Definition_Item__c> itemsMap = TestAssessmentUtil.getAssessmentDefinitionItemsByNames(
            def.Id,
            new Set<String>{'C19_Consent', 'C19_No_Consent'});

        Assessment_Definition_Item__c currentItem = itemsMap.get('C19_Consent');
        System.assertNotEquals(null, currentItem);


        Test.startTest();

            AssessmentEvaluateItemRequest req = new AssessmentEvaluateItemRequest();
            req.assessmentSessionId = sess.Id;
            req.assessmentItemId = currentItem.Id;
            req.responseTrueOrFalse = false;

            List<AssessmentEvaluateItemResponse> resp = AssessmentEvaluateItemResponseAction.evaluateItemResponse(new List<AssessmentEvaluateItemRequest>{req});
            System.assertEquals(1, resp.size());

        Test.stopTest();

    }

}
