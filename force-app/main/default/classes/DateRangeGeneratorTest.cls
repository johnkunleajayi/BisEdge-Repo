@isTest
private class DateRangeGeneratorTest {
    
    @isTest
    static void testGenerateDateRangeBasicScenario() {
        // Test a basic scenario with a small date range
        DateRangeGenerator.DateRangeRequest request = new DateRangeGenerator.DateRangeRequest();
        request.startDate = Datetime.newInstance(2023, 1, 1, 0, 0, 0);
        request.endDate = Datetime.newInstance(2023, 1, 5, 0, 0, 0);
        
        Test.startTest();
        List<List<Datetime>> results = DateRangeGenerator.generateDateRange(new List<DateRangeGenerator.DateRangeRequest>{request});
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(0, results.size(), 'Results should not be empty');
        System.assertEquals(1, results.size(), 'Should have one result set');
        
        List<Datetime> dateRange = results[0];
        System.assertEquals(5, dateRange.size(), 'Should generate 5 days');
        
        // Verify dates are correct
        System.assertEquals(Datetime.newInstance(2023, 1, 1, 0, 0, 0), dateRange[0], 'First date should match start date');
        System.assertEquals(Datetime.newInstance(2023, 1, 5, 0, 0, 0), dateRange[4], 'Last date should match end date');
    }
    
    @isTest
    static void testGenerateDateRangeSameDayScenario() {
        // Test scenario where start and end dates are the same
        DateRangeGenerator.DateRangeRequest request = new DateRangeGenerator.DateRangeRequest();
        request.startDate = Datetime.newInstance(2023, 6, 15, 10, 30, 0);
        request.endDate = Datetime.newInstance(2023, 6, 15, 14, 45, 0);
        
        Test.startTest();
        List<List<Datetime>> results = DateRangeGenerator.generateDateRange(new List<DateRangeGenerator.DateRangeRequest>{request});
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(0, results.size(), 'Results should not be empty');
        System.assertEquals(1, results.size(), 'Should have one result set');
        
        List<Datetime> dateRange = results[0];
        System.assertEquals(1, dateRange.size(), 'Should generate 1 day');
        System.assertEquals(request.startDate, dateRange[0], 'Single date should match input date');
    }
    
    @isTest
    static void testGenerateDateRangeMultipleRequests() {
        // Test multiple requests in a single call
        List<DateRangeGenerator.DateRangeRequest> requests = new List<DateRangeGenerator.DateRangeRequest>();
        
        // Request 1: 3 days
        DateRangeGenerator.DateRangeRequest request1 = new DateRangeGenerator.DateRangeRequest();
        request1.startDate = Datetime.newInstance(2023, 2, 1, 0, 0, 0);
        request1.endDate = Datetime.newInstance(2023, 2, 3, 0, 0, 0);
        requests.add(request1);
        
        // Request 2: 2 days
        DateRangeGenerator.DateRangeRequest request2 = new DateRangeGenerator.DateRangeRequest();
        request2.startDate = Datetime.newInstance(2023, 3, 10, 0, 0, 0);
        request2.endDate = Datetime.newInstance(2023, 3, 11, 0, 0, 0);
        requests.add(request2);
        
        Test.startTest();
        List<List<Datetime>> results = DateRangeGenerator.generateDateRange(requests);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(2, results.size(), 'Should process both requests');
        System.assertEquals(3, results[0].size(), 'First request should generate 3 days');
        System.assertEquals(2, results[1].size(), 'Second request should generate 2 days');
    }
    
    @isTest
    static void testGenerateDateRangeErrorScenarios() {
        // Test error scenarios
        List<DateRangeGenerator.DateRangeRequest> scenarios = new List<DateRangeGenerator.DateRangeRequest>();
        
        // Scenario 1: Null start date
        DateRangeGenerator.DateRangeRequest nullStartRequest = new DateRangeGenerator.DateRangeRequest();
        nullStartRequest.endDate = Datetime.newInstance(2023, 4, 1, 0, 0, 0);
        scenarios.add(nullStartRequest);
        
        // Scenario 2: Null end date
        DateRangeGenerator.DateRangeRequest nullEndRequest = new DateRangeGenerator.DateRangeRequest();
        nullEndRequest.startDate = Datetime.newInstance(2023, 4, 1, 0, 0, 0);
        scenarios.add(nullEndRequest);
        
        // Scenario 3: End date before start date
        DateRangeGenerator.DateRangeRequest invalidDateRequest = new DateRangeGenerator.DateRangeRequest();
        invalidDateRequest.startDate = Datetime.newInstance(2023, 5, 2, 0, 0, 0);
        invalidDateRequest.endDate = Datetime.newInstance(2023, 5, 1, 0, 0, 0);
        scenarios.add(invalidDateRequest);
        
        Test.startTest();
        List<List<Datetime>> results = DateRangeGenerator.generateDateRange(scenarios);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(0, results.size(), 'Should not return any results for invalid requests');
    }
    
    @isTest
    static void testGenerateDateRangeNullInput() {
        // Test null input
        Test.startTest();
        List<List<Datetime>> results = DateRangeGenerator.generateDateRange(null);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(0, results.size(), 'Should return empty list for null input');
    }
    
    @isTest
    static void testGenerateDateRangeLongRange() {
        // Test a longer date range
        DateRangeGenerator.DateRangeRequest request = new DateRangeGenerator.DateRangeRequest();
        request.startDate = Datetime.newInstance(2023, 1, 1, 0, 0, 0);
        request.endDate = Datetime.newInstance(2023, 1, 31, 0, 0, 0);
        
        Test.startTest();
        List<List<Datetime>> results = DateRangeGenerator.generateDateRange(new List<DateRangeGenerator.DateRangeRequest>{request});
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(0, results.size(), 'Results should not be empty');
        System.assertEquals(1, results.size(), 'Should have one result set');
        
        List<Datetime> dateRange = results[0];
        System.assertEquals(31, dateRange.size(), 'Should generate 31 days for January');
        
        // Verify first and last dates
        System.assertEquals(Datetime.newInstance(2023, 1, 1, 0, 0, 0), dateRange[0], 'First date should match start date');
        System.assertEquals(Datetime.newInstance(2023, 1, 31, 0, 0, 0), dateRange[30], 'Last date should match end date');
    }
}