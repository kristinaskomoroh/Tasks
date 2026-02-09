@IsTest
public with sharing class TestFactory {
    @IsTest
    public static List<Contact> createPrivateContact() {
        Account acc1 = new Account(Name = 'Private Account');
        insert acc1;
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(LastName = 'test1Last', FirstName = 'test1First', Amount__c = 78664, AccountId = acc1.Id));
        insert contacts;
        return contacts;
    }
    @IsTest
    public static List<Contact> createPublicContact() {
        Account acc2 = new Account(Name = 'Public Account');
        insert acc2;
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(LastName = 'test3Last', FirstName = 'test3First', Amount__c = 78, AccountId = acc2.Id));
        insert contacts;
        return contacts;
    }
}