@isTest
public class KpiCalculationControllerBTest {

    static flair__Employee__c testEmployeeB; // Declare this as a class variable to access it in the tests

    static void setupTestData() {
        // Create a test Employee Feedback Cycle record with the required Timeline Type
        flair__Employee_Feedback_Cycle__c feedbackCycle = new flair__Employee_Feedback_Cycle__c(
            Name = '2024 Behavioural Review Cycle',
            flair__Timeline_Type__c = 'Behavioural'
        );
        insert feedbackCycle;

        // Create a test Employee Feedback record that references the cycle
        flair__Employee_Feedback_Request__c employeeFeedback = new flair__Employee_Feedback_Request__c(
            flair__Employee_Feedback_Cycle__c = feedbackCycle.Id
            // Add any other required fields for formula dependencies here
        );
        insert employeeFeedback;

        // Create a test Employee record to link with KPI Calculation
        testEmployeeB = new flair__Employee__c(
            Name = 'Test EmployeeB'
        );
        insert testEmployeeB;

        // Create a test KPI Calculation record that references Employee Feedback
        KPI_Calculation__c kpi = new KPI_Calculation__c(
            Employee_Lookup__c = testEmployeeB.Id,
            Employee_Feedback__c = employeeFeedback.Id, // Reference the employee feedback
            Question_Test__c = 'Behavioural Question',
            Employee_Answer__c = 'Answer 1',
            Behavioural_Percentage__c = 90,
            Manager_Behavioural_Score__c = 88
            // Add any other fields required for formula calculations
        );
        insert kpi;
    }

    @isTest
    static void testGetPerformanceReviewCycles() {
        // Setup data
        setupTestData(); 

        // Call the method to test
        List<String> reviewCycles = KpiCalculationControllerB.getPerformanceReviewCycles();
        
        // Assert that the list contains the expected review cycle
        System.assertNotEquals(null, reviewCycles, 'Review cycles should not be null.');
        System.assertEquals(1, reviewCycles.size(), 'There should be one review cycle returned.');
        
        // Check that the Performance_Review_Cycle__c generated the expected value
        String expectedCycle = '2024 Behavioural Review Cycle'; // Use the name of the created cycle
        System.assertEquals(expectedCycle, reviewCycles[0], 'The review cycle should match the expected formula output.');
    }

    @isTest
    static void testGetEmployeesByReviewCycle() {
        // Setup data
        setupTestData();

        // Call the method to test with the correct performance review cycle name
        List<KpiCalculationControllerB.EmployeeWrapper> employees = 
            KpiCalculationControllerB.getEmployeesByReviewCycle('2024 Behavioural Review Cycle');
        
        // Assert that the list contains the expected employee
        System.assertNotEquals(null, employees, 'Employee list should not be null.');
        System.assertEquals(1, employees.size(), 'There should be one employee returned.');
    }

    @isTest
    static void testGetKpiDetailsByEmployee() {
        // Setup data
        setupTestData();

        // Call the method to test with the test employee's ID and the performance review cycle name
        List<KPI_Calculation__c> kpiDetails = 
            KpiCalculationControllerB.getKpiDetailsByEmployee(testEmployeeB.Id, '2024 Behavioural Review Cycle');
        
        // Assert that the list contains the expected KPI details
        System.assertNotEquals(null, kpiDetails, 'KPI details should not be null.');
        System.assertEquals(1, kpiDetails.size(), 'There should be one KPI detail returned.');

        // Check that the returned KPI matches the expected values
        System.assertEquals('Behavioural Question', kpiDetails[0].Question_Test__c, 'The question should match.');
        System.assertEquals('Answer 1', kpiDetails[0].Employee_Answer__c, 'The employee answer should match.');
        System.assertEquals(90, kpiDetails[0].Behavioural_Percentage__c, 'The score should match.');
        System.assertEquals(88, kpiDetails[0].Manager_Behavioural_Score__c, 'The manager score should match.');
    }
}