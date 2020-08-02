global with sharing class AssessmentServiceImpl implements AssessmentService {

    global AssessmentInitialItemResponse getInitialItemResponse(AssessmentInitialItemRequest request) {
        AssessmentInitialItemResponse response = new AssessmentInitialItemResponse();

        AssessmentServiceImpl.WithoutSharingOps wsops = new AssessmentServiceImpl.WithoutSharingOps();

        List<Assessment_Definition__c> definitions = new List<Assessment_Definition__c>();
        
        String routableItemId = request.routableItemId != null ? request.routableItemId : request.chatKey;

        if (request.assessmentDefinitionId == null) {
            // If no assessment definition is present, resolve definition based on assessment deployment records
            Map<String, String> channelDeploymentInfo = wsops.getDeploymetInfoForRoutableId(routableItemId);
            if (channelDeploymentInfo != null) {
                request.assessmentDefinitionId = wsops.getAssessmentDefinitionForDeploymentInfo(channelDeploymentInfo);
            }
        }

        if (request.assessmentDefinitionId != null) {
            definitions = wsops.getAssessmentDefinitionsByUniqueName(new List<String>{request.assessmentDefinitionId});
        }

        if (definitions.isEmpty()) return response;
        
        Assessment_Definition__c assessmentDefinition = definitions.get(0);
        response.isActive = assessmentDefinition.Active__c;

        List<Assessment_Definition_Item__c> initialItems = null;
        if (assessmentDefinition.Initial_Item_Name__c != null) {
            initialItems = wsops.getAssessmentDefinitionItemByNames(new Set<String>{assessmentDefinition.Initial_Item_Name__c}, assessmentDefinition.Id);
        }

        Assessment_Definition_Item__c initialItem = null;
        if (initialItems != null) {
            initialItem = initialItems.get(0);
        }

        if (initialItem != null) {
            response.initalAssessmentItemId = initialItem.Id;
            Assessment_Session__c session = wsops.createAssessmentSession(assessmentDefinition.Id, routableItemId);
            response.assessmentSessionId = session.Id;
        }

        return response;
    }
    
    global AssessmentNextItemResponse getNextItemResponse(AssessmentNextItemRequest request) {
        AssessmentNextItemResponse response = new AssessmentNextItemResponse();

        AssessmentServiceImpl.WithoutSharingOps wsops = new AssessmentServiceImpl.WithoutSharingOps();

        List<Assessment_Definition_Item__c> items = wsops.getAssessmentDefinitionItemByIds(new List<Id>{request.assessmentItemId});

        if (items.isEmpty()) return response;
        
        Assessment_Definition_Item__c currentItem = items.get(0);
        response.type = currentItem.Type__c;
        response.message = currentItem.Message__c;
        response.answerType = currentItem.Question_Type__c;
        response.assessmentItemId = currentItem.Id;
        response.transferType = currentItem.Transfer_Type__c;

        if (currentItem.Type__c == AssessmentConstants.ITEM_TYPE_TRANSFER) {
            String targetId = wsops.getTransferTargetId(currentItem.Transfer_Type__c, currentItem.Transfer_Target_Name__c);
            if (currentItem.Transfer_Type__c == AssessmentConstants.TRANSFER_TYPE_QUEUE) {
                response.transferQueueId = targetId;
            } else if (currentItem.Transfer_Type__c == AssessmentConstants.TRANSFER_TYPE_BOT) {
                response.transferBotId = targetId;
            } else if (currentItem.Transfer_Type__c == AssessmentConstants.TRANSFER_TYPE_ASSESSMENT) {
                response.transferAssessmentId = targetId;
            }
        }

        if (currentItem.Type__c == AssessmentConstants.ITEM_TYPE_DECISION) {

            Set<String> nextAssessmentItems = new Set<String>{
                currentItem.Next_Item_Name__c,
                currentItem.Next_Item_Name_Other_Outcome__c};
            nextAssessmentItems.remove(null);
            
            Map<String, Assessment_Definition_Item__c> nextItemsMap = new Map<String, Assessment_Definition_Item__c>();
            if (!nextAssessmentItems.isEmpty()) {
                List<Assessment_Definition_Item__c> nextItems = wsops.getAssessmentDefinitionItemByNames(nextAssessmentItems, currentItem.Assessment_Definition__c);
                for(Assessment_Definition_Item__c nextItem : nextItems) {
                    nextItemsMap.put(nextItem.Name, nextItem);
                }
            }

            Assessment_Definition_Item__c defaultSuccesNextItem = nextItemsMap.get(currentItem.Next_Item_Name__c);
            Assessment_Definition_Item__c defaultFailureNextItem = nextItemsMap.get(currentItem.Next_Item_Name_Other_Outcome__c);
            String defaultSuccessNextItemId = defaultSuccesNextItem != null ? defaultSuccesNextItem.Id : null;
            String defaultFailureNextItemId = defaultFailureNextItem != null ? defaultFailureNextItem.Id : null;

            List<Assessment_Definition_Decision_Signal__c> decisionSignals = currentItem.Assessment_Definition_Decision_Signals__r;
            if (decisionSignals != null && !decisionSignals.isEmpty()) {
                Map<Integer, Id> signalOrderToIdMap = new Map<Integer, Id>();
                for (Assessment_Definition_Decision_Signal__c ds : currentItem.Assessment_Definition_Decision_Signals__r) {
                    signalOrderToIdMap.put((Integer)ds.Order__c, ds.Assessment_Definition_Signal__c);
                }
                Set<Id> currentSessionSignals = wsops.getAssessmentSessionSignals(request.assessmentSessionId);

                // For decision items, the conditonal value becomes the condition and valid values at the moment are 'AND' and 'OR' if null, then default ot 'AND'
                String conditionalLogic = currentItem.Next_Item_Outcome_Condition__c != null ? currentItem.Next_Item_Outcome_Condition__c.trim() : null;
                String conditionalLogicType = conditionalLogic == null || conditionalLogic == AssessmentConstants.AND_DECISION ? AssessmentConstants.AND_DECISION : AssessmentConstants.OR_DECISION;

                Boolean evaluationResult = true;
                for (Integer decisionItemOrder : signalOrderToIdMap.keySet()) {
                    String signalId = signalOrderToIdMap.get(decisionItemOrder);
                    if (conditionalLogicType == AssessmentConstants.AND_DECISION) {
                        if (!currentSessionSignals.contains(signalId)) {
                            evaluationResult = false;
                            break;
                        }
                    } else {
                        if (currentSessionSignals.contains(signalId)) break;
                    }
                }

                Assessment_Definition_Item__c nextItem = evaluationResult ? defaultSuccesNextItem : defaultFailureNextItem;
                response.assessmentItemId = evaluationResult ? defaultSuccessNextItemId : defaultFailureNextItemId;

                if (nextItem != null){
                    if (nextItem.Type__c == AssessmentConstants.ITEM_TYPE_DECISION) {
                        // If next item is another decision, recursively call getNextItem
                        request.assessmentItemId = response.assessmentItemId;
                        response = getNextItemResponse(request);
                    } else {
                        response.type = nextItem.Type__c;
                        response.message = nextItem.Message__c;
                        response.answerType = nextItem.Question_Type__c;
                    }
                    List<Assessment_Definition_Item__c> nextItems = wsops.getAssessmentDefinitionItemByIds(new List<Id>{nextItem.Id}) ;
                    if (nextItems != null && !nextItems.isEmpty()) {
                        currentItem = nextItems.get(0);
                    }
                }
            } else {
                response.assessmentItemId = defaultSuccessNextItemId;
            }
            response.choices = new List<AssessmentItemChoice>();
        } else {
            if (currentItem.Assessment_Definition_Item_Choices__r != null) {
                List<AssessmentItemChoice> choices = new List<AssessmentItemChoice>();
                for (Assessment_Definition_Item_Choice__c choice : currentItem.Assessment_Definition_Item_Choices__r) {
                    AssessmentItemChoice ac =new AssessmentItemChoice();
                    ac.label = choice.Label__c;
                    ac.value = choice.Value__c;
                    choices.add(ac);
                }
                response.choices = choices;
            }
        }

        Map<String, Set<Id>> itemEventSignalIdsByTypeMap = getItemEventSignalIdsByTypeMap(currentItem.Assessment_Definition_Item_Events__r);
        Set<Id> onEntrySignals = itemEventSignalIdsByTypeMap.get(AssessmentConstants.EVENT_TYPE_ON_ENTRY);

        Boolean isFinalItem = currentItem.Next_Item_Name__c == null && currentItem.Next_Item_Name_Other_Outcome__c == null;
        String updateStatus = isFinalItem ? AssessmentConstants.SESSION_COMPLETED_STATUS : null;
        wsops.updateAssessmentSession(request.assessmentSessionId, updateStatus, onEntrySignals, currentItem.Id);

        return response;
    }

    global AssessmentEvaluateItemResponse evaluateItemResponse(AssessmentEvaluateItemRequest request) {
        AssessmentEvaluateItemResponse response = new AssessmentEvaluateItemResponse();

        AssessmentServiceImpl.WithoutSharingOps wsops = new AssessmentServiceImpl.WithoutSharingOps();

        List<Assessment_Definition_Item__c> items = wsops.getAssessmentDefinitionItemByIds(new List<Id>{request.assessmentItemId});

        if (items.isEmpty()) return response;

        Assessment_Definition_Item__c currentItem= items.get(0);
        
        Set<String> nextAssessmentItems = new Set<String>();
        nextAssessmentItems.add(currentItem.Next_Item_Name__c);
        nextAssessmentItems.add(currentItem.Next_Item_Name_Other_Outcome__c);

        Map<String, Assessment_Definition_Item_Choice__c> choiceNextItemMap = new Map<String, Assessment_Definition_Item_Choice__c>();
        if (currentItem.Assessment_Definition_Item_Choices__r != null) {
            for (Assessment_Definition_Item_Choice__c choice : currentItem.Assessment_Definition_Item_Choices__r) {
                choiceNextItemMap.put(choice.Value__c, choice);
                if(choice.Next_Item_Name__c != null) {
                    nextAssessmentItems.add(choice.Next_Item_Name__c);
                }
            }
        }
        nextAssessmentItems.remove(null);

        String conditionalValue = currentItem.Next_Item_Outcome_Condition__c != null ? currentItem.Next_Item_Outcome_Condition__c.trim() : null;
        String conditionalOperator = currentItem.Next_Item_Condition_Operator__c;
        String questionType = currentItem.Question_Type__c;
        String userResponse = getUserResponseAsString(questionType, request);

        Assessment_Definition_Item_Choice__c nextItemChoiceMatch = questionType == AssessmentConstants.QUESTION_TYPE_CHOICES ? choiceNextItemMap.get(userResponse) : null;

        Set<Id> newSessionSignalIds = new Set<Id>();

        if (!nextAssessmentItems.isEmpty()) {

            Map<String, Assessment_Definition_Item__c> nextItemsMap = new Map<String, Assessment_Definition_Item__c>();
            List<Assessment_Definition_Item__c> nextItems = wsops.getAssessmentDefinitionItemByNames(nextAssessmentItems, currentItem.Assessment_Definition__c);

            for(Assessment_Definition_Item__c nextItem : nextItems) {
                nextItemsMap.put(nextItem.Name, nextItem);
            }

            Assessment_Definition_Item__c defaultSuccesNextItem = nextItemsMap.get(currentItem.Next_Item_Name__c);
            Assessment_Definition_Item__c defaultFailureNextItem = nextItemsMap.get(currentItem.Next_Item_Name_Other_Outcome__c);
            
            String defaultSuccessNextItemId = defaultSuccesNextItem != null ? defaultSuccesNextItem.Id : null;
            String defaultFailureNextItemId = defaultFailureNextItem != null ? defaultFailureNextItem.Id : null;

            System.debug('default success next item : '+defaultSuccessNextItemId);
            System.debug('default failure next item : '+defaultFailureNextItemId);

            String nextAssessmentItemIdOverride = null;
            if (nextItemChoiceMatch != null) {
                newSessionSignalIds.add(nextItemChoiceMatch.Assessment_Definition_Signal__c);
                System.debug('has choice match, next item override : '+nextItemChoiceMatch.Next_Item_Name__c);
                Assessment_Definition_Item__c overrideSuccesNextItem = nextItemsMap.get(nextItemChoiceMatch.Next_Item_Name__c);
                nextAssessmentItemIdOverride = overrideSuccesNextItem != null ? overrideSuccesNextItem.Id : null;
            }

            if (conditionalValue == null && questionType == AssessmentConstants.QUESTION_TYPE_TRUEFALSE) {
                // If there is no conditional value for a true/false question
                // still evaluate for a true condition in case signal events are attached
                conditionalOperator = AssessmentConstants.OPERATOR_EQUAL_TO;
                conditionalValue = 'true';
                // If no conditional value was specified do not end session if no other outcome name is specified
                // just continue with the default success next item
                if (defaultSuccessNextItemId != null && defaultFailureNextItemId == null) {
                    defaultFailureNextItemId = defaultSuccessNextItemId;
                }
            }

            if (nextAssessmentItemIdOverride != null) {
                response.nextAssessmentItemId = nextAssessmentItemIdOverride != null ? nextAssessmentItemIdOverride : defaultSuccessNextItemId;
            } else if (conditionalValue != null) {

                Map<String, Set<Id>> itemEventSignalIdsByTypeMap = getItemEventSignalIdsByTypeMap(currentItem.Assessment_Definition_Item_Events__r);

                Set<Id> onSuccessSignals = itemEventSignalIdsByTypeMap.get(AssessmentConstants.EVENT_TYPE_ON_TRUE);
                Set<Id> onFailureSignals = itemEventSignalIdsByTypeMap.get(AssessmentConstants.EVENT_TYPE_ON_FALSE);

                Boolean evaluationResult = evaluateCondition(userResponse, questionType, conditionalOperator, conditionalValue) ;
                response.nextAssessmentItemId = evaluationResult ? defaultSuccessNextItemId : defaultFailureNextItemId;

                if (evaluationResult) {
                    if (onSuccessSignals != null) {
                        newSessionSignalIds.addAll(onSuccessSignals);
                    }
                } else {
                    if (onFailureSignals != null) {
                        newSessionSignalIds.addAll(onFailureSignals);
                    }
                }
            } else { 
                response.nextAssessmentItemId = defaultSuccessNextItemId;
            }

        } else {
            // Check if there are any potential last signals present for a choice match
            if (nextItemChoiceMatch != null) {
                newSessionSignalIds.add(nextItemChoiceMatch.Assessment_Definition_Signal__c);
            }
        }

        if (response.nextAssessmentItemId == null) {
            wsops.updateAssessmentSession(request.assessmentSessionId, AssessmentConstants.SESSION_COMPLETED_STATUS, newSessionSignalIds, currentItem.Id);
        } else {
            wsops.updateAssessmentSession(request.assessmentSessionId, null, newSessionSignalIds, currentItem.Id);
        }

        return response;
    }
    
    global AssessmentEvaluateChoiceResponse evaluateChoiceResponse(AssessmentEvaluateChoiceRequest request) {
        AssessmentEvaluateChoiceResponse response = new AssessmentEvaluateChoiceResponse();
        response.textResponse = request.choiceObject.value;
        return response;
    }

    private static String getUserResponseAsString(String questionType, AssessmentEvaluateItemRequest request){
        String userResponse = null;
        if (questionType == AssessmentConstants.QUESTION_TYPE_TRUEFALSE) {
            userResponse = String.valueOf(request.responseTrueOrFalse);
        } else if (questionType == AssessmentConstants.QUESTION_TYPE_NUMBER) {
            userResponse = String.valueOf(request.responseNumber);
        } else if (questionType == AssessmentConstants.QUESTION_TYPE_DATE) {
            userResponse = String.valueOf(request.responseDate);
        } else if (questionType == AssessmentConstants.QUESTION_TYPE_TEXT || questionType == AssessmentConstants.QUESTION_TYPE_CHOICES) {
            userResponse = request.responseText;
        }
        return userResponse == null ? '' : userResponse.trim();
    }

    private static Boolean evaluateCondition(String userResponse, String questionType, String conditionalOperator, String conditionalValue) {
        Boolean evaluationResult = false;
        if (questionType == AssessmentConstants.QUESTION_TYPE_NUMBER) {
            Double userNumber = Double.valueOf(userResponse);
            Double conditionNumber = Double.valueOf(conditionalValue);
            if (conditionalOperator != null) {
                if (conditionalOperator == AssessmentConstants.OPERATOR_GREATER_THAN){
                    evaluationResult = userNumber > conditionNumber;
                } else if (conditionalOperator == AssessmentConstants.OPERATOR_LESS_THAN) {
                    evaluationResult = userNumber < conditionNumber;
                } else if (conditionalOperator == AssessmentConstants.OPERATOR_EQUAL_TO) {
                    evaluationResult = userNumber == conditionNumber;
                } else if (conditionalOperator == AssessmentConstants.OPERATOR_NOT_EQUAL_TO) {
                    evaluationResult = userNumber != conditionNumber;
                } else {
                    evaluationResult = false;
                }
            } else {
                evaluationResult = userNumber == conditionNumber;
            }
        } else if (questionType == AssessmentConstants.QUESTION_TYPE_DATE) {
            Date userDate = Date.valueOf(userResponse);
            Date conditionDate = Date.valueOf(conditionalValue);
            if (conditionalOperator != null) {
                if (conditionalOperator == AssessmentConstants.OPERATOR_GREATER_THAN){
                    evaluationResult = userDate > conditionDate;
                } else if (conditionalOperator == AssessmentConstants.OPERATOR_LESS_THAN) {
                    evaluationResult = userDate < conditionDate;
                } else if (conditionalOperator == AssessmentConstants.OPERATOR_EQUAL_TO) {
                    evaluationResult = userDate.isSameDay(conditionDate);
                } else if (conditionalOperator == AssessmentConstants.OPERATOR_NOT_EQUAL_TO) {
                    evaluationResult = !userDate.isSameDay(conditionDate);
                } else {
                    evaluationResult = false;
                }
            } else {
                evaluationResult = userDate.isSameDay(conditionDate);
            }
        } else {
            if (conditionalOperator == null || conditionalOperator == AssessmentConstants.OPERATOR_EQUAL_TO) {
                evaluationResult = userResponse.equalsIgnoreCase(conditionalValue);
            } else if (conditionalOperator == AssessmentConstants.OPERATOR_NOT_EQUAL_TO) {
                evaluationResult = !userResponse.equalsIgnoreCase(conditionalValue);
            }
        }
        System.debug('conditional evaluation result '+evaluationResult);
        return evaluationResult;
    }

    private static Map<String, Set<Id>> getItemEventSignalIdsByTypeMap(List<Assessment_Definition_Item_Event__c> events) {
        Map<String, Set<Id>> result = new Map<String, Set<Id>>();
        if (events == null) return result;
        for (Assessment_Definition_Item_Event__c ev : events) {
            if (!result.containsKey(ev.Type__c)) {
                result.put(ev.Type__c, new Set<Id>());
            }
            result.get(ev.Type__c).add(ev.Assessment_Definition_Signal__c);
        }
        return result;
    }

    private without sharing class WithoutSharingOps {

        public List<Assessment_Definition__c> getAssessmentDefinitionsByUniqueName(List<String> assessmentDefinitionIds) {
            return [select Id, Active__c, Initial_Item_Name__c from Assessment_Definition__c where Assessment_Definition_Id__c in :assessmentDefinitionIds];
        }

        public Assessment_Session__c createAssessmentSession(Id assessmentDefinitionId, String routableItemId) {
            Assessment_Session__c session = new Assessment_Session__c();
            session.Assessment_Definition__c = assessmentDefinitionId;
            session.Status__c = AssessmentConstants.SESSION_IN_PROGRESS_STATUS;
            session.Source_Transcript_Id__c = routableItemId;
            insert session;
            return session;
        }

        public void updateAssessmentSession(Id assessmentSessionId, String status, Set<Id> newSignalIds, String assessmentDefinitionItemId) {
            if (assessmentSessionId == null) return;
            if (status != null) {
                Assessment_Session__c session = new Assessment_Session__c(Id = assessmentSessionId);
                session.Status__c = status;
                update session;
            }
            if (newSignalIds != null) {
                newSignalIds.remove(null);
                if (!newSignalIds.isEmpty()) {
                    List<Assessment_Session_Signal__c> currentSessionSignals = getAssessmentSessionSignals(assessmentSessionId, newSignalIds);
                    Set<Id> currentSessionSignalIds = new Set<Id>();
                    for (Assessment_Session_Signal__c s : currentSessionSignals) {
                        currentSessionSignalIds.add(s.Id);
                    }
                    // Remove existing signals
                    newSignalIds.removeAll(currentSessionSignalIds);
                    if (!newSignalIds.isEmpty()) {
                        createAsessmentSessionSignals(assessmentSessionId, newSignalIds, assessmentDefinitionItemId);
                    }
                }
            }
        }

        public Set<Id> getAssessmentSessionSignals(Id assessmentSessionId) {
            Set<Id> sessionSignals = new Set<Id>();
            for(Assessment_Session_Signal__c ss : [select Id, Assessment_Definition_Signal__c
                                                                from Assessment_Session_Signal__c
                                                                where Assessment_Session__c  = :assessmentSessionId]){
                sessionSignals.add(ss.Assessment_Definition_Signal__c);
            }
            sessionSignals.remove(null);
            return sessionSignals;
        }

        public List<Assessment_Session_Signal__c> getAssessmentSessionSignals(Id assessmentSessionId, Set<Id> assessmentDefinitionSignals) {
            List<Assessment_Session_Signal__c> sessionSignals = [select Id
                                                                from Assessment_Session_Signal__c
                                                                where Assessment_Session__c  = :assessmentSessionId
                                                                and Assessment_Definition_Signal__c in :assessmentDefinitionSignals];
            return sessionSignals;
        }

        public void createAsessmentSessionSignals(Id assessmentSessionId, Set<Id> assessmentDefinitionSignalIds, Id assessmentDefinitionItemId) {
            List<Assessment_Session_Signal__c> newSessionSignals = new List<Assessment_Session_Signal__c>();
            for (Id signalId : assessmentDefinitionSignalIds) {
                Assessment_Session_Signal__c sessionSignal = new Assessment_Session_Signal__c();
                sessionSignal.Assessment_Session__c = assessmentSessionId;
                sessionSignal.Assessment_Definition_Signal__c = signalId;
                sessionSignal.Trigger_Assessment_Definition_Item__c = assessmentDefinitionItemId;
                newSessionSignals.add(sessionSignal);
            }
            if (!newSessionSignals.isEmpty()) {
                insert newSessionSignals;
            }
        }

        public List<Assessment_Definition_Item__c> getAssessmentDefinitionItemByIds(List<Id> assessmentItemIds) {
            List<Assessment_Definition_Item__c> items = [select Id,
                                                                Name,
                                                                Assessment_Definition__c,
                                                                Message__c,
                                                                Next_Item_Name__c,
                                                                Next_Item_Name_Other_Outcome__c,
                                                                Next_Item_Outcome_Condition__c,
                                                                Next_Item_Condition_Operator__c,
                                                                Question_Type__c,
                                                                Type__c,
                                                                Transfer_Type__c,
                                                                Transfer_Target_Name__c,
                                                                (select Id, Label__c, Value__c, Assessment_Definition_Signal__c, Next_Item_Name__c
                                                                    from Assessment_Definition_Item_Choices__r order by Order__c asc),
                                                                (select Id, Assessment_Definition_Signal__c, Order__c
                                                                    from Assessment_Definition_Decision_Signals__r order by Order__c asc),
                                                                (select Id, Type__c, Assessment_Definition_Signal__c
                                                                    from Assessment_Definition_Item_Events__r)
                                                                from Assessment_Definition_Item__c
                                                                where Id in : assessmentItemIds];
            return items;
        }

        public List<Assessment_Definition_Item__c> getAssessmentDefinitionItemByNames(Set<String> assessmentItemNames, Id assessmentDefintionId) {
            List<Assessment_Definition_Item__c> items = [select Id,
                                                                Name,
                                                                Assessment_Definition__c,
                                                                Message__c,
                                                                Next_Item_Name__c,
                                                                Next_Item_Name_Other_Outcome__c,
                                                                Next_Item_Outcome_Condition__c,
                                                                Next_Item_Condition_Operator__c,
                                                                Question_Type__c,
                                                                Type__c
                                                                from Assessment_Definition_Item__c
                                                                where Name in :assessmentItemNames
                                                                and Assessment_Definition__c = :assessmentDefintionId];
            return items;
        }

        public Map<String, String> getDeploymetInfoForRoutableId(String routableItemId) {
            boolean isValidId = routableItemId InstanceOf Id;
            Map<String, String>  deploymentInfo = null;
            if (!isValidId) return deploymentInfo;
            
            Id transcriptRecordId = (Id)routableItemId;
            Schema.SObjectType transcriptSObjectType = transcriptRecordId.getSobjectType();
            String sobjectName = transcriptSObjectType.getDescribe().getName();
            List<Sobject> transcriptRecords = null;
            String transcriptChannelField = null;
            if (sobjectName == 'LiveChatTranscript') {
                transcriptChannelField = 'LiveChatButton';
                transcriptRecords = Database.query('select id, '+transcriptChannelField+'.DeveloperName from LiveChatTranscript where Id = :transcriptRecordId');
            } else if (sobjectName == 'MessagingSession') {
                transcriptRecords = Database.query('select id, '+transcriptChannelField+'.DeveloperName from MessagingSession where Id = :transcriptRecordId');
            }
            if (transcriptRecords == null || transcriptRecords.isEmpty()) {
                return deploymentInfo;
            }
            Sobject transcriptRecord = transcriptRecords.get(0);

            Map<String, Object> sobjectMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(transcriptRecord));
            Map<String, Object> recordObject = (Map<String, Object>)sobjectMap.get(transcriptChannelField);
            if (recordObject == null) return deploymentInfo;
            deploymentInfo = new Map<String, String>{
                'deploymentType' => sobjectName == 'LiveChatTranscript' ? 'Web Chat' : 'Messaging',
                'name' => (String)recordObject.get('DeveloperName')};
            return deploymentInfo;
        }

        public String getAssessmentDefinitionForDeploymentInfo(Map<String, String> channelDeploymentInfo) {
            if (channelDeploymentInfo == null) return null;
            String deploymentType = channelDeploymentInfo.get('deploymentType');
            String deploymentName = channelDeploymentInfo.get('name');
            if (deploymentType == null || deploymentName == null) return null;

            List<Assessment_Definition_Deployment__c> deployments = [select Id,
                Assessment_Definition__r.Assessment_Definition_Id__c
                from Assessment_Definition_Deployment__c
                where Deployment_Name__c = :deploymentName
                and Type__c = :deploymentType];
            
            if (deployments.isEmpty()) return null;
            return deployments.get(0).Assessment_Definition__r.Assessment_Definition_Id__c;
        }

        public String getTransferTargetId(String transferType, String transferTargetName) {
            String soql = null;
            String targetId = null;
            if (transferType == AssessmentConstants.TRANSFER_TYPE_QUEUE) {
                soql = 'select Id from Group where Type = \'Queue\' and DeveloperName = :transferTargetName';
            } else if (transferType == AssessmentConstants.TRANSFER_TYPE_BOT) {
                soql = 'select Id from BotDefinition where DeveloperName = :transferTargetName';
            } else if (transferType == AssessmentConstants.TRANSFER_TYPE_ASSESSMENT) {
                soql = 'select Assessment_Definition_Id__c from Assessment_Definition__c where Assessment_Definition_Id__c = :transferTargetName';
            }
            if (soql != null) {
                List<SObject> records = Database.query(soql);
                if (records != null && !records.isEmpty()) {
                    if (transferType == AssessmentConstants.TRANSFER_TYPE_ASSESSMENT) {
                        targetId = (String)records.get(0).get('Assessment_Definition_Id__c');
                    } else {
                        targetId = records.get(0).Id; 
                    }
                }
                if (Test.isRunningTest()) {
                    return TestAssessmentUtil.getTestTransferTargetId(transferType);
                }
            }
            return targetId;
        }

    }
}
