public with sharing class AssessmentDefinitionImportExportCtrl {

    public transient String exportJSON{get; set;}
    public transient String importJSON{get; set;}
    public String selectedDefinition{get;set;}
    
    public AssessmentDefinitionImportExportCtrl() {}
    
    public PageReference doImport() {
        try {
            AssessmentDefinitionImportExportService.importDefinition(importJSON);
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Asssessment Successfully Imported'));
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }
        return null;
    }

    public PageReference doExport() {
        try {
            exportJSON = AssessmentDefinitionImportExportService.exportDefinition(selectedDefinition);
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Asssessment Successfully Exported'));
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }
        return null;
    }

    public List<SelectOption> getDefinitions() {
        return AssessmentDefinitionImportExportService.getDefinitionOptions();
    }

}