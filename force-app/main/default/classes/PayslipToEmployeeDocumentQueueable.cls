public class PayslipToEmployeeDocumentQueueable implements Queueable, Database.AllowsCallouts {
    
    public void execute(QueueableContext context) {
        // Process payslips created 5-60 minutes ago (ensures files exist)
        Datetime sixtyMinsAgo = System.now().addMinutes(-120);
        Datetime fiveMinsAgo = System.now().addMinutes(-5);

        List<Employee_Payslip__c> payslips = [
            SELECT Id, Name, Employee__c 
            FROM Employee_Payslip__c 
            WHERE CreatedDate >= :sixtyMinsAgo 
            AND CreatedDate <= :fiveMinsAgo
            AND Id NOT IN (SELECT Employee_Payslip__c FROM flair__Employee_Document__c)
        ];
        
        if (payslips.isEmpty()) return; // Avoid unnecessary processing

        Set<Id> payslipIds = new Set<Id>();
        Map<Id, Id> payslipToFileMap = new Map<Id, Id>();

        for (Employee_Payslip__c payslip : payslips) {
            payslipIds.add(payslip.Id);
        }

        // Find related files for these Payslips
        List<ContentDocumentLink> fileLinks = [
            SELECT ContentDocumentId, LinkedEntityId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId IN :payslipIds
        ];

        for (ContentDocumentLink link : fileLinks) {
            payslipToFileMap.put(link.LinkedEntityId, link.ContentDocumentId);
        }

        // Query the Payroll Document Category
        flair__Document_Category__c payrollCategory;
        try {
            payrollCategory = [
                SELECT Id FROM flair__Document_Category__c WHERE Name = 'Payroll' LIMIT 1
            ];
        } catch (Exception e) {
            System.debug('Error fetching Payroll Document Category: ' + e.getMessage());
            return; // Exit if category is missing
        }

        // Create flair__Employee_Document__c records
        List<flair__Employee_Document__c> newDocuments = new List<flair__Employee_Document__c>();

        for (Employee_Payslip__c payslip : payslips) {
            if (payslipToFileMap.containsKey(payslip.Id)) {
                flair__Employee_Document__c doc = new flair__Employee_Document__c();
                doc.flair__Employee1__c  = payslip.Employee__c;
                doc.Name = payslip.Name;
                doc.Employee_Payslip__c = payslip.Id;
                doc.flair__Document_Category__c = payrollCategory.Id;
                doc.flair__Visibility__c = 'HR_MANAGER_EMPLOYEE';
                doc.flair__Draft__c = false;
                newDocuments.add(doc);
            }
        }

        if (!newDocuments.isEmpty()) {
            insert newDocuments;

            // Link files to new documents
            List<ContentDocumentLink> newFileLinks = new List<ContentDocumentLink>();
            for (flair__Employee_Document__c doc : newDocuments) {
                if (payslipToFileMap.containsKey(doc.Employee_Payslip__c)) {
                    newFileLinks.add(new ContentDocumentLink(
                        LinkedEntityId = doc.Id,
                        ContentDocumentId = payslipToFileMap.get(doc.Employee_Payslip__c),
                        ShareType = 'V' // Viewer access
                    ));
                }
            }

            if (!newFileLinks.isEmpty()) {
                insert newFileLinks;
            }
        }
    }
}