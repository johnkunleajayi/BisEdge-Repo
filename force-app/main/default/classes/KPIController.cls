/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-17-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class KPIController {
   @AuraEnabled(cacheable=true)
    public static List<KPI_Result__c> getKpiResults() {
        return [
            SELECT Employee__r.Name, Manager_Technical_Score__c, Employee_Technical_Score_Appraisal_Total__c, 
                   Technical_Score_Technical_Appraisal__c, Employee_Behavioural_Appraisal__c, 
                   Manager_Behavioural_Appraisal_Feedback__c, Total_Scores_Behavioural_Appraisal__c, 
                   Organisation_Ratio_Technical_Appraisal__c, Organisation_Ratio_Behavioural_Appraisal__c, 
                   Technical_Overall_Score__c, Behavioural_Overall_Score__c, Final_Rating__c, Grade__c 
            FROM KPI_Result__c
        ];
    }
}