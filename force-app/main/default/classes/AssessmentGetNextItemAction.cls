global with sharing class AssessmentGetNextItemAction {

    @InvocableMethod(label='Get Next Assessment Item' description='Returns metadata for the next assessment item to execute')
    global static List<AssessmentNextItemResponse> getNextAssessmentAction(List<AssessmentNextItemRequest> req) {
        
        AssessmentService service = new AssessmentServiceImpl();
        AssessmentNextItemResponse response = service.getNextItemResponse(req.get(0));
        
        return new List<AssessmentNextItemResponse>{response};
    }

}