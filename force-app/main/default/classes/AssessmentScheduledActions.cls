global with sharing class AssessmentScheduledActions implements Schedulable {

    global void execute(SchedulableContext SC) {
        AssessmentSessionBatchUpdateService batchJob = new AssessmentSessionBatchUpdateService();
        Database.executeBatch(batchJob);
    }

}
