@IsTest
public class EmployeePayslipPDFGeneratorTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test employees
        List<Employee_Payslip__c> payslips = new List<Employee_Payslip__c>();
        for (Integer i = 0; i < 5; i++) { // Creating 5 sample records
            Employee_Payslip__c payslip = new Employee_Payslip__c(
                Name = 'Payslip ' + i,
                Attendance__c = '30 out of 30 days',
                Overtime_Allowance_I__c = 200 + (i*5),
                Overtime_Allowance_II__c = 300 + (i*10),
                Public_Holidays_Allowance__c = 400 + (i*15),
                Payment_Date__c = Date.today()
            );
            payslips.add(payslip);
        }
        insert payslips;
    }

    @IsTest
    static void testGeneratePayslipPDF() {
        // Retrieve test payslips
        List<Employee_Payslip__c> testPayslips = [
            SELECT Id, Name FROM Employee_Payslip__c
        ];
        
        System.assert(!testPayslips.isEmpty(), 'Test payslips should be created.');

        // Create request wrapper
        EmployeePayslipPDFGenerator.PayslipRequest request = new EmployeePayslipPDFGenerator.PayslipRequest();
        request.employeePayslips = testPayslips;

        // Wrap in list
        List<EmployeePayslipPDFGenerator.PayslipRequest> requests = new List<EmployeePayslipPDFGenerator.PayslipRequest>{ request };

        // Call the method
        Test.startTest();
        EmployeePayslipPDFGenerator.generatePayslipPDF(requests);
        Test.stopTest();

        // Verify ContentVersion records (PDFs should be created)
        List<ContentVersion> pdfs = [
            SELECT Id, Title 
            FROM ContentVersion 
            WHERE Title LIKE 'Payslip%'
        ];
        
        System.assert(!pdfs.isEmpty(), 'PDF attachments should be created.');
        
        // Ensure all payslip IDs are gathered for filtering
        Set<Id> payslipIds = new Set<Id>();
        for (Employee_Payslip__c p : testPayslips) {
            payslipIds.add(p.Id);
        }

        // ✅ FIXED QUERY: Uses IN to filter multiple records
        List<ContentDocumentLink> links = [
            SELECT Id, LinkedEntityId 
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :payslipIds
        ];
        
        System.assert(!links.isEmpty(), 'PDFs should be linked to payslip records.');
    }
}