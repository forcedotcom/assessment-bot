global with sharing class AssessmentEvaluateItemResponseAction {

    @InvocableMethod(label='Evaluate Assessment Response' description='Evaluates the response of the current assessment item')
    global static List<AssessmentEvaluateItemResponse> evaluateItemResponse(List<AssessmentEvaluateItemRequest> req) {

        AssessmentService service = new AssessmentServiceImpl();
        AssessmentEvaluateItemResponse response = service.evaluateItemResponse(req.get(0));

        return new List<AssessmentEvaluateItemResponse>{response};
    } 
    
}