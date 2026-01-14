@isTest
public with sharing class ContactIntegrationTest {
    @isTest
    public static void testContactAddCallout() {
        Test.setMock( HttpCalloutMock.class, new ContactWebServiceMock());
       RestResource.addContact('Test', 'Contact');
       System.assertEquals(1, Limits.getCallouts(), 'The callout must be made');
    }

    @IsTest
    public static void testContactGetCallout() {
        Contact testContact = new Contact(LastName='qwer');
        insert testContact;
       
        Test.setMock( HttpCalloutMock.class, new ContactWebServiceMock());
        Test.startTest();
        RestResource.getContact(testContact.Id);
        Test.stopTest();
    
        System.assertEquals(true, RestResource.calloutWasMade);
    }
       

    @IsTest
    public static void testContactDeleteCallout() {
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Loc');
        insert testContact;
        Test.setMock( HttpCalloutMock.class, new ContactWebServiceMock());
        Test.startTest();
        RestResource.deleteContact(testContact.Id);
        Test.stopTest();
        System.assertEquals(true, RestResource.calloutWasMade);
}


}