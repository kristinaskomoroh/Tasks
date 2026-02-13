@isTest
public with sharing class ContactIntegrationTest {
    @isTest
    public static void testContactAddCallout() {
        Test.setMock(HttpCalloutMock.class, new ContactWebServiceMock());
        Test.startTest();
        RestResource.addContact('Test', 'Contact');
        Test.stopTest();
        System.assertEquals(1, Limits.getCallouts(),'The callout must be made');
    }
    @IsTest
    public static void testContactGetCallout() {
        Contact testContact = new Contact(FirstName = 'tyu', LastName='qwer');
        insert testContact;
        Test.setMock(HttpCalloutMock.class, new ContactWebServiceMock());
        Test.startTest();
        RestResource.getContact(testContact.FirstName, testContact.LastName);
        Test.stopTest();
        System.assertEquals(true, RestResource.calloutWasMade);
    }
    @IsTest
    public static void testContactDeleteCallout() {
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Loc');
        insert testContact;
        Test.setMock(HttpCalloutMock.class, new ContactWebServiceMock());
        Test.startTest();
        RestResource.deleteContact(testContact.FirstName, testContact.LastName);
        Test.stopTest();
        System.assertEquals(true, RestResource.calloutWasMade);
    }
}