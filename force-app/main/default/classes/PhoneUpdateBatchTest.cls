@isTest
public with sharing class PhoneUpdateBatchTest {
    @isTest
    public static void testPhoneUpdateBatch(){
        List<Contact> contacts = new List<Contact>();
            contacts.add(new Contact(LastName = 'Test Contact1', Phone = null));
            contacts.add(new Contact(LastName = 'Test Contact2', Phone = ''));
            contacts.add(new Contact(LastName = 'Test Contact3', Phone = '456732'));
        
        insert contacts;
        PhoneUpdateBatch batch = new PhoneUpdateBatch();
        Test.startTest();
        Database.executeBatch(batch);
        Test.stopTest();

        List<Contact> updatedContacts = [SELECT Id, LastName, Phone FROM Contact];

        System.assert(updatedContacts[0].Phone != null);
        System.assert(updatedContacts[1].Phone != null);
        System.Assert.areEqual(updatedContacts[2].Phone, '456732');
    }

    @IsTest
    public static void testBulkPhoneUpdateBatch(){
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 200; i++){
            contacts.add(new Contact(LastName = 'Test Contact' + i, Phone = null));
        }
        insert contacts;
        PhoneUpdateBatch batch = new PhoneUpdateBatch();
        Test.startTest();
        Database.executeBatch(batch);
        Test.stopTest();


        List<Contact> updatedContacts = [SELECT Id, LastName, Phone FROM Contact];

        System.assert(updatedContacts[56].Phone != null);
        System.assert(updatedContacts[100].Phone != null);
    }

    
}
        
