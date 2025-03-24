public with sharing class AssignKPIstoEmployees {
    
    @InvocableMethod(label='Assign KPIs to Employees' description='Creates Employee Objectives for each Employee based on a template')
    public static List<List<SObject>> assignKPIstoEmployees(
        List<AssignKPIsRequest> requests
    ) {
        List<List<SObject>> resultsList = new List<List<SObject>>();
        
        // Dynamic SObject type for Employee Objective
        Schema.SObjectType employeeObjectiveSObjectType = 
            Schema.getGlobalDescribe().get('flair__Employee_Objective__c');
        
        if (employeeObjectiveSObjectType == null) {
            throw new AuraHandledException('Custom Object flair__Employee_Objective__c does not exist');
        }
        
        for (AssignKPIsRequest request : requests) {
            // Validate inputs
            if (request.employees == null || request.employees.isEmpty()) {
                throw new AuraHandledException('Employees collection cannot be null or empty');
            }
            
            if (request.templateObjective == null) {
                throw new AuraHandledException('Template Objective cannot be null');
            }
            
            // Collection to hold new Employee Objectives
            List<SObject> varEmployeeObjectiveCollection = 
                new List<SObject>();
            
            // Get the template Employee Objective
            SObject templateObjective = request.templateObjective;
            
            // Loop through each Employee
            for (SObject employee : request.employees) {
                // Create a new Employee Objective for each Employee
                SObject varEmployeeObjective = 
                    employeeObjectiveSObjectType.newSObject();
                
                // Assign values based on the provided mapping
                varEmployeeObjective.put('flair__Company_Objective__c', 
                    templateObjective.get('flair__Company_Objective__c'));
                
                varEmployeeObjective.put('flair__Objective_Time_Period__c', 
                    templateObjective.get('flair__Objective_Time_Period__c'));
                
                varEmployeeObjective.put('flair__Team_Objective__c', 
                    templateObjective.get('flair__Team_Objective__c'));
                
                varEmployeeObjective.put('flair__Owner__c', 
                    templateObjective.get('flair__Owner__c'));
                
                varEmployeeObjective.put('flair__Responsible__c', employee.Id);
                
                varEmployeeObjective.put('flair__Due_Date__c', 
                    templateObjective.get('flair__Due_Date__c'));
                
                varEmployeeObjective.put('flair__Start_Date__c', 
                    templateObjective.get('flair__Start_Date__c'));
                
                varEmployeeObjective.put('flair__Status__c', 
                    templateObjective.get('flair__Status__c'));
                
                varEmployeeObjective.put('flair__Description__c', 
                    templateObjective.get('flair__Description__c'));
                
                // Name generation logic
                String templateName = (String)templateObjective.get('Name');
                String employeeName = (String)employee.get('Name');
                
                if (templateName != null && templateName.contains('Template')) {
                    varEmployeeObjective.put('Name', 
                        templateName.replace('Template', employeeName));
                } else {
                    varEmployeeObjective.put('Name', templateName);
                }
                
                varEmployeeObjective.put('flair__Visibility__c', 
                    templateObjective.get('flair__Visibility__c'));
                
                // Add to collection
                varEmployeeObjectiveCollection.add(varEmployeeObjective);
            }
            
            // Add the collection of new Employee Objectives to the results
            resultsList.add(varEmployeeObjectiveCollection);
        }
        
        // Perform bulk insert of the new Employee Objectives
        if (!resultsList.isEmpty()) {
            List<SObject> objectivesToInsert = 
                new List<SObject>();
            
            for (List<SObject> objectiveList : resultsList) {
                objectivesToInsert.addAll(objectiveList);
            }
            
            if (!objectivesToInsert.isEmpty()) {
                insert objectivesToInsert;
            }
        }
        
        return resultsList;
    }
    
    // Inner class to define the input structure
    public class AssignKPIsRequest {
        @InvocableVariable(label='Employees' description='Collection of Employee records')
        public List<SObject> employees;
        
        @InvocableVariable(label='Template Employee Objective' description='Employee Objective template')
        public SObject templateObjective;
    }
}