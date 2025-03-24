public with sharing class KpiCalculationControllerB {

    // Method to retrieve distinct performance review cycles containing "Behavioural"
@AuraEnabled(cacheable=true)
public static List<String> getPerformanceReviewCycles() {
    // Retrieve Performance Review Cycles with "Behavioural" in the name
    List<KPI_Calculation__c> records = [
        SELECT Performance_Review_Cycle__c 
        FROM KPI_Calculation__c 
        WHERE Performance_Review_Cycle__c LIKE '%Behavioural%'
    ];

    // Use a Set to store unique values
    Set<String> uniqueReviewCycles = new Set<String>();

    // Add each Performance Review Cycle to the Set for uniqueness
    for (KPI_Calculation__c record : records) {
        if (record.Performance_Review_Cycle__c != null) {
            uniqueReviewCycles.add(record.Performance_Review_Cycle__c);
        }
    }

    // Return the unique values as a list
    return new List<String>(uniqueReviewCycles);
}


    // Method to get unique employees for a specific performance review cycle containing "Behavioural"
@AuraEnabled(cacheable=true)
public static List<EmployeeWrapper> getEmployeesByReviewCycle(String reviewCycle) {
    // Retrieve records for the specific Performance Review Cycle with "Behavioural" in the name
    List<KPI_Calculation__c> records = [
        SELECT Employee_Lookup__c, Employee_Lookup__r.Name 
        FROM KPI_Calculation__c 
        WHERE Performance_Review_Cycle__c = :reviewCycle AND Performance_Review_Cycle__c LIKE '%Behavioural%'
    ];

    // Use a Map to store unique Employee IDs and Names
    Map<Id, String> uniqueEmployees = new Map<Id, String>();

    // Populate the Map with unique employees
    for (KPI_Calculation__c record : records) {
        if (record.Employee_Lookup__c != null) {
            uniqueEmployees.put(record.Employee_Lookup__c, record.Employee_Lookup__r.Name);
        }
    }

    // Convert the Map entries into a list of EmployeeWrapper instances
    List<EmployeeWrapper> employees = new List<EmployeeWrapper>();
    for (Id employeeId : uniqueEmployees.keySet()) {
        employees.add(new EmployeeWrapper(employeeId, uniqueEmployees.get(employeeId)));
    }

    return employees;
}


    // Method to retrieve KPI details for a specific employee with "Behavioural" in the performance review cycle
@AuraEnabled
public static List<KPI_Calculation__c> getKpiDetailsByEmployee(Id employeeId, String reviewCycle) {
    // Query to retrieve KPI details for the specific employee and review cycle containing "Behavioural"
    return [
        SELECT Id, Question_Test__c, Employee_Answer__c, Behavioural_Percentage__c, 
               Behavioural_Score_Percentage__c, Manager_Answer__c,
               Manager_Behavioural_Score__c, Percentage_Manager_New__c, 
               Name
        FROM KPI_Calculation__c
        WHERE Employee_Lookup__c = :employeeId 
              AND Performance_Review_Cycle__c = :reviewCycle
              AND Performance_Review_Cycle__c LIKE '%Behavioural%'
    ];
}



    // Wrapper class to hold Employee ID and Name
    public class EmployeeWrapper {
        @AuraEnabled public Id employeeId;
        @AuraEnabled public String employeeName;

        public EmployeeWrapper(Id employeeId, String employeeName) {
            this.employeeId = employeeId;
            this.employeeName = employeeName;
        }
    }
}