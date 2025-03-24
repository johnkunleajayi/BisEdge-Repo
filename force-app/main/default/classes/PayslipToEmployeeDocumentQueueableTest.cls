@isTest
private class PayslipToEmployeeDocumentQueueableTest {
    @isTest
    static void testPayslipToEmployeeDocumentQueueable() {
        // Create required Document Category for trigger
        flair__Document_Category__c payrollCategory = new flair__Document_Category__c(
            Name = 'Payroll',
            flair__API_Name__c = 'Payroll'
        );
        insert payrollCategory;

        // Create test Employee
        flair__Employee__c testEmployee = new flair__Employee__c(
            flair__First_Name__c = 'Test',
            flair__Last_Name__c = 'Employee'
        );
        insert testEmployee;

        // Create test Employee Payslip
        Employee_Payslip__c testPayslip = new Employee_Payslip__c(
            Employee__c = testEmployee.Id
        );
        insert testPayslip;

        // Adjust CreatedDate to fall within the required range
        Test.setCreatedDate(testPayslip.Id, System.now().addMinutes(-10));

        // Create test ContentDocument (File)
        ContentVersion testContentVersion = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'TestDocument.pdf',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert testContentVersion;
        
        // Retrieve the ContentDocument ID
        ContentDocument testContentDocument = [SELECT Id FROM ContentDocument WHERE Title = 'Test Document' LIMIT 1];

        // Create initial ContentDocumentLink to simulate an existing file attachment
        ContentDocumentLink existingContentLink = new ContentDocumentLink(
            LinkedEntityId = testPayslip.Id,
            ContentDocumentId = testContentDocument.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert existingContentLink;

        // Start test execution
        Test.startTest();
        System.enqueueJob(new PayslipToEmployeeDocumentQueueable());
        Test.stopTest();

        // Verify that an Employee Document is created
        List<flair__Employee_Document__c> docs = [
            SELECT Id FROM flair__Employee_Document__c WHERE Employee_Payslip__c = :testPayslip.Id
        ];
        
        System.assertEquals(1, docs.size(), 'An Employee Document should be created.');
    }
}