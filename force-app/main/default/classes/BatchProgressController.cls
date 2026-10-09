public with sharing class BatchProgressController {
    @AuraEnabled
    public static AsyncApexJob getBatchStatus(Id jobId){
        return [
            SELECT Status, JobItemsProcessed, TotalJobItems, NumberOfErrors
            FROM AsyncApexJob
            WHERE Id = :jobId
            LIMIT 1
        ];
    }
}