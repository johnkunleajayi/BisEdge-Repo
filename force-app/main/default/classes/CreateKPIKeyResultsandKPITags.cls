public with sharing class CreateKPIKeyResultsandKPITags {
    // Wrapper class to handle multiple inputs
    public class KPIKeyResultsandTagsRequest {
        @InvocableVariable(required=true)
        public List<flair__Employee_Objective__c> employeeObjectives;

        @InvocableVariable(required=true)
        public List<flair__Objective_Key_Result__c> objectiveKeyResults;

        @InvocableVariable(required=true)
        public List<flair__Objective_Tag__c> objectiveTags;
    }

    // Wrapper class to handle outputs
    public class KPIKeyResultsandTagsResponse {
        @InvocableVariable
        public List<flair__Objective_Key_Result__c> createdKeyResults;

        @InvocableVariable
        public List<flair__Objective_Tag__c> createdTags;
    }

    @InvocableMethod(label='Create KPI Key Results and Tags' description='Creates Objective Key Results and Tags based on Employee Objectives.')
    public static List<KPIKeyResultsandTagsResponse> createKPIKeyResultsandTags(List<KPIKeyResultsandTagsRequest> requests) {
        // Initialize outputs
        List<KPIKeyResultsandTagsResponse> responses = new List<KPIKeyResultsandTagsResponse>();
        List<flair__Objective_Key_Result__c> allKeyResults = new List<flair__Objective_Key_Result__c>();
        List<flair__Objective_Tag__c> allTags = new List<flair__Objective_Tag__c>();

        for (KPIKeyResultsandTagsRequest request : requests) {
            // Collections to accumulate the records
            List<flair__Objective_Key_Result__c> keyResultsCollection = new List<flair__Objective_Key_Result__c>();
            List<flair__Objective_Tag__c> tagsCollection = new List<flair__Objective_Tag__c>();

            // Outer loop through Employee Objectives
            for (flair__Employee_Objective__c empObjective : request.employeeObjectives) {
                // Inner loop for Key Results
                for (flair__Objective_Key_Result__c objKeyResult : request.objectiveKeyResults) {
                    flair__Objective_Key_Result__c keyResult = new flair__Objective_Key_Result__c(
                        flair__Employee_Objective__c = empObjective.Id,
                        flair__Initial_Value__c = objKeyResult.flair__Initial_Value__c,
                        flair__Target_Value__c = objKeyResult.flair__Target_Value__c,
                        flair__Current_Value__c = objKeyResult.flair__Current_Value__c,
                        flair__Type__c = objKeyResult.flair__Type__c,
                        Name = objKeyResult.Name
                    );
                    keyResultsCollection.add(keyResult);
                }

                // Inner loop for Tags
                for (flair__Objective_Tag__c objTag : request.objectiveTags) {
                    flair__Objective_Tag__c tag = new flair__Objective_Tag__c(
                        flair__Employee_Objective__c = empObjective.Id,
                        flair__Tag__c = objTag.flair__Tag__c
                    );
                    tagsCollection.add(tag);
                }
            }

            // Insert records and accumulate for response
            try {
                if (!keyResultsCollection.isEmpty()) {
                    insert keyResultsCollection;
                    allKeyResults.addAll(keyResultsCollection);
                }
                if (!tagsCollection.isEmpty()) {
                    insert tagsCollection;
                    allTags.addAll(tagsCollection);
                }
            } catch (DmlException ex) {
                // Log errors for debugging and prevent bulk failure
                System.debug('Error inserting records: ' + ex.getMessage());
                continue;
            }
        }

        // Create a response and populate its fields explicitly
        KPIKeyResultsandTagsResponse response = new KPIKeyResultsandTagsResponse();
        response.createdKeyResults = allKeyResults;
        response.createdTags = allTags;
        responses.add(response);

        return responses;
    }
}