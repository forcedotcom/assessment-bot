global with sharing class AssessmentSessionBatchUpdateService implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id, Status__c, Source_Transcript_Id__c, CreatedDate,' +
            'Processed__c, Source_Transcript_Deletion_Error__c, Source_Transcript_Deletion_Status__c,' +
            'Assessment_Definition__c, Assessment_Definition__r.Delete_Transcript_on_Completion__c' +
            ' FROM Assessment_Session__c' + 
            ' WHERE Processed__c = false LIMIT 10000'
        );
    }

    global void execute(Database.BatchableContext bc, List<Assessment_Session__c> scope){
        Map<Schema.SObjectType, Set<Id>> schemaTypeToIdMap = new Map<Schema.SObjectType, Set<Id>>();
        Map<Id, Assessment_Session__c> transcriptIdToSessionMap = new Map<Id, Assessment_Session__c>();
        Map<String, Assessment_Session__c> chatKeyToSessionMap = new Map<String, Assessment_Session__c>();
        
        for (Assessment_Session__c session : scope) {
            if (session.Status__c == AssessmentConstants.SESSION_COMPLETED_STATUS) {
                session.Processed__c = true;
            } else {
                if (session.CreatedDate <= DateTime.now().addHours(-2)) {
                    session.Status__c = AssessmentConstants.SESSION_ABANDONED_STATUS;
                    session.Processed__c = true;
                }
            }

            if (session.Processed__c) {
                if (session.Source_Transcript_Id__c != null && session.Assessment_Definition__r.Delete_Transcript_on_Completion__c) {
                    if (isId(session.Source_Transcript_Id__c)) {
                        Id transcriptRecordId = (Id)session.Source_Transcript_Id__c;
                        Schema.SObjectType transcriptSObjectType = transcriptRecordId.getSobjectType();
                        if(!schemaTypeToIdMap.containsKey(transcriptSObjectType)){
                            schemaTypeToIdMap.put(transcriptSObjectType, new Set<Id>());
                        }
                        schemaTypeToIdMap.get(transcriptSObjectType).add(transcriptRecordId);
                        transcriptIdToSessionMap.put(transcriptRecordId, session);
                    } else {
                        chatKeyToSessionMap.put(session.Source_Transcript_Id__c, session);
                    }
                }
            }
        }

        System.debug('sobject type map with valid transcript ids : '+schemaTypeToIdMap.size());
        if (!chatKeyToSessionMap.isEmpty()) {
            Map<String, Id> chatKeysToIdsMap = getLiveChatTranscriptsByChatKey(chatKeyToSessionMap.keySet());
            if (!chatKeysToIdsMap.isEmpty()) {
                Set<Id> convertedIds = new Set<Id>();
                for (String chatKey : chatKeysToIdsMap.keySet()) {
                    Id transcriptRecordId = chatKeysToIdsMap.get(chatKey);
                    if (transcriptRecordId == null) continue;
                    Assessment_Session__c sessionRecord = chatKeyToSessionMap.get(chatKey);
                    if (sessionRecord == null) continue;
                    transcriptIdToSessionMap.put(transcriptRecordId, sessionRecord);
                    convertedIds.add(transcriptRecordId);
                }
                if (!convertedIds.isEmpty()) {
                    Id sampleId = null;
                    for (Id i : convertedIds) {
                        sampleId = i;
                        break;
                    }
                    Schema.SObjectType transcriptSObjectType = sampleId.getSobjectType();
                    if(!schemaTypeToIdMap.containsKey(transcriptSObjectType)){
                        schemaTypeToIdMap.put(transcriptSObjectType, new Set<Id>());
                    }
                    schemaTypeToIdMap.get(transcriptSObjectType).addAll(convertedIds);
                }
            }
        }

        System.debug('sobject type map after resolving chat keys : '+schemaTypeToIdMap.size());

        for (Schema.SObjectType sobjectType : schemaTypeToIdMap.keySet()) {
            Map<Id, String> deleteResults = deleteRecords(sobjectType, schemaTypeToIdMap.get(sobjectType));
            for(Id transcriptRecordId : deleteResults.keySet()) {
                Assessment_Session__c sessionRecord = transcriptIdToSessionMap.get(transcriptRecordId);
                if (sessionRecord == null) continue;
                String errorMessage = deleteResults.get(transcriptRecordId);
                if (errorMessage == null) {
                    sessionRecord.Source_Transcript_Deletion_Status__c = 'Completed';
                } else {
                    sessionRecord.Source_Transcript_Deletion_Status__c = 'Error';
                    sessionRecord.Source_Transcript_Deletion_Error__c = errorMessage;
                }
            }
        }

        update scope;
    }

    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }

    private Boolean isId(String stringValue) {
        return stringValue InstanceOf Id;
    }

    private Map<String, Id> getLiveChatTranscriptsByChatKey(Set<String> chatKeys) {
        Map<String, Id> results = new Map<String, Id>();
        if (chatKeys == null || chatKeys.isEmpty()) return results;

        List<SObject> records = Database.query('select Id,ChatKey from LiveChatTranscript where Source_Assessment_Definition__c != null AND ChatKey in :chatKeys');
        for (SObject r : records) {
            results.put((String)r.get('ChatKey'), r.Id);
        }
        return results;
    }

    private Map<Id, String> deleteRecords(Schema.SObjectType sobjectType, Set<Id> toDeleteIds) {
        Map<Id, String> delResults = new Map<Id, String>();
        if (toDeleteIds == null || toDeleteIds.isEmpty()) return delResults;

        List<SObject> records = new List<SObject>();
        for (Id delId : toDeleteIds) {
            Sobject so = sobjectType.newSObject();
            so.id = delId;
            records.add(so);
        }

        System.debug('deleting '+records.size()+' records');
        Database.DeleteResult[] drList = Database.delete(records, false);
        for(Database.DeleteResult dr : drList) {
            if (!dr.isSuccess()) {
                String errorMsg = dr.getErrors() != null ? dr.getErrors()[0].getMessage() : null;
                errorMsg = errorMsg == null ? 'unknown' : errorMsg.left(255);
                delResults.put(dr.id, errorMsg);
            } else {
                delResults.put(dr.id, null);
            }
        }
        return delResults;
    }

}
