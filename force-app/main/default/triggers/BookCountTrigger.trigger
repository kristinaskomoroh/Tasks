trigger BookCountTrigger on Book1__c (after insert, after update) {
    WarehouseTriggerHelper.calculateBooks(Trigger.new);
}