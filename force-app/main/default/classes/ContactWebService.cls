@RestResource(urlMapping='/ContactAPI/*')
global with sharing class ContactWebService {
   @HttpGet
    global static void getContact() {
       RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');

        try {
           
            String contactId = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
            
            if (String.isBlank(contactId) || contactId == 'ContactAPI') {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf('{"error": "Missing Contact ID in URL"}');
                return;
            }

            List<Contact> contacts = [SELECT Id, FirstName, LastName FROM Contact WHERE Id = :contactId];

            if (!contacts.isEmpty()) {
               
                res.statusCode = 200;
                res.responseBody = Blob.valueOf(JSON.serialize(contacts[0]));
            } else {
                res.statusCode = 404;
                res.responseBody = Blob.valueOf('{"error": "Contact not found"}');
            }
        } catch (Exception e) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf('{"error": "' + e.getMessage() + '"}');
        }
    }
    

    @HttpPost
    global static void addContact() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');

        try {
           
            String requestBody = req.requestBody.toString();
            Contact con = (Contact)JSON.deserialize(requestBody, Contact.class);
            insert con;
            res.statusCode = 201;
            res.responseBody = Blob.valueOf('{"id": "' + con.Id + '", "status": "Success"}');
            
        } catch (Exception e) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf('{"error": "' + e.getMessage() + '"}');
        }
    }
    

    @HttpDelete
    global static void deleteContact(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        try {
            String contactId = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
            
            if (String.isBlank(contactId) || !(contactId instanceof Id)) {
                res.statusCode = 400; 
                res.responseBody = Blob.valueOf('{"Error": "Invalid or missing ID"}');
                return;
            }

            List<Contact> contactsToDelete = [SELECT Id FROM Contact WHERE Id = :contactId];

            if (!contactsToDelete.isEmpty()) {
                delete contactsToDelete;
                res.statusCode = 200; 
                res.responseBody = Blob.valueOf('{"Status": "Deleted successfully"}');
            } else {
                res.statusCode = 404;
                res.responseBody = Blob.valueOf('{"Error": "Contact not found"}');
            }
        } catch (Exception e) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf('{"Error": "' + e.getMessage() + '"}');
        }
    }
        
} 
