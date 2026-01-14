public with sharing class RestResource {

    @TestVisible private static Boolean calloutWasMade = false;


    public static void addContact(String fName, String lName) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Named1/services/apexrest/ContactAPI/');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        Map<String, String> contactData = new Map<String, String>{
        'FirstName' => fName,
        'LastName' => lName
    };
    req.setBody(JSON.serialize(contactData));

    sendRequest(req);
    }
    
    public static void getContact(Id contactId){
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Named1/services/apexrest/ContactAPI/' + contactId);
        req.setMethod('GET');
        sendRequest(req);
    }
    
    public static void deleteContact(Id contactId){
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Named1/services/apexrest/ContactAPI/' + contactId);
        req.setMethod('DELETE');
        sendRequest(req);
    }
    
    public static void sendRequest(HttpRequest req){
        Http http = new Http();
        HttpResponse res = http.send(req);
        calloutWasMade = true;
        System.debug(res.getBody());
        System.debug('Status Code: ' + res.getStatusCode());
        System.debug('Response Body: ' + res.getBody());
    }
}