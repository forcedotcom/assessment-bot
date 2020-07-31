public with sharing class AssessmentDefinitionPreviewExtension {

    private final Assessment_Definition__c def;
    public String orgId{get; private set;}
    public String orgUrl{get; private set;}
    public String laEndpoint{get; private set;}
    public String eswChannelMenuName{get; private set;}

    public AssessmentDefinitionPreviewExtension(ApexPages.StandardController con) {
        this.def = (Assessment_Definition__c)con.getRecord();
        initParams();
    }

    private void initParams() {
        Assessment_Settings__c settings = Assessment_Settings__c.getInstance();
        this.orgId = UserInfo.getOrganizationId().substring(0, 15);
        this.orgUrl = URL.getOrgDomainUrl().toExternalForm();
        this.laEndpoint = settings.Live_Agent_URL__c;
        this.eswChannelMenuName = settings.ESW_Channel_Menu_Name__c;
    }

}

