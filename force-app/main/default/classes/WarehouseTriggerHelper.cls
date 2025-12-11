public with sharing class WarehouseTriggerHelper {
    public static void calculateBooks(List<Book1__c> newBooks){
        Set<Id> warehouseIds = new Set<Id>();
        for(Book1__c book : newBooks){
            if(book.Warehouses__c != null)
            warehouseIds.add(book.Warehouses__c);
        }
        if(warehouseIds.isEmpty()) return;

        Map<Id, Integer> counts = new Map<Id, Integer>();

        for(AggregateResult arr : [SELECT Warehouses__c w, COUNT(Id) c FROM Book1__c WHERE Warehouses__c IN :warehouseIds GROUP BY Warehouses__c]){
            counts.put((Id)arr.get('w'), (Integer)arr.get('c'));
        }

        List<Warehouse1__c> warehousesNew = new List<Warehouse1__c>();
        for(Id wId : warehouseIds){
            Warehouse1__c w = new Warehouse1__c(Id = wId, Number_of_books__c = counts.containsKey(wId) ? counts.get(wId) : 0);
            warehousesNew.add(w);
        }
          update warehousesNew;
    }
}
   
