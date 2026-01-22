trigger BookTrigger on Book1__c (before insert, after insert, after update) {
    new BookTriggerHandler().run();
}