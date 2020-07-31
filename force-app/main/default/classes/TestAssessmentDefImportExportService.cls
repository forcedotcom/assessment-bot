@isTest
private with sharing class TestAssessmentDefImportExportService {

    @isTest
    static void testExport() {
        Assessment_Definition__c def = TestAssessmentUtil.createTestAssessmentDefinition();

        Test.startTest();
            AssessmentDefinitionImportExportCtrl ctrl = new AssessmentDefinitionImportExportCtrl();
            ctrl.selectedDefinition = def.Assessment_Definition_Id__c;
            ctrl.doExport();
            Map<String, Object> objMap = (Map<String, Object>)JSON.deserializeUntyped(ctrl.exportJSON);
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

        Test.startTest();
            AssessmentDefinitionImportExportCtrl ctrl = new AssessmentDefinitionImportExportCtrl();
            List<SelectOption> opts = ctrl.getDefinitions();
            System.assertEquals(1, opts.size());
            ctrl.importJSON = JSON.serialize(objMap);
            ctrl.doImport();
            opts = ctrl.getDefinitions();
            System.assertEquals(2, opts.size());
        Test.stopTest();
    }

}
