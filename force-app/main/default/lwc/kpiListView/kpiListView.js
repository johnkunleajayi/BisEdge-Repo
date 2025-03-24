import { LightningElement, track } from 'lwc'; 
import getKpiResults from '@salesforce/apex/KPIController.getKpiResults';

export default class KpiParticipants extends LightningElement {
    @track employees;

    connectedCallback() {
        this.loadEmployees();
    }

    loadEmployees() {
        getKpiResults()
            .then(result => {
                this.employees = result.map(emp => ({
                    ...emp,
                    showDetails: false
                }));
            })
            .catch(error => {
                console.error('Error fetching KPI results:', error);
            });
    }

    toggleDetails(event) {
        const employeeId = event.target.dataset.id;
        this.employees = this.employees.map(emp => {
            if (emp.Id === employeeId) {
                emp.showDetails = !emp.showDetails;
            }
            return emp;
        });
    }
}