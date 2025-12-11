public class VehicleController {
    public static void createVehicle(){
        Contact ownerContact = [SELECT ID FROM Contact WHERE LastName = 'sk'];
        Id contactId = ownerContact.Id;
        List<Vehicle__c> vehicles = new List<Vehicle__c>();
        for(Integer i = 0; i<5; i++){
            vehicles.add(new Vehicle__c(Price__c = 20 + i, Discount__c = 10, Registration_number__c = '123456789', Vehicle_Owner__c = contactId));
                }
       insert vehicles;
    }

}