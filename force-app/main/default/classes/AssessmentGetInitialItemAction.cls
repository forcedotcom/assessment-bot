global with sharing class AssessmentGetInitialItemAction {

	@InvocableMethod(label='Get Inital Assessment Item' description='Returns metadata for the inital assessment item to execute')
    global static List<AssessmentInitialItemResponse> getInitalAssessmentAction(List<AssessmentInitialItemRequest> reqs) {

        AssessmentService service = new AssessmentServiceImpl();
        
        AssessmentInitialItemResponse response = service.getInitialItemResponse(reqs.get(0));

        return new List<AssessmentInitialItemResponse>{response};
    } 

}