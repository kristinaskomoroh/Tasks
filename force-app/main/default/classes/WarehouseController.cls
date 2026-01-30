public with sharing class WarehouseController {
    public static void createRecords() {
        List <Warehouse1__c> warehouses = new List<Warehouse1__c>();
        List<Book1__c> books = new List<Book1__c>();
        List<SObject> records = new List<SObject>(); 
        for(Integer i = 0; i < 5; i++) {
            Integer externalId = 879 + i;
            warehouses.add(new Warehouse1__c(External_Id__c = externalId, Name = 'Warehouse ' + i));
            books.add(new Book1__c(Warehouses__r = new Warehouse1__c(External_Id__c = externalId)));
        }
        
        records.addAll(warehouses); 
        records.addAll(books);
        insert records;
}

    public static List<Book1__c> getBooks() {
        return [SELECT Name, Warehouses__c, Serial_number__c FROM Book1__c];
    }

    public static List<Warehouse1__c> getWarehousesAndBooks() {
         return [SELECT Name, Number_of_books__c, (SELECT Name, Warehouses__c, Serial_number__c FROM Books1__r) FROM Warehouse1__c];
    }
}