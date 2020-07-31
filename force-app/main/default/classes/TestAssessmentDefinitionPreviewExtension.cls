@isTest
private with sharing class TestAssessmentDefinitionPreviewExtension {

    @isTest
    static void testExtension() {

        Assessment_Settings__c settings = new Assessment_Settings__c();
        settings.Live_Agent_URL__c = 'live agent url';
        settings.ESW_Channel_Menu_Name__c = 'esw live agent dev name';
        insert settings;

        Assessment_Definition__c def = TestAssessmentUtil.createTestAssessmentDefinition();

        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(def);
        AssessmentDefinitionPreviewExtension ext = new AssessmentDefinitionPreviewExtension(sc);

        System.assertEquals('live agent url', ext.laEndpoint);
        System.assertEquals('esw live agent dev name', ext.eswChannelMenuName);
        System.assertNotEquals(null, ext.orgId);
        System.assertNotEquals(null, ext.orgUrl);

        Test.stopTest();

    }

}
