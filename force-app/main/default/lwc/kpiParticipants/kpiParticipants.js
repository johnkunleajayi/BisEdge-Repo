import { LightningElement, track } from 'lwc';
import getKpiResults from '@salesforce/apex/KPIController.getKpiResults';

export default class KpiParticipants extends LightningElement {
    @track employees;
    @track searchTerm = ''; // New tracked property for search term

    columns = [
        { label: 'Site Operator Manager Score', fieldName: 'Site_Operator_Manager_Score__c' },
        { label: 'Employee YE Score', fieldName: 'Employee_Technical_Score_Appraisal_Total__c' },
        { label: 'Manager YE Score', fieldName: 'Manager_Technical_Score__c' },
        { label: 'YE Total Score', fieldName: 'Technical_Score_Technical_Appraisal__c' },
        { label: 'Employee MY Score', fieldName: 'Mid_Year_Score_Technical_Employee__c' },
        { label: 'Manager MY Score', fieldName: 'Mid_Year_Score_Technical_Manager__c' },
        { label: 'MY Total Score', fieldName: 'MID_Year_Total__c' },
        { label: 'Employee Behavioural Appraisal', fieldName: 'Employee_Behavioural_Appraisal__c' },
        { label: 'Manager Behavioural Appraisal', fieldName: 'Manager_Behavioural_Appraisal_Feedback__c' },
        { label: 'Behavioural Total Score', fieldName: 'Total_Scores_Behavioural_Appraisal__c' }
    ];

    connectedCallback() {
        this.loadEmployees();
    }

    loadEmployees() {
        getKpiResults()
            .then(result => {
                this.employees = result.map(emp => ({
                    ...emp,
                    showDetails: false,
                    kpiDetails: [
                        {
                            Site_Operator_Manager_Score__c: emp.Site_Operator_Manager_Score__c,
                            Employee_Technical_Score_Appraisal_Total__c: emp.Employee_Technical_Score_Appraisal_Total__c,
                            Manager_Technical_Score__c: emp.Manager_Technical_Score__c,
                            Technical_Score_Technical_Appraisal__c: emp.Technical_Score_Technical_Appraisal__c,
                            Mid_Year_Score_Technical_Employee__c: emp.Mid_Year_Score_Technical_Employee__c,
                            Mid_Year_Score_Technical_Manager__c: emp.Mid_Year_Score_Technical_Manager__c,
                            MID_Year_Total__c: emp.MID_Year_Total__c,
                            Employee_Behavioural_Appraisal__c: emp.Employee_Behavioural_Appraisal__c,
                            Manager_Behavioural_Appraisal_Feedback__c: emp.Manager_Behavioural_Appraisal_Feedback__c,
                            Total_Scores_Behavioural_Appraisal__c: emp.Total_Scores_Behavioural_Appraisal__c 
                        }
                    ]
                }));
            })
            .catch(error => {
                console.error('Error fetching KPI results:', error);
            });
    }

    // Filtered employees based on the search term
    get filteredEmployees() {
        const searchTerm = this.searchTerm.toLowerCase();
        return this.employees
            ? this.employees.filter(emp => emp.Employee__r.Name.toLowerCase().includes(searchTerm))
            : [];
    }

    // Handle input change for the search term
    handleSearch(event) {
        this.searchTerm = event.target.value;
    }

    toggleDetails(event) {
        const employeeName = event.target.label;
        this.employees = this.employees.map(emp => {
            if (emp.Employee__r.Name === employeeName) {
                emp.showDetails = !emp.showDetails;
            }
            return emp;
        });
    }
}