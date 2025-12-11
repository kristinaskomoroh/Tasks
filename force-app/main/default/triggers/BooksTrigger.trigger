trigger BooksTrigger on Book1__c (before insert) {
    for(Book1__c book : Trigger.new){
        if(book.Serial_number__c == null || book.Serial_number__c == ''){
            book.Serial_number__c = BookTriggerHelper.generateSerialNumber();
        }
    }

    
}