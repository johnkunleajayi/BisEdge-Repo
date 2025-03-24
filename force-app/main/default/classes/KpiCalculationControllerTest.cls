@isTest
public class KpiCalculationControllerTest {

    static flair__Employee__c testEmployee; // Declare this as a class variable to access it in the tests

    static void setupTestData() {
        // Create a test Employee Feedback Cycle record with the required Timeline Type
        flair__Employee_Feedback_Cycle__c feedbackCycle = new flair__Employee_Feedback_Cycle__c(
            Name = '2024 Technical Review Cycle',
            flair__Timeline_Type__c = 'Your Timeline Type' // Replace with an appropriate value
        );
        insert feedbackCycle;

        // Create a test Employee Feedback record that references the cycle
        flair__Employee_Feedback_Request__c employeeFeedback = new flair__Employee_Feedback_Request__c(
            flair__Employee_Feedback_Cycle__c = feedbackCycle.Id
            // Add any other required fields if necessary
        );
        insert employeeFeedback;

        // Create a test Employee record to link with KPI Calculation
        testEmployee = new flair__Employee__c(
            Name = 'Test Employee'
        );
        insert testEmployee;

        // Create a test KPI Calculation record that references Employee Feedback
        KPI_Calculation__c kpi = new KPI_Calculation__c(
            Employee_Lookup__c = testEmployee.Id,
            Employee_Feedback__c = employeeFeedback.Id, // Reference the employee feedback
            Question_Test__c = 'Technical Question', // Ensures the question relates to a Technical review
            Employee_Answer__c = 'Test Answer',
            Score__c = 80,
            Manager_Score_Use_This__c = 85
            // Note: Do not set Performance_Review_Cycle__c directly since it's a formula field
        );
        insert kpi;
    }

    @isTest
    static void testGetPerformanceReviewCycles() {
        // Setup data
        setupTestData(); 

        // Call the method to test
        List<String> reviewCycles = KpiCalculationController.getPerformanceReviewCycles();
        
        // Assert that the list contains the expected review cycle
        System.assertNotEquals(null, reviewCycles, 'Review cycles should not be null.');
        System.assertEquals(1, reviewCycles.size(), 'There should be one review cycle returned.');
        
        // Check that the Performance_Review_Cycle__c generated the expected value
        String expectedCycle = '2024 Technical Review Cycle'; // Use the name of the created cycle
        System.assertEquals(expectedCycle, reviewCycles[0], 'The review cycle should match the expected formula output.');
    }

    @isTest
    static void testGetEmployeesByReviewCycle() {
        // Setup data
        setupTestData();

        // Call the method to test with the appropriate performance review cycle name
        List<KpiCalculationController.EmployeeWrapper> employees = 
            KpiCalculationController.getEmployeesByReviewCycle('2024 Technical Review Cycle');
        
        // Assert that the list contains the expected employee
        System.assertNotEquals(null, employees, 'Employee list should not be null.');
        System.assertEquals(1, employees.size(), 'There should be one employee returned.');

        // Check that the returned employee matches the expected values
        // Optionally check the employeeId as well if needed
        // System.assertEquals(testEmployee.Id, employees[0].employeeId, 'The employee ID should match.');
    }

    @isTest
    static void testGetKpiDetailsByEmployee() {
        // Setup data
        setupTestData();

        // Call the method to test with the test employee's ID and the performance review cycle name
        List<KPI_Calculation__c> kpiDetails = 
            KpiCalculationController.getKpiDetailsByEmployee(testEmployee.Id, '2024 Technical Review Cycle');
        
        // Assert that the list contains the expected KPI details
        System.assertNotEquals(null, kpiDetails, 'KPI details should not be null.');
        System.assertEquals(1, kpiDetails.size(), 'There should be one KPI detail returned.');

        // Check that the returned KPI matches the expected values
        System.assertEquals('Technical Question', kpiDetails[0].Question_Test__c, 'The question should match.');
        System.assertEquals('Test Answer', kpiDetails[0].Employee_Answer__c, 'The employee answer should match.');
        System.assertEquals(80, kpiDetails[0].Score__c, 'The score should match.');
        System.assertEquals(85, kpiDetails[0].Manager_Score_Use_This__c, 'The manager score should match.');
    }
}