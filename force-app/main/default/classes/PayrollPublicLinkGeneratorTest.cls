/**
 * Class: PayrollPublicLinkGeneratorTest
 * Description: Test class for PayrollPublicLinkGenerator
 */
@isTest
private class PayrollPublicLinkGeneratorTest {
    
    @testSetup
    static void setupTestData() {
        // 1. Create test Payroll Territory record
        flair__Payroll_Territory__c payrollTerritory = new flair__Payroll_Territory__c(
            Name = 'Test Payroll Territory'
        );
        insert payrollTerritory;
        
        // 2. Create test Payroll Run record with required fields
        flair__Payroll_Run__c payrollRun = new flair__Payroll_Run__c(
            Name = 'Test Payroll Run',
            flair__Payroll_Territory__c = payrollTerritory.Id,
            flair__Start_Date__c = Date.today().addDays(-30),
            flair__End_Date__c = Date.today(),
            flair__Time_Entries_Start_Date__c = Date.today().addDays(-30),
            flair__Time_Entries_End_Date__c = Date.today(),
            flair__State__c = 'Draft' // Assuming 'Draft' is a valid state value
        );
        insert payrollRun;
        
        // Create test ContentVersion
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test Salary Document',
            PathOnClient = 'TestSalaryDocument.pdf',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;
    }
    
    @isTest
    static void testGeneratePayrollPublicLinks() {
        // Get the Payroll Run ID
        flair__Payroll_Run__c payrollRun = [
            SELECT Id 
            FROM flair__Payroll_Run__c 
            LIMIT 1
        ];
        
        // Get the ContentDocument ID
        ContentVersion contentVersion = [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Title = 'Test Salary Document'
            LIMIT 1
        ];
        
        // Create input parameter
        PayrollPublicLinkGenerator.InputParams param = new PayrollPublicLinkGenerator.InputParams();
        param.contentDocumentId = contentVersion.ContentDocumentId;
        param.payrollRunId = payrollRun.Id;
        
        Test.startTest();
        
        // Call the invocable method
        List<String> results = PayrollPublicLinkGenerator.generatePayrollPublicLinks(
            new List<PayrollPublicLinkGenerator.InputParams>{param}
        );
        
        Test.stopTest();
        
        // Verify results
        System.assertNotEquals(0, results.size(), 'Should return at least one result message');
        
        // Verify the Payroll Run record was updated
        flair__Payroll_Run__c updatedPayrollRun = [
            SELECT Id, Edit_Salary_Details_Link__c 
            FROM flair__Payroll_Run__c
            LIMIT 1
        ];
        
        System.assertNotEquals(null, updatedPayrollRun.Edit_Salary_Details_Link__c, 
                              'Edit_Salary_Details_Link__c should be populated');
        
        // Verify URL format (in test context it will be a mock URL)
        System.assert(updatedPayrollRun.Edit_Salary_Details_Link__c.startsWith('https://'), 
                     'URL should start with https://');
    }
    
    @isTest
    static void testNullInput() {
        Test.startTest();
        
        // Call with null input
        List<String> results = PayrollPublicLinkGenerator.generatePayrollPublicLinks(null);
        
        Test.stopTest();
        
        // Verify error handling
        System.assertEquals(1, results.size(), 'Should return one error message');
        System.assertEquals('No input parameters provided', results[0], 
                           'Should return appropriate error message');
    }
    
    @isTest
    static void testInvalidIds() {
        // Get a valid ContentDocument ID
        ContentVersion contentVersion = [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Title = 'Test Salary Document'
            LIMIT 1
        ];
        
        // Create input with invalid Payroll Run ID
        PayrollPublicLinkGenerator.InputParams invalidParam = new PayrollPublicLinkGenerator.InputParams();
        invalidParam.contentDocumentId = contentVersion.ContentDocumentId;
        invalidParam.payrollRunId = UserInfo.getUserId(); // Using User ID as a definitely wrong ID
        
        Test.startTest();
        
        // Call with invalid ID
        List<String> results = PayrollPublicLinkGenerator.generatePayrollPublicLinks(
            new List<PayrollPublicLinkGenerator.InputParams>{invalidParam}
        );
        
        Test.stopTest();
        
        // Verify error handling
        System.assertNotEquals(0, results.size(), 'Should return at least one result message');
    }
    
    @isTest
    static void testMissingIds() {
        // Get data for test
        flair__Payroll_Run__c payrollRun = [
            SELECT Id 
            FROM flair__Payroll_Run__c 
            LIMIT 1
        ];
        
        ContentVersion contentVersion = [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Title = 'Test Salary Document'
            LIMIT 1
        ];
        
        // Test missing Content Document ID
        PayrollPublicLinkGenerator.InputParams missingContentDoc = new PayrollPublicLinkGenerator.InputParams();
        missingContentDoc.payrollRunId = payrollRun.Id;
        // contentDocumentId intentionally left null
        
        // Test missing Payroll Run ID
        PayrollPublicLinkGenerator.InputParams missingPayrollRun = new PayrollPublicLinkGenerator.InputParams();
        missingPayrollRun.contentDocumentId = contentVersion.ContentDocumentId;
        // payrollRunId intentionally left null
        
        Test.startTest();
        
        // Call with missing Content Document ID
        List<String> results1 = PayrollPublicLinkGenerator.generatePayrollPublicLinks(
            new List<PayrollPublicLinkGenerator.InputParams>{missingContentDoc}
        );
        
        // Call with missing Payroll Run ID
        List<String> results2 = PayrollPublicLinkGenerator.generatePayrollPublicLinks(
            new List<PayrollPublicLinkGenerator.InputParams>{missingPayrollRun}
        );
        
        Test.stopTest();
        
        // Verify error handling
        System.assertNotEquals(0, results1.size(), 'Should return at least one result message for missing Content Document ID');
        System.assertNotEquals(0, results2.size(), 'Should return at least one result message for missing Payroll Run ID');
    }
}