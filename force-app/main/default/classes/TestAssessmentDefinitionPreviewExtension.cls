@isTest
private with sharing class TestAssessmentDefinitionPreviewExtension {

    @isTest
    static void testExtension() {

        Assessment_Settings__c settings = new Assessment_Settings__c();
        settings.Live_Agent_URL__c = 'live agent url';
        settings.Live_Agent_Content_URL__c = 'live agent content url';
        settings.Chat_Button_Name__c = 'button dev name';
        settings.Chat_Deployment_Name__c = 'deployment dev name';
        settings.ESW_Live_Agent_Dev_Name__c = 'esw live agent dev name';
        settings.Community_URL__c = 'community url';
        settings.ESW_Deployment_Dev_Name__c = 'esw deployment dev name';
        insert settings;

        Assessment_Definition__c def = TestAssessmentUtil.createTestAssessmentDefinition();

        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(def);
        AssessmentDefinitionPreviewExtension ext = new AssessmentDefinitionPreviewExtension(sc);

        System.assertEquals('live agent url', ext.laEndpoint);
        System.assertEquals('esw deployment dev name', ext.embeddedServiceDevName);
        System.assertEquals('community url', ext.communityURL);
        System.assertEquals('live agent content url', ext.laContentEndpoint);
        System.assertEquals('esw live agent dev name', ext.eswLiveAgentDevName);
        System.assertNotEquals(null, ext.orgId);
        System.assertNotEquals(null, ext.orgUrl);

        Test.stopTest();

    }

}
