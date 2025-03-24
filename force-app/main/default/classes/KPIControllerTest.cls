@isTest
public class KPIControllerTest {

    @testSetup
    static void setupTestData() {
        // Create test Employee record
        flair__Employee__c testEmployee = new flair__Employee__c(Name = 'Test Employee');
        insert testEmployee;

        // Create a KPI_Result__c record linked to the test Employee with required base fields
        KPI_Result__c kpiResult = new KPI_Result__c(
            Employee__c = testEmployee.Id,
            Manager_Technical_Score__c = 0.012,
            Employee_Technical_Score_Appraisal_Total__c = 0.012,
            Employee_Behavioural_Appraisal__c = 0.012,
            Manager_Behavioural_Appraisal_Feedback__c = 0.012,
            Organisation_Ratio_Technical_Appraisal__c = 0.012,
            Organisation_Ratio_Behavioural_Appraisal__c = 0.018
        );
        insert kpiResult;
    }
    
    @isTest
    static void testGetKpiResults() {
        // Ensure flow is run to populate formula fields
        Test.startTest();
        
        // Call the flow if it’s a record-triggered flow that runs on updates
        KPI_Result__c kpiToTriggerFlow = [SELECT Id FROM KPI_Result__c LIMIT 1];
        update kpiToTriggerFlow;

        Test.stopTest();

        // Call the getKpiResults method
        List<KPI_Result__c> results = KPIController.getKpiResults();
        
        // Verify that results are returned
        System.assertNotEquals(0, results.size(), 'Expected KPI results to be returned');
        
        // Verify the fields of the first record in the result
        KPI_Result__c result = results[0];
        
        // Add assertions for formula fields after flow execution if expected values are known
        // System.assertEquals(expectedFormulaValue, result.Technical_Overall_Score__c, 'Technical Overall Score should match');
    }
}