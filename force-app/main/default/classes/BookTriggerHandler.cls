public with sharing class BookTriggerHandler extends TriggerHandler {
    public override void beforeInsert(){
        setSerialNumber();
    }

    public override void afterInsert(){
        countBooks();
    }

    public override void afterUpdate(){
        countBooks();
    }
    
    private void setSerialNumber(){
        for(Book1__c book : (List<Book1__c>) Trigger.new){
            if(book.Serial_number__c == null || book.Serial_number__c == ''){
                book.Serial_number__c = BookTriggerHelper.generateSerialNumber();
            }
        }
    }

    private void countBooks(){
        WarehouseTriggerHelper.calculateBooks(Trigger.new);
    }

}