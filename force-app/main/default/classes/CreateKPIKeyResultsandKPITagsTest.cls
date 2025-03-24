@isTest
private class CreateKPIKeyResultsandKPITagsTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test employee objectives
        List<flair__Employee_Objective__c> testEmployeeObjectives = new List<flair__Employee_Objective__c>();
        for (Integer i = 0; i < 5; i++) {
            flair__Employee_Objective__c empObj = new flair__Employee_Objective__c(
                Name = 'Test Employee Objective ' + i,
                flair__Status__c = 'BEHIND'
            );
            testEmployeeObjectives.add(empObj);
        }
        insert testEmployeeObjectives;
    }
    
    @isTest
    static void testCreateKPIKeyResultsandTagsSuccess() {
        // Retrieve the test employee objectives created in setup
        List<flair__Employee_Objective__c> employeeObjectives = [
            SELECT Id 
            FROM flair__Employee_Objective__c 
            LIMIT 5
        ];
        
        // Prepare key results
        List<flair__Objective_Key_Result__c> keyResults = new List<flair__Objective_Key_Result__c>();
        for (Integer i = 0; i < 3; i++) {
            flair__Objective_Key_Result__c kr = new flair__Objective_Key_Result__c(
                Name = 'Test Key Result ' + i,
                flair__Initial_Value__c = 0,
                flair__Target_Value__c = 100,
                flair__Current_Value__c = 50,
                flair__Type__c = 'Numeric'
            );
            keyResults.add(kr);
        }
        
        // Prepare tags
        // Create related records for Tags if flair__Tag__c is a lookup
        List<flair__Tag__c> tags = new List<flair__Tag__c>(); // Replace with the actual object name for flair__Tag__c
        for (Integer i = 0; i < 2; i++) {
            tags.add(new flair__Tag__c(Name = 'Tag ' + i)); // Replace Name with the actual required fields for the object
        }
        insert tags;

        // Create test data for Objective Tags using the IDs of related Tag records
        List<flair__Objective_Tag__c> objectiveTags = new List<flair__Objective_Tag__c>();
        for (flair__Tag__c tag : tags) {
            objectiveTags.add(new flair__Objective_Tag__c(
                flair__Tag__c = tag.Id // Assign the ID of the related Tag record
            ));
        }
        
        // Prepare the invocable method request
        List<CreateKPIKeyResultsandKPITags.KPIKeyResultsandTagsRequest> requests = 
            new List<CreateKPIKeyResultsandKPITags.KPIKeyResultsandTagsRequest>();
        
        CreateKPIKeyResultsandKPITags.KPIKeyResultsandTagsRequest request = 
            new CreateKPIKeyResultsandKPITags.KPIKeyResultsandTagsRequest();
        request.employeeObjectives = employeeObjectives;
        request.objectiveKeyResults = keyResults;
        request.objectiveTags = objectiveTags;
        
        requests.add(request);
        
        // Perform the test
        Test.startTest();
        List<CreateKPIKeyResultsandKPITags.KPIKeyResultsandTagsResponse> responses = 
            CreateKPIKeyResultsandKPITags.createKPIKeyResultsandTags(requests);
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(0, responses.size(), 'Response list should not be empty');
        
        // Verify key results creation
        List<flair__Objective_Key_Result__c> createdKeyResults = [
            SELECT Id, flair__Employee_Objective__c 
            FROM flair__Objective_Key_Result__c 
            WHERE flair__Employee_Objective__c IN :employeeObjectives
        ];
        System.assertEquals(
            employeeObjectives.size() * keyResults.size(), 
            createdKeyResults.size(), 
            'Number of created key results should match'
        );
        
        // Verify tags creation
        List<flair__Objective_Tag__c> createdTags = [
            SELECT Id, flair__Employee_Objective__c 
            FROM flair__Objective_Tag__c 
            WHERE flair__Employee_Objective__c IN :employeeObjectives
        ];
        System.assertEquals(
            employeeObjectives.size() * tags.size(), 
            createdTags.size(), 
            'Number of created tags should match'
        );
    }
    
    @isTest
    static void testCreateKPIKeyResultsandTagsEmptyInput() {
        // Prepare empty lists
        List<flair__Employee_Objective__c> employeeObjectives = new List<flair__Employee_Objective__c>();
        List<flair__Objective_Key_Result__c> keyResults = new List<flair__Objective_Key_Result__c>();
        List<flair__Objective_Tag__c> tags = new List<flair__Objective_Tag__c>();
        
        // Prepare the invocable method request
        List<CreateKPIKeyResultsandKPITags.KPIKeyResultsandTagsRequest> requests = 
            new List<CreateKPIKeyResultsandKPITags.KPIKeyResultsandTagsRequest>();
        
        CreateKPIKeyResultsandKPITags.KPIKeyResultsandTagsRequest request = 
            new CreateKPIKeyResultsandKPITags.KPIKeyResultsandTagsRequest();
        request.employeeObjectives = employeeObjectives;
        request.objectiveKeyResults = keyResults;
        request.objectiveTags = tags;
        
        requests.add(request);
        
        // Perform the test
        Test.startTest();
        List<CreateKPIKeyResultsandKPITags.KPIKeyResultsandTagsResponse> responses = 
            CreateKPIKeyResultsandKPITags.createKPIKeyResultsandTags(requests);
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(0, responses.size(), 'Response list should not be empty');
        System.assertEquals(0, responses[0].createdKeyResults.size(), 'No key results should be created');
        System.assertEquals(0, responses[0].createdTags.size(), 'No tags should be created');
    }
    
    @isTest
    static void testCreateKPIKeyResultsandTagsWithDmlException() {
        // Create a mock employee objective that might trigger a validation rule
        List<flair__Employee_Objective__c> employeeObjectives = new List<flair__Employee_Objective__c>{
            new flair__Employee_Objective__c(
                Name = 'Test Objective with Potential Exception'
                // Add any fields that might cause a validation error
            )
        };
        
        // Prepare key results
        List<flair__Objective_Key_Result__c> keyResults = new List<flair__Objective_Key_Result__c>();
        for (Integer i = 0; i < 3; i++) {
            flair__Objective_Key_Result__c kr = new flair__Objective_Key_Result__c(
                Name = 'Test Key Result ' + i,
                flair__Initial_Value__c = 0,
                flair__Target_Value__c = 100,
                flair__Current_Value__c = 50,
                flair__Type__c = 'Numeric'
            );
            keyResults.add(kr);
        }
        
        // Prepare tags
        // Create related records for Tags if flair__Tag__c is a lookup
        List<flair__Tag__c> tags = new List<flair__Tag__c>(); // Replace with the actual object name for flair__Tag__c
        for (Integer i = 0; i < 2; i++) {
            tags.add(new flair__Tag__c(Name = 'Tag ' + i)); // Replace Name with the actual required fields for the object
        }
        insert tags;

        // Create test data for Objective Tags using the IDs of related Tag records
        List<flair__Objective_Tag__c> objectiveTags = new List<flair__Objective_Tag__c>();
        for (flair__Tag__c tag : tags) {
            objectiveTags.add(new flair__Objective_Tag__c(
                flair__Tag__c = tag.Id // Assign the ID of the related Tag record
            ));
        }
        
        // Prepare the invocable method request
        List<CreateKPIKeyResultsandKPITags.KPIKeyResultsandTagsRequest> requests = 
            new List<CreateKPIKeyResultsandKPITags.KPIKeyResultsandTagsRequest>();
        
        CreateKPIKeyResultsandKPITags.KPIKeyResultsandTagsRequest request = 
            new CreateKPIKeyResultsandKPITags.KPIKeyResultsandTagsRequest();
        request.employeeObjectives = employeeObjectives;
        request.objectiveKeyResults = keyResults;
        request.objectiveTags = objectiveTags;
        
        requests.add(request);
        
        // Perform the test
        Test.startTest();
        List<CreateKPIKeyResultsandKPITags.KPIKeyResultsandTagsResponse> responses = 
            CreateKPIKeyResultsandKPITags.createKPIKeyResultsandTags(requests);
        Test.stopTest();
    }
}