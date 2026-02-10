@isTest
public with sharing class ReceivingDataTest {
    @isTest
    public static void getContactTest(){
        Contact testContact = new Contact(FirstName = 'test', LastName='test');
        insert testContact;
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/ContactAPI';
        req.httpMethod = 'GET';
        req.params.put('firstName', 'test');
        req.params.put('lastName', 'test');
        RestContext.request = req;
        RestContext.response = new RestResponse();
        Test.startTest();
        ContactWebService.getContact();
        Test.stopTest();
        System.assertEquals(200, RestContext.response.statusCode);
    }
    @isTest
    public static void getContactWithoutParamsTest(){
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/ContactAPI';
        req.httpMethod = 'GET';
        req.params.put('firstName', '');
        req.params.put('lastName', '');
        RestContext.request = req;
        RestContext.response = new RestResponse();
        Test.startTest();
        ContactWebService.getContact();
        Test.stopTest();
        System.assertEquals(400, RestContext.response.statusCode);
    }
    @isTest
    public static void getContactWithWrongURITest(){
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/ContactAP';
        req.httpMethod = 'GET';
        req.params.put('firstName', 'rty');
        req.params.put('lastName', 'uio');
        RestContext.request = req;
        RestContext.response = new RestResponse();
        Test.startTest();
        ContactWebService.getContact();
        Test.stopTest();
        System.assertEquals(404, RestContext.response.statusCode);
    }
    @isTest
    public static void addContactTest(){
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/ContactAPI';
        req.httpMethod = 'POST';
        req.params.put('firstName', 'test');
        req.params.put('lastName', 'test');
        req.requestBody = Blob.valueOf('{"firstName":"test", "lastName":"test"}');
        RestContext.request = req;
        RestContext.response = new RestResponse();
        Test.startTest();
        ContactWebService.addContact();
        Test.stopTest();
        System.assertEquals(201, RestContext.response.statusCode);
    }
    @isTest
    public static void addContactWithoutParamsTest(){
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/ContactAPI';
        req.httpMethod = 'POST';
        req.params.put('firstName', '');
        req.params.put('lastName', '');
        RestContext.request = req;
        RestContext.response = new RestResponse();
        Test.startTest();
        ContactWebService.addContact();
        Test.stopTest();
        System.assertEquals(400, RestContext.response.statusCode);
    }
    @isTest
    public static void deleteContactTest(){
        Contact testContact = new Contact(FirstName = 'test', LastName='test');
        insert testContact;
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/ContactAPI';
        req.httpMethod = 'DELETE';
        req.params.put('firstName', 'test');
        req.params.put('lastName', 'test');
        RestContext.request = req;
        RestContext.response = new RestResponse();
        Test.startTest();
        ContactWebService.deleteContact();
        Test.stopTest();
        System.assertEquals(204, RestContext.response.statusCode);
    }
    @isTest
    public static void deleteContactWithoutParamsTest(){
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/ContactAPI';
        req.httpMethod = 'DELETE';
        req.params.put('firstName', '');
        req.params.put('lastName', '');
        RestContext.request = req;
        RestContext.response = new RestResponse();
        Test.startTest();
        ContactWebService.deleteContact();
        Test.stopTest();
        System.assertEquals(400, RestContext.response.statusCode);
    }
    @isTest
    public static void deleteContactWithWrongURITest(){
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/ContactAP';
        req.httpMethod = 'DELETE';
        req.params.put('firstName', 'vbn');
        req.params.put('lastName', 'asd');
        RestContext.request = req;
        RestContext.response = new RestResponse();
        Test.startTest();
        ContactWebService.deleteContact();
        Test.stopTest();
        System.assertEquals(404, RestContext.response.statusCode);
    }
}