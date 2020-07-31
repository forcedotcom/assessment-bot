@isTest
private with sharing class TestAssessmentGetInitialItemAction {

    @isTest
    static void testAction() {

        Assessment_Definition__c def = TestAssessmentUtil.createTestAssessmentDefinition();

        Test.startTest();

            AssessmentInitialItemRequest initialItemRequest = new AssessmentInitialItemRequest();
            initialItemRequest.assessmentDefinitionId = def.Assessment_Definition_Id__c;
            List<AssessmentInitialItemResponse> resp = AssessmentGetInitialItemAction.getInitalAssessmentAction(new List<AssessmentInitialItemRequest>{initialItemRequest});
            System.assertEquals(1, resp.size());

        Test.stopTest();

    }

}
