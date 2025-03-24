import { LightningElement, track, wire } from 'lwc';
import getPerformanceReviewCycles from '@salesforce/apex/KpiCalculationControllerB.getPerformanceReviewCycles';
import getEmployeesByReviewCycle from '@salesforce/apex/KpiCalculationControllerB.getEmployeesByReviewCycle';
import getKpiDetailsByEmployee from '@salesforce/apex/KpiCalculationControllerB.getKpiDetailsByEmployee';

export default class KpiCalculationFilterB extends LightningElement {
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
        { label: 'Appraisee Answer', fieldName: 'Employee_Answer__c' },
        { label: 'Appraisee Score', fieldName: 'Behavioural_Percentage__c' },
        { label: 'Appraisee Score %', fieldName: 'Behavioural_Score_Percentage__c' },
        { label: 'Line Manager Answer', fieldName: 'Manager_Answer__c' },
        { label: 'Line Manager Score', fieldName: 'Manager_Behavioural_Score__c' },
        { label: 'Line Manager Score %', fieldName: 'Percentage_Manager_New__c' }
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
                this.kpiDetails = result;
            })
            .catch(error => {
                console.error('Error fetching KPI details:', error);
            });
    }
}