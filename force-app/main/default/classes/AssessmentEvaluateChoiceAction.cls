global with sharing class AssessmentEvaluateChoiceAction {

    @InvocableMethod(label='Evaluate Assessment Choice Response' description='Evaluates the response of the current assessment choice item')
    global static List<AssessmentEvaluateChoiceResponse> evaluateChoiceResponse(List<AssessmentEvaluateChoiceRequest> req) {

        AssessmentService service = new AssessmentServiceImpl();
        AssessmentEvaluateChoiceResponse response = service.evaluateChoiceResponse(req.get(0));

        return new List<AssessmentEvaluateChoiceResponse>{response};
    } 
    
}