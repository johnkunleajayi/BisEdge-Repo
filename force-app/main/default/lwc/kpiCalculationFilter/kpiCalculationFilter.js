import { LightningElement, track, wire } from 'lwc';
import getPerformanceReviewCycles from '@salesforce/apex/KpiCalculationController.getPerformanceReviewCycles';
import getEmployeesByReviewCycle from '@salesforce/apex/KpiCalculationController.getEmployeesByReviewCycle';
import getKpiDetailsByEmployee from '@salesforce/apex/KpiCalculationController.getKpiDetailsByEmployee';

export default class KpiCalculationReview extends LightningElement {
    @track reviewCycleOptions = [];
    @track selectedReviewCycle = '';
    @track employeeList = [];
    @track selectedEmployeeId = '';
    @track selectedEmployeeName = '';
    @track kpiDetails = [];
    @track isKpiVisible = false; // Track if KPI details are visible

    // Define columns for the KPI datatable
    columns = [
        { label: 'KPI No', fieldName: 'Name' },
        { label: 'Key Result Areas', fieldName: 'Question_Test__c' },
        { label: 'Appraisee YE Answer', fieldName: 'Employee_Answer__c' },
        { label: 'Appraisee YE Score', fieldName: 'Score__c' },
        { label: 'Appraisee YE Score %', fieldName: 'Score_Percentage__c' },
        { label: 'Line Manager YE Answer', fieldName: 'Manager_Answer__c' },
        { label: 'Line Manager YE Score', fieldName: 'Manager_Score_Use_This__c' },
        { label: 'Line Manager YE Score %', fieldName: 'Manager_Percentage_Technical__c' },
        { label: 'Appraisee MY Score', fieldName: 'Mid_Year_Score_Employee__c' },
        { label: 'Appraisee MY Score %', fieldName: 'Mid_Year_Percentage_Employee__c' },
        { label: 'Line Manager MY Score', fieldName: 'Mid_Year_Score_Manager__c' },
        { label: 'Line Manager MY Score %', fieldName: 'Mid_Year_Percentage_Manager__c' },
        { label: 'Site Operator Manager Score', fieldName: 'Site_Operator_Manager_Score__c' },
        { label: 'Site Operator Manager Score %', fieldName: 'Site_Operator_Manager_Percentage__c' }
    ];

    // Fetch performance review cycles for the dropdown
    @wire(getPerformanceReviewCycles)
    loadReviewCycles({ error, data }) {
        if (data) {
            this.reviewCycleOptions = data.map(cycle => {
                return { label: cycle, value: cycle };
            });
        } else if (error) {
            console.error('Error loading review cycles:', error);
        }
    }

    // Handle selection change in Performance Review Cycle dropdown
    handleCycleChange(event) {
        this.selectedReviewCycle = event.detail.value;
        this.fetchEmployees();
    }

    // Fetch distinct employees for the selected review cycle
    fetchEmployees() {
        getEmployeesByReviewCycle({ reviewCycle: this.selectedReviewCycle })
            .then(result => {
                this.employeeList = result;
                this.kpiDetails = [];  // Clear previous KPI details
                this.selectedEmployeeName = '';  // Reset selected employee name
                this.isKpiVisible = false; // Reset visibility
            })
            .catch(error => {
                console.error('Error fetching employees:', error);
            });
    }

    // Handle employee name click to fetch or hide KPI details
    handleEmployeeClick(event) {
        const employeeId = event.currentTarget.dataset.id;
        const employee = this.employeeList.find(emp => emp.employeeId === employeeId);
        
        if (this.selectedEmployeeId === employeeId && this.isKpiVisible) {
            // If the same employee is clicked again, toggle visibility off
            this.isKpiVisible = false;
        } else {
            // Set the selected employee and show their KPI details
            this.selectedEmployeeId = employeeId;
            this.selectedEmployeeName = employee.employeeName;
            this.fetchKpiDetails();
            this.isKpiVisible = true; // Show KPI details
        }
    }

    // Fetch KPI details for the selected employee and review cycle
    fetchKpiDetails() {
        getKpiDetailsByEmployee({ employeeId: this.selectedEmployeeId, reviewCycle: this.selectedReviewCycle })
            .then(result => {
                // Map through the results and set any null values to an empty string
                this.kpiDetails = result.map(kpi => {
                    return {
                        ...kpi,
                        Score__c: kpi.Score__c ?? '', // Replace null with empty string
                        Score_Percentage__c: kpi.Score_Percentage__c ?? '',
                        Manager_Score_Use_This__c: kpi.Manager_Score_Use_This__c ?? '',
                        Manager_Percentage_Technical__c: kpi.Manager_Percentage_Technical__c ?? '',
                        Mid_Year_Score_Employee__c: kpi.Mid_Year_Score_Employee__c ?? '',
                        Mid_Year_Percentage_Employee__c: kpi.Mid_Year_Percentage_Employee__c ?? '',
                        Mid_Year_Score_Manager__c: kpi.Mid_Year_Score_Manager__c ?? '',
                        Mid_Year_Percentage_Manager__c: kpi.Mid_Year_Percentage_Manager__c ?? '',
                        Site_Operator_Manager_Score__c: kpi.Site_Operator_Manager_Score__c ?? '',
                        Site_Operator_Manager_Percentage__c: kpi.Site_Operator_Manager_Percentage__c ?? ''
                    };
                });
            })
            .catch(error => {
                console.error('Error fetching KPI details:', error);
            });
    }

}