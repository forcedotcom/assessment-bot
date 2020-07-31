@isTest
private with sharing class TestAssessmentDefinitionImportExportCtrl {

    @isTest
    static void testExport() {
        Assessment_Definition__c def = TestAssessmentUtil.createTestAssessmentDefinition();

        Test.startTest();
            String exportJson = AssessmentDefinitionImportExportService.exportDefinition(def.Assessment_Definition_Id__c);
            Map<String, Object> objMap = (Map<String, Object>)JSON.deserializeUntyped(exportJson);
            System.assertEquals((String)def.Id, (String)objMap.get('Id'));
        Test.stopTest();
    }

    @isTest
    static void testImport() {
        Assessment_Definition__c def = TestAssessmentUtil.createTestAssessmentDefinition();
        String exportJson = AssessmentDefinitionImportExportService.exportDefinition(def.Assessment_Definition_Id__c);
        Map<String, Object> objMap = (Map<String, Object>)JSON.deserializeUntyped(exportJson);
        System.assertEquals((String)def.Id, (String)objMap.get('Id'));
        objMap.put('Assessment_Definition_Id__c',  def.Assessment_Definition_Id__c+'Copy');
        objMap.put('Name', def.Name+'Copy');
        List<SelectOption> opts = AssessmentDefinitionImportExportService.getDefinitionOptions();
        System.assertEquals(1, opts.size());

        Test.startTest();
            AssessmentDefinitionImportExportService.importDefinition(JSON.serialize(objMap));
            opts = AssessmentDefinitionImportExportService.getDefinitionOptions();
            System.assertEquals(2, opts.size());
        Test.stopTest();
    }

}
