@isTest
private class EmployeeShiftAnalyzerTest {
    // Custom object for testing (simulating Shift object)
    @TestVisible 
    private class TestShift {
        public Datetime startDateTime;
        
        public TestShift(Datetime startDt) {
            this.startDateTime = startDt;
        }
        
        public SObject toSObject() {
            // Create a mock SObject that mimics the structure of the shift object
            SObject mockShift = new flair__Employee_Shift__c(Name = 'Test Shift'); // Using Account as a placeholder
            mockShift.put('flair__Start_Datetime__c', this.startDateTime);
            return mockShift;
        }
    }

    @isTest
    static void testAnalyzeShiftsFullScenario() {
        // Prepare test data
        List<Datetime> testDateTimes = new List<Datetime>{
            Datetime.newInstance(2023, 10, 1, 0, 0, 0),
            Datetime.newInstance(2023, 10, 2, 0, 0, 0),
            Datetime.newInstance(2023, 10, 3, 0, 0, 0)
        };

        // Create test shifts
        List<SObject> testShifts = new List<SObject>();
        
        // Morning shifts (before 7 AM)
        testShifts.add(new TestShift(Datetime.newInstance(2023, 10, 1, 5, 0, 0)).toSObject());
        testShifts.add(new TestShift(Datetime.newInstance(2023, 10, 2, 6, 0, 0)).toSObject());
        
        // Afternoon shifts (2 PM to 6 PM)
        testShifts.add(new TestShift(Datetime.newInstance(2023, 10, 1, 14, 0, 0)).toSObject());
        testShifts.add(new TestShift(Datetime.newInstance(2023, 10, 2, 15, 0, 0)).toSObject());
        
        // Night shifts (after 6 PM)
        testShifts.add(new TestShift(Datetime.newInstance(2023, 10, 1, 20, 0, 0)).toSObject());
        testShifts.add(new TestShift(Datetime.newInstance(2023, 10, 2, 22, 0, 0)).toSObject());

        // Create location employees (mock SObject)
        List<SObject> locationEmployees = new List<SObject>();
        for (Integer i = 0; i < 10; i++) {
            locationEmployees.add(new flair__Employee_Shift__c(Name = 'Employee ' + i));
        }

        // Prepare the request
        EmployeeShiftAnalyzer.ShiftAnalysisRequest request = 
            new EmployeeShiftAnalyzer.ShiftAnalysisRequest();
        request.dateTimeCollection = testDateTimes;
        request.employeeShifts = testShifts;
        request.locationEmployees = locationEmployees;

        // Execute the method
        Test.startTest();
        List<EmployeeShiftAnalyzer.ShiftAnalysisResult> results = 
            EmployeeShiftAnalyzer.analyzeShifts(new List<EmployeeShiftAnalyzer.ShiftAnalysisRequest>{request});
        Test.stopTest();

        // Assertions
        System.assertNotEquals(0, results.size(), 'Results should not be empty');
        
        EmployeeShiftAnalyzer.ShiftAnalysisResult result = results[0];
        
        // Verify shift counts
        System.assertEquals(2, result.morningShifts.size(), 'Should have 2 morning shifts');
        System.assertEquals(2, result.afternoonShifts.size(), 'Should have 2 afternoon shifts');
        System.assertEquals(2, result.nightShifts.size(), 'Should have 2 night shifts');
        
        // Verify location employees count
        System.assertEquals(10, result.locationEmployeesCount, 'Location employees count should match');
        
        // Verify summary is generated
        System.assertNotEquals(null, result.shiftsSummary, 'Shifts summary should be generated');
        System.assert(result.shiftsSummary.contains('<table'), 'Summary should be an HTML table');
    }

    @isTest
    static void testAnalyzeShiftsEdgeCases() {
        // Test scenario with no shifts
        List<Datetime> testDateTimes = new List<Datetime>{
            Datetime.newInstance(2023, 10, 1, 0, 0, 0)
        };

        List<SObject> testShifts = new List<SObject>();
        List<SObject> locationEmployees = new List<SObject>();
        for (Integer i = 0; i < 5; i++) {
            locationEmployees.add(new flair__Employee_Shift__c(Name = 'Employee ' + i));
        }

        EmployeeShiftAnalyzer.ShiftAnalysisRequest request = 
            new EmployeeShiftAnalyzer.ShiftAnalysisRequest();
        request.dateTimeCollection = testDateTimes;
        request.employeeShifts = testShifts;
        request.locationEmployees = locationEmployees;

        Test.startTest();
        List<EmployeeShiftAnalyzer.ShiftAnalysisResult> results = 
            EmployeeShiftAnalyzer.analyzeShifts(new List<EmployeeShiftAnalyzer.ShiftAnalysisRequest>{request});
        Test.stopTest();

        // Assertions for edge case
        System.assertNotEquals(0, results.size(), 'Results should not be empty');
        
        EmployeeShiftAnalyzer.ShiftAnalysisResult result = results[0];
        
        System.assertEquals(0, result.morningShifts.size(), 'Morning shifts should be 0');
        System.assertEquals(0, result.afternoonShifts.size(), 'Afternoon shifts should be 0');
        System.assertEquals(0, result.nightShifts.size(), 'Night shifts should be 0');
        System.assertEquals(5, result.locationEmployeesCount, 'Location employees count should match');
    }

    @isTest
    static void testAnalyzeShiftsMultipleRequests() {
        // Prepare multiple requests to test bulk processing
        List<EmployeeShiftAnalyzer.ShiftAnalysisRequest> multipleRequests = 
            new List<EmployeeShiftAnalyzer.ShiftAnalysisRequest>();

        for (Integer j = 0; j < 3; j++) {
            List<Datetime> testDateTimes = new List<Datetime>{
                Datetime.newInstance(2023, 10, j+1, 0, 0, 0)
            };

            List<SObject> testShifts = new List<SObject>();
            testShifts.add(new TestShift(Datetime.newInstance(2023, 10, j+1, 5, 0, 0)).toSObject());
            testShifts.add(new TestShift(Datetime.newInstance(2023, 10, j+1, 15, 0, 0)).toSObject());

            List<SObject> locationEmployees = new List<SObject>();
            for (Integer i = 0; i < 8; i++) {
                locationEmployees.add(new flair__Employee_Shift__c(Name = 'Employee ' + i));
            }

            EmployeeShiftAnalyzer.ShiftAnalysisRequest request = 
                new EmployeeShiftAnalyzer.ShiftAnalysisRequest();
            request.dateTimeCollection = testDateTimes;
            request.employeeShifts = testShifts;
            request.locationEmployees = locationEmployees;

            multipleRequests.add(request);
        }

        Test.startTest();
        List<EmployeeShiftAnalyzer.ShiftAnalysisResult> results = 
            EmployeeShiftAnalyzer.analyzeShifts(multipleRequests);
        Test.stopTest();

        // Assertions for multiple requests
        System.assertEquals(3, results.size(), 'Should process all requests');
        
        for (EmployeeShiftAnalyzer.ShiftAnalysisResult result : results) {
            System.assertEquals(1, result.morningShifts.size(), 'Each result should have 1 morning shift');
            System.assertEquals(1, result.afternoonShifts.size(), 'Each result should have 1 afternoon shift');
            System.assertEquals(8, result.locationEmployeesCount, 'Location employees count should match');
            System.assertNotEquals(null, result.shiftsSummary, 'Shifts summary should be generated');
        }
    }
}