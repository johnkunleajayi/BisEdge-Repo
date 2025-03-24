public without sharing class EmployeePayslipPDFGenerator {
    
    // Maximum number of records to process in a single future call
    private static final Integer BATCH_SIZE = 50;
    
    // Wrapper class for the input parameters
    public class PayslipRequest {
        @InvocableVariable(required=true label='Employee Payslips')
        public List<Employee_Payslip__c> employeePayslips;
    }
    
    @InvocableMethod(label='Generate Payslip PDF' description='Generates PDF payslips and attaches them to Employee Payslip records')
    public static void generatePayslipPDF(List<PayslipRequest> requests) {
        if (requests == null || requests.isEmpty()) return;
        
        // Get all payslips from the request
        List<Employee_Payslip__c> payslips = requests[0].employeePayslips;
        if (payslips == null || payslips.isEmpty()) return;
        
        // Create a list to store payslip IDs
        List<Id> payslipIds = new List<Id>();
        for(Employee_Payslip__c payslip : payslips) {
            payslipIds.add(payslip.Id);
        }
        
        // Process payslips in batches
        List<List<Id>> batchedPayslipIds = getBatches(payslipIds);
        
        // Call future method for each batch
        for(List<Id> batch : batchedPayslipIds) {
            generatePayslipsFuture(batch);
        }
    }
    
    // Helper method to split records into batches
    private static List<List<Id>> getBatches(List<Id> records) {
        List<List<Id>> batches = new List<List<Id>>();
        Integer totalRecords = records.size();
        
        List<Id> currentBatch = new List<Id>();
        for(Integer i = 0; i < totalRecords; i++) {
            currentBatch.add(records[i]);
            
            if(currentBatch.size() == BATCH_SIZE || i == totalRecords - 1) {
                batches.add(currentBatch);
                currentBatch = new List<Id>();
            }
        }
        
        return batches;
    }
    
    @Future(callout=true)
    private static void generatePayslipsFuture(List<Id> payslipIds) {
        // Create a list to track any errors
        List<Database.SaveResult> saveResults = new List<Database.SaveResult>();
        Map<Id, String> errorsByPayslipId = new Map<Id, String>();
        
        // Query all payslips in the batch
        List<Employee_Payslip__c> payslips = queryPayslips(payslipIds);
        
        // Process each payslip
        for (Employee_Payslip__c payslip : payslips) {
            try {
                generateAndAttachPDF(payslip);
            } catch (Exception e) {
                String errorMsg = 'Error generating PDF for payslip ' + payslip.Id + ': ' + e.getMessage();
                errorsByPayslipId.put(payslip.Id, errorMsg);
                System.debug(LoggingLevel.ERROR, errorMsg);
                System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
            }
        }
        
        // Log any errors for monitoring
        if (!errorsByPayslipId.isEmpty()) {
            logErrors(errorsByPayslipId);
        }
    }
    
    private static List<Employee_Payslip__c> queryPayslips(List<Id> payslipIds) {
        try {
            return [
                SELECT 
                    Id, 
                    Name, 
                    Employee__r.Name,
                    Employee_Designation__c, 
                    Payroll_Period__c,
                    Payment_Date__c, 
                    Attendance__c,
                    Staff_ID_Location__c, 
                    Basic_Salary__c,
                    Transport_Allowance__c, 
                    Housing_Allowance__c,
                    Leave_Allowance__c, 
                    Other_Allowance__c,
                    Overtime_Allowance_I__c, 
                    Overtime_Allowance_II__c,
                    Public_Holidays_Allowance__c, 
                    Employer_Pension_Contribution__c,
                    Employee_Pension_Contribution__c, 
                    Tax_Remittance__c,
                    NHF_Contribution__c, 
                    Total_Gross_Salary__c,
                    Total_Net_Payment__c
                FROM Employee_Payslip__c
                WHERE Id IN :payslipIds
                WITH SECURITY_ENFORCED
            ];
        } catch (QueryException qe) {
            String errorMsg = 'Failed to query payslip records: ' + qe.getMessage();
            System.debug(LoggingLevel.ERROR, errorMsg);
            throw new PayslipGenerationException(errorMsg);
        }
    }
    
    private static void generateAndAttachPDF(Employee_Payslip__c payslip) {
        // Generate PDF
        PageReference pdf = Page.EmployeePayslipPDFTemplate;
        pdf.getParameters().put('id', payslip.Id);
        pdf.setRedirect(true);
        
        // Create ContentVersion
        ContentVersion cv = new ContentVersion();
        cv.Title = payslip.Name;
        cv.PathOnClient = payslip.Name + '.pdf';
        cv.IsMajorVersion = true;
        
        try {
            // Get PDF content
            Blob pdfBlob;
            if (Test.isRunningTest()) {
                pdfBlob = Blob.valueOf('Test PDF Content');
            } else {
                pdfBlob = pdf.getContentAsPDF();
            }
            
            cv.VersionData = pdfBlob;
            insert cv;
            
            // Get ContentDocument Id
            Id conDocId = [
                SELECT ContentDocumentId 
                FROM ContentVersion 
                WHERE Id = :cv.Id
                WITH SECURITY_ENFORCED
            ].ContentDocumentId;
            
            // Create ContentDocumentLink
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = conDocId;
            cdl.LinkedEntityId = payslip.Id;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            insert cdl;
            
        } catch (Exception e) {
            String errorMsg = 'Failed to generate payslip PDF: ' + e.getMessage() + 
                            '\nStack trace: ' + e.getStackTraceString();
            System.debug(LoggingLevel.ERROR, errorMsg);
            throw new PayslipGenerationException(errorMsg);
        }
    }
    
    private static void logErrors(Map<Id, String> errorsByPayslipId) {
        // You can implement custom error logging here
        // For example, creating Error_Log__c records or sending email notifications
        for(Id payslipId : errorsByPayslipId.keySet()) {
            System.debug(LoggingLevel.ERROR, 'Payslip ' + payslipId + ': ' + errorsByPayslipId.get(payslipId));
        }
    }
    
    public class PayslipGenerationException extends Exception {}
}