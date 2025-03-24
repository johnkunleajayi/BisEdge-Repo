public class EmployeeShiftAnalyzer {
    public class ShiftAnalysisRequest {
        @InvocableVariable(required=true label='DateTime Collection')
        public List<Datetime> dateTimeCollection;
        
        @InvocableVariable(required=true label='Employee Shifts')
        public List<SObject> employeeShifts;
        
        @InvocableVariable(required=true label='Location Employees')
        public List<SObject> locationEmployees;
    }
    
    public class ShiftAnalysisResult {
        @InvocableVariable(label='Morning Shifts')
        public List<SObject> morningShifts;
        
        @InvocableVariable(label='Afternoon Shifts')
        public List<SObject> afternoonShifts;
        
        @InvocableVariable(label='Night Shifts')
        public List<SObject> nightShifts;
        
        @InvocableVariable(label='Morning Shifts Count')
        public Integer morningShiftsCount;
        
        @InvocableVariable(label='Afternoon Shifts Count')
        public Integer afternoonShiftsCount;
        
        @InvocableVariable(label='Night Shifts Count')
        public Integer nightShiftsCount;
        
        @InvocableVariable(label='Count of Off Employees')
        public Integer offEmployeesCount;
        
        @InvocableVariable(label='Count of Location Employees')
        public Integer locationEmployeesCount;
        
        @InvocableVariable(label='Shifts Summary')
        public String shiftsSummary;
    }
    
    @InvocableMethod(label='Analyze Employee Shifts' description='Categorizes shifts and generates summary')
    public static List<ShiftAnalysisResult> analyzeShifts(List<ShiftAnalysisRequest> requests) {
        List<ShiftAnalysisResult> results = new List<ShiftAnalysisResult>();
        
        for (ShiftAnalysisRequest request : requests) {
            ShiftAnalysisResult result = processShifts(
                request.dateTimeCollection, 
                request.employeeShifts, 
                request.locationEmployees
            );
            results.add(result);
        }
        
        return results;
    }
    
    private static ShiftAnalysisResult processShifts(
        List<Datetime> dateTimeCollection, 
        List<SObject> employeeShifts,
        List<SObject> locationEmployees
    ) {
        ShiftAnalysisResult result = new ShiftAnalysisResult();
        
        // Initialize collections
        result.morningShifts = new List<SObject>();
        result.afternoonShifts = new List<SObject>();
        result.nightShifts = new List<SObject>();
        
        // Set location employees count
        result.locationEmployeesCount = locationEmployees.size();
        
        // Start building HTML table with compact styling
        String htmlTable = '<table style="border-collapse: collapse; width: auto; font-size: 12px; font-family: Arial, sans-serif;">\n';
        
        // Add header row
        htmlTable += '<tr style="border: 1px solid black;">' + 
                    '<th style="border: 1px solid black; padding: 4px; text-align: left; background-color: #f2f2f2;">Date</th>';
        for (Datetime dt : dateTimeCollection) {
            htmlTable += '<th style="border: 1px solid black; padding: 4px; text-align: center; background-color: #f2f2f2;">' + 
                        dt.format('MM/dd/yyyy') + '</th>';
        }
        htmlTable += '</tr>\n';
        
        // Process data and build rows
        Map<Date, Map<String, Integer>> shiftCounts = new Map<Date, Map<String, Integer>>();
        
        // Initialize counts for each date
        for (Datetime dt : dateTimeCollection) {
            Date currentDate = dt.date();
            shiftCounts.put(currentDate, new Map<String, Integer>{
                'morning' => 0,
                'afternoon' => 0,
                'night' => 0
            });
        }
        
        // Count shifts for each date
        for (SObject shift : employeeShifts) {
            Datetime shiftStartDateTime = (Datetime)shift.get('flair__Start_Datetime__c');
            Date shiftDate = shiftStartDateTime.date();
            
            if (shiftCounts.containsKey(shiftDate)) {
                Time shiftTime = shiftStartDateTime.time();
                Map<String, Integer> dateCounts = shiftCounts.get(shiftDate);
                
                if (shiftTime <= Time.newInstance(9, 0, 0, 0)) {
                    dateCounts.put('morning', dateCounts.get('morning') + 1);
                    result.morningShifts.add(shift);
                } else if (shiftTime >= Time.newInstance(14, 0, 0, 0) && 
                          shiftTime < Time.newInstance(18, 0, 0, 0)) {
                    dateCounts.put('afternoon', dateCounts.get('afternoon') + 1);
                    result.afternoonShifts.add(shift);
                } else if (shiftTime >= Time.newInstance(18, 0, 0, 0)) {
                    dateCounts.put('night', dateCounts.get('night') + 1);
                    result.nightShifts.add(shift);
                }
            }
        }
        
        // CSS styles for cells
        String cellStyle = 'border: 1px solid black; padding: 4px; text-align: center;';
        String headerCellStyle = 'border: 1px solid black; padding: 4px; font-weight: bold;';
        
        // Add Morning row
        htmlTable += '<tr style="border: 1px solid black;">' + 
                    '<td style="' + headerCellStyle + '">Morning</td>';
        for (Datetime dt : dateTimeCollection) {
            Integer count = shiftCounts.get(dt.date()).get('morning');
            htmlTable += '<td style="' + cellStyle + '">' + count + '</td>';
        }
        htmlTable += '</tr>\n';
        
        // Add Afternoon row
        htmlTable += '<tr style="border: 1px solid black;">' + 
                    '<td style="' + headerCellStyle + '">Afternoon</td>';
        for (Datetime dt : dateTimeCollection) {
            Integer count = shiftCounts.get(dt.date()).get('afternoon');
            htmlTable += '<td style="' + cellStyle + '">' + count + '</td>';
        }
        htmlTable += '</tr>\n';
        
        // Add Night row
        htmlTable += '<tr style="border: 1px solid black;">' + 
                    '<td style="' + headerCellStyle + '">Night</td>';
        for (Datetime dt : dateTimeCollection) {
            Integer count = shiftCounts.get(dt.date()).get('night');
            htmlTable += '<td style="' + cellStyle + '">' + count + '</td>';
        }
        htmlTable += '</tr>\n';
        
        // Add Off Employees row
        htmlTable += '<tr style="border: 1px solid black; background-color: #fff0f0;">' + 
                    '<td style="' + headerCellStyle + '">Off</td>';
        for (Datetime dt : dateTimeCollection) {
            Map<String, Integer> dateCounts = shiftCounts.get(dt.date());
            Integer totalWorkingCount = dateCounts.get('morning') + 
                                      dateCounts.get('afternoon') + 
                                      dateCounts.get('night');
            Integer offCount = result.locationEmployeesCount - totalWorkingCount;
            htmlTable += '<td style="' + cellStyle + '">' + offCount + '</td>';
        }
        htmlTable += '</tr>\n';
        
        // Add Total row (Working + Off Employees)
        htmlTable += '<tr style="border: 1px solid black; background-color: #f9f9f9;">' + 
                    '<td style="' + headerCellStyle + '">Total</td>';
        for (Datetime dt : dateTimeCollection) {
            // Total should always equal locationEmployeesCount (Working + Off)
            htmlTable += '<td style="' + cellStyle + '"><strong>' + result.locationEmployeesCount + '</strong></td>';
        }
        htmlTable += '</tr>\n';
        
        // Close table
        htmlTable += '</table>';
        
        result.shiftsSummary = htmlTable;
        return result;
    }
}