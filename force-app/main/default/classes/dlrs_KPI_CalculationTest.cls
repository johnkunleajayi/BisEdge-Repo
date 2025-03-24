/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_KPI_CalculationTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_KPI_CalculationTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new KPI_Calculation__c());
    }
}