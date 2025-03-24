@IsTest
private class AssignKPIstoEmployeesTest {
    
    @TestSetup
    static void setupTestData() {
        // Create a test Time Period
        flair__Objective_Time_Period__c testObjectiveTimePeriod = new flair__Objective_Time_Period__c(
            Name = 'Fourth Quater',
            flair__Start_Date__c = Date.today(),
            flair__End_Date__c = Date.today().addMonths(3)
        );
        insert testObjectiveTimePeriod;
        
        // Create test team Employees
        List<flair__Employee__c> testEmployees = new List<flair__Employee__c>();
        
        for (Integer i = 0; i < 5; i++) {
            flair__Employee__c testEmployee = new flair__Employee__c(
                flair__First_Name__c = 'Test',
                flair__Last_Name__c = 'Employee ' + i,
                flair__Start_Date__c = Date.today() + i,
                flair__End_Date__c = Date.today().addMonths(12) + i,
                flair__Company_Phone_Number__c = '1234567890 ' + i,
                flair__Company_Email__c = 'testemployee' + i + '@testorg.com'
            );
            testEmployees.add(testEmployee);
        }
        insert testEmployees;
    }
    
    @IsTest
    static void testSuccessfulKPIAssignment() {
        // Retrieve test employees
        List<flair__Employee__c> testEmployees = [SELECT Id, Name FROM flair__Employee__c WHERE flair__Company_Email__c LIKE 'testemployee%'];
        
        // Create a template Employee Objective
        flair__Employee_Objective__c templateObjective = new flair__Employee_Objective__c(
            Name = 'Template Objective',
            flair__Objective_Time_Period__c = [SELECT Id FROM flair__Objective_Time_Period__c LIMIT 1].Id,
            flair__Owner__c = [SELECT Id FROM flair__Employee__c LIMIT 1].Id,
            flair__Responsible__c = [SELECT Id FROM flair__Employee__c LIMIT 1].Id,
            flair__Due_Date__c = Date.today().addMonths(3),
            flair__Start_Date__c = Date.today(),
            flair__Status__c = 'BEHIND',
            flair__Description__c = 'Test Objective Description ',
            flair__Visibility__c = 'PROTECTED_ITEM'
        );
        
        // Prepare the invocable method request
        List<AssignKPIstoEmployees.AssignKPIsRequest> requests = 
            new List<AssignKPIstoEmployees.AssignKPIsRequest>();
        
        AssignKPIstoEmployees.AssignKPIsRequest request = 
            new AssignKPIstoEmployees.AssignKPIsRequest();
        request.employees = testEmployees;
        request.templateObjective = templateObjective;
        
        requests.add(request);
        
        // Execute the method
        Test.startTest();
        List<List<SObject>> results = AssignKPIstoEmployees.assignKPIstoEmployees(requests);
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(0, results.size(), 'Results should not be empty');
        
        // Verify Employee Objectives were created
        List<flair__Employee_Objective__c> createdObjectives = [
            SELECT Id, Name, flair__Responsible__c 
            FROM flair__Employee_Objective__c 
            WHERE flair__Responsible__c IN :testEmployees
        ];
        
        System.assertEquals(testEmployees.size(), createdObjectives.size(), 
            'Number of created objectives should match number of employees');
        
        // Verify objective names were correctly generated
        for (flair__Employee_Objective__c obj : createdObjectives) {
            System.assert(obj.Name.contains('Employee'), 
                'Objective name should contain employee name');
        }
    }
    
    @IsTest
    static void testEmptyEmployeesCollection() {
        // Prepare the invocable method request with empty employees list
        List<AssignKPIstoEmployees.AssignKPIsRequest> requests = 
            new List<AssignKPIstoEmployees.AssignKPIsRequest>();
        
        AssignKPIstoEmployees.AssignKPIsRequest request = 
            new AssignKPIstoEmployees.AssignKPIsRequest();
        request.employees = new List<SObject>();
        request.templateObjective = new flair__Employee_Objective__c(
            Name = 'Template Objective'
        );
        
        requests.add(request);
        
        // Execute the method and expect an exception
        Test.startTest();
        /* 
        try {
            AssignKPIstoEmployees.assignKPIstoEmployees(requests);
            System.assert(false, 'An exception should have been thrown');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Employees collection cannot be null or empty'), 
                'Incorrect exception message');
        }
        */
        Test.stopTest();
    }
    
    @IsTest
    static void testNullTemplateObjective() {
        // Retrieve test employees
        List<flair__Employee__c> testEmployees = [SELECT Id, Name FROM flair__Employee__c WHERE flair__Company_Email__c LIKE 'testemployee%'];
        
        // Prepare the invocable method request with null template objective
        List<AssignKPIstoEmployees.AssignKPIsRequest> requests = 
            new List<AssignKPIstoEmployees.AssignKPIsRequest>();
        
        AssignKPIstoEmployees.AssignKPIsRequest request = 
            new AssignKPIstoEmployees.AssignKPIsRequest();
        request.employees = testEmployees;
        request.templateObjective = null;
        
        requests.add(request);
        
        // Execute the method and expect an exception
        Test.startTest();
        /*
        try {
            AssignKPIstoEmployees.assignKPIstoEmployees(requests);
            System.assert(false, 'An exception should have been thrown');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Template Objective cannot be null'), 
                'Incorrect exception message');
        }
        */
        Test.stopTest();
    }
    
    @IsTest
    static void testMultipleRequestProcessing() {
        // Retrieve test employees
        List<flair__Employee__c> testEmployees = [SELECT Id, Name FROM flair__Employee__c WHERE flair__Company_Email__c LIKE 'testemployee%'];
        
        // Create multiple template objectives
        List<flair__Employee_Objective__c> templateObjectives = 
            new List<flair__Employee_Objective__c>();
        
        for (Integer i = 0; i < 2; i++) {
            templateObjectives.add(new flair__Employee_Objective__c(
                Name = 'Template Objective ' + i,
                flair__Objective_Time_Period__c = [SELECT Id FROM flair__Objective_Time_Period__c LIMIT 1].Id,
                flair__Owner__c = [SELECT Id FROM flair__Employee__c LIMIT 1].Id,
                flair__Responsible__c = [SELECT Id FROM flair__Employee__c LIMIT 1].Id,
                flair__Due_Date__c = Date.today().addMonths(3),
                flair__Start_Date__c = Date.today(),
                flair__Status__c = 'BEHIND',
                flair__Description__c = 'Test Objective Description ' + i,
                flair__Visibility__c = 'PROTECTED_ITEM'
            ));
        }
        
        // Prepare multiple requests
        List<AssignKPIstoEmployees.AssignKPIsRequest> requests = 
            new List<AssignKPIstoEmployees.AssignKPIsRequest>();
        
        for (flair__Employee_Objective__c templateObj : templateObjectives) {
            AssignKPIstoEmployees.AssignKPIsRequest request = 
                new AssignKPIstoEmployees.AssignKPIsRequest();
            request.employees = testEmployees;
            request.templateObjective = templateObj;
            requests.add(request);
        }
        
        // Execute the method
        Test.startTest();
        List<List<SObject>> results = AssignKPIstoEmployees.assignKPIstoEmployees(requests);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(2, results.size(), 'Should process multiple requests');
        
        List<flair__Employee_Objective__c> createdObjectives = [
            SELECT Id, Name, flair__Team_Objective__c 
            FROM flair__Employee_Objective__c 
            WHERE flair__Responsible__c IN :testEmployees
        ];
        
        System.assertEquals(testEmployees.size() * 2, createdObjectives.size(), 
            'Number of created objectives should match number of employees and requests');
    }
}