public with sharing class AssessmentDefinitionPreviewExtension {

    private final Assessment_Definition__c def;
    public String orgId{get; private set;}
    public String orgUrl{get; private set;}
    public String laEndpoint{get; private set;}
    public String deploymentId{get; private set;}
	public String buttonId{get; private set;}
    public String communityURL{get; private set;}
    public String laContentEndpoint{get; private set;}
    public String eswLiveAgentDevName{get; private set;}
    public String embeddedServiceDevName{get;private set;}
    
    public AssessmentDefinitionPreviewExtension(ApexPages.StandardController con) {
        this.def = (Assessment_Definition__c)con.getRecord();
        initParams();
    }

    private void initParams() {
        Assessment_Settings__c settings = Assessment_Settings__c.getInstance();
        AssessmentDefinitionPreviewExtension.WithoutSharingOps wsops = new AssessmentDefinitionPreviewExtension.WithoutSharingOps();
        this.orgId = UserInfo.getOrganizationId().substring(0, 15);
        this.orgUrl = URL.getOrgDomainUrl().toExternalForm();
        this.buttonId = wsops.getPreviewButtonId(settings.Chat_Button_Name__c);
        this.deploymentId = wsops.getPreviewDeploymentId(settings.Chat_Deployment_Name__c);
        this.communityURL = settings.Community_URL__c;
        this.laEndpoint = settings.Live_Agent_URL__c;
        this.laContentEndpoint = settings.Live_Agent_Content_URL__c;
        this.eswLiveAgentDevName = settings.ESW_Live_Agent_Dev_Name__c;
        this.embeddedServiceDevName = settings.ESW_Deployment_Dev_Name__c;
    }

    private without sharing class WithoutSharingOps {	

        public String getPreviewButtonId(String assessmentButtonName) {	
            List<SObject> chatButtons = Database.query('select id from LiveChatButton where DeveloperName = :assessmentButtonName');
            if (chatButtons != null && !chatButtons.isEmpty()) {
                String buttonId = chatButtons.get(0).Id;
                return buttonId.substring(0, 15);
            } else {
                return null;
            }
        }

        public String getPreviewDeploymentId(String assessmentDeploymentName) {	
            List<SObject> chatDeployments = Database.query('select id from LiveChatDeployment where DeveloperName = :assessmentDeploymentName');
            if (chatDeployments != null && !chatDeployments.isEmpty()) {
                String depId = chatDeployments.get(0).Id;
                return depId.substring(0, 15);
            } else {
                return null;
            }
        }

    }
}