global interface AssessmentService {

    AssessmentInitialItemResponse getInitialItemResponse(AssessmentInitialItemRequest request);
    AssessmentNextItemResponse getNextItemResponse(AssessmentNextItemRequest request);
    AssessmentEvaluateItemResponse evaluateItemResponse(AssessmentEvaluateItemRequest request);
    AssessmentEvaluateChoiceResponse evaluateChoiceResponse(AssessmentEvaluateChoiceRequest request);

}