@isTest
private with sharing class TestAssessmentSessionBatchUpdateService {

    public static String CRON_EXP = '0 0 0 15 3 ? 2024';

    @isTest
    static void testAssessmentSessionBatchUpdateService() {

        Assessment_Definition__c def = createTestAssessmentDefinitionWitSessions();
        
        Test.startTest();
            AssessmentSessionBatchUpdateService batchJob = new AssessmentSessionBatchUpdateService();
            Database.executeBatch(batchJob);
        Test.stopTest();

        assertProcessedSessions(def);

    }

    @isTest
    static void testAssessmentSessionBatchUpdateServiceWithValidTranscript() {
        String lct1Id = createLiveChatTranscript();
        Assessment_Definition__c def = createTestAssessmentDefinitionWitSessions();
        Assessment_Session__c sess6 = TestAssessmentUtil.createAssessmentSession(def.Id, 'Completed', lct1Id);

        Test.startTest();
            AssessmentSessionBatchUpdateService batchJob = new AssessmentSessionBatchUpdateService();
            Database.executeBatch(batchJob);
        Test.stopTest();

        assertProcessedSessions(def);
    }

    @isTest
    static void testAssessmentSessionBatchUpdateScheduledJob() {

        Assessment_Definition__c def = createTestAssessmentDefinitionWitSessions();

        Test.startTest();
            String jobId = System.schedule('ScheduledApexTest', CRON_EXP, new AssessmentScheduledActions());
        Test.stopTest();

    }

    private static Assessment_Definition__c createTestAssessmentDefinitionWitSessions() {
        Assessment_Definition__c def = TestAssessmentUtil.createTestAssessmentDefinition();
        Assessment_Session__c sess1 = TestAssessmentUtil.createAssessmentSession(def.Id, 'In Progress');
        Assessment_Session__c sess2 = TestAssessmentUtil.createAssessmentSession(def.Id, 'Completed');
        Assessment_Session__c sess3 = TestAssessmentUtil.createAssessmentSession(def.Id, 'Completed');
        Assessment_Session__c sess4 = TestAssessmentUtil.createAssessmentSession(def.Id, 'Completed', 'some-chat-key');
        Assessment_Session__c sess5 = TestAssessmentUtil.createAssessmentSession(def.Id, 'Completed', '5708A000000JHFCQA4');
        return def;
    }

    private static void assertProcessedSessions(Assessment_Definition__c def) {
        List<Assessment_Session__c> sessions = TestAssessmentUtil.getAssessmentSessionsByDefinitionIds(new Set<Id>{def.Id});
        for (Assessment_Session__c s : sessions) {
            if (s.Status__c == 'Completed') {
                System.assertEquals(true, s.Processed__c);
            } else {
                System.assertEquals(false, s.Processed__c);
            }
        }
    }

    private static String createLiveChatTranscript() {
        LiveChatVisitor lcv = new LiveChatVisitor();
        try {
            insert lcv;
        } catch(Exception e){}

        LiveChatTranscript lct = new LiveChatTranscript();
        lct.LiveChatVisitorid = lcv.id;
        try{
            insert lct;
        } catch(Exception e){}
        return lct.Id;
    }

}
