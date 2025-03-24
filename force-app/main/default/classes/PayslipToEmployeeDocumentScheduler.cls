public class PayslipToEmployeeDocumentScheduler implements Schedulable {
    public void execute(SchedulableContext SC) {
        System.enqueueJob(new PayslipToEmployeeDocumentQueueable());
    }
}