public class DateRangeGenerator {
    
    @InvocableMethod(label='Generate Date Range' description='Returns a list of dates between start and end dates')
    public static List<List<Datetime>> generateDateRange(List<DateRangeRequest> requests) {
        List<List<Datetime>> resultsToReturn = new List<List<Datetime>>();
        
        // Input validation
        if (requests == null || requests.isEmpty()) {
            System.debug('Error: No requests received');
            return resultsToReturn;
        }
        
        for (DateRangeRequest request : requests) {
            // Validate request parameters
            if (request.startDate == null || request.endDate == null) {
                System.debug('Error: Start date or end date is null');
                continue;
            }
            
            if (request.endDate < request.startDate) {
                System.debug('Error: End date is before start date');
                continue;
            }
            
            Datetime startDate = request.startDate;
            Datetime endDate = request.endDate;
            
            System.debug('Start Date: ' + startDate);
            System.debug('End Date: ' + endDate);
            
            List<Datetime> daysList = new List<Datetime>();
            
            // Calculate days difference
            Long millisDiff = endDate.getTime() - startDate.getTime();
            Integer numberOfDays = Integer.valueOf(Math.floor(millisDiff / (1000.0 * 60 * 60 * 24))) + 1;
            
            System.debug('Number of days calculated: ' + numberOfDays);
            
            // Generate each day
            for (Integer i = 0; i < numberOfDays; i++) {
                Datetime currentDay = startDate.addDays(i);
                daysList.add(currentDay);
                System.debug('Added day: ' + currentDay);
            }
            
            resultsToReturn.add(daysList);
            System.debug('Size of daysList: ' + daysList.size());
        }
        
        System.debug('Final result size: ' + resultsToReturn.size());
        return resultsToReturn;
    }
    
    public class DateRangeRequest {
        @InvocableVariable(required=true label='Start Date' description='The start datetime')
        public Datetime startDate;
        
        @InvocableVariable(required=true label='End Date' description='The end datetime')
        public Datetime endDate;
    }
}