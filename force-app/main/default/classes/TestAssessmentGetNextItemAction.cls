@isTest
private with sharing class TestAssessmentGetNextItemAction {

    @isTest
    static void testAction() {

        Assessment_Definition__c def = TestAssessmentUtil.createTestAssessmentDefinition();
        Assessment_Session__c sess = TestAssessmentUtil.createAssessmentSession(def.Id, 'In Progress');
        System.assertNotEquals(null, sess);

        Map<String, Assessment_Definition_Item__c> itemsMap = TestAssessmentUtil.getAssessmentDefinitionItemsByNames(
            def.Id,
            new Set<String>{'C19_No_Consent'});

        Assessment_Definition_Item__c currentItem = itemsMap.get('C19_No_Consent');
        System.assertNotEquals(null, currentItem);


        Test.startTest();

            AssessmentNextItemRequest req = new AssessmentNextItemRequest();
            req.assessmentSessionId = sess.Id;
            req.assessmentItemId = currentItem.Id;

            List<AssessmentNextItemResponse> resp = AssessmentGetNextItemAction.getNextAssessmentAction(new List<AssessmentNextItemRequest>{req});
            System.assertEquals(1, resp.size());

        Test.stopTest();

    }

}
