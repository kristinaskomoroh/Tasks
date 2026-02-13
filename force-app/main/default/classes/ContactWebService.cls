@RestResource(urlMapping='/ContactAPI/*')
global with sharing class ContactWebService {
    @HttpGet
    global static void getContact() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        try {
            String firstName= req.params.get('firstName');
            String lastName = req.params.get('lastName');
            if (String.isBlank(firstName) || String.isBlank(lastName)) {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf('{"Error": "Contact not found"}');
                return;
            }
            List<Contact> contacts = [SELECT Id, FirstName, LastName FROM Contact WHERE FirstName = :firstName AND LastName = :lastName LIMIT 100];
            if (!contacts.isEmpty()) {
                res.statusCode = 200;
                res.responseBody = Blob.valueOf(JSON.serialize(contacts));
            } else{
                res.statusCode = 404;
                res.responseBody = Blob.valueOf('{"Error": "Contact not found"}');
            }
        } catch (Exception e) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf('{"Error": "' + e.getMessage() + '"}');
        }
    }
    @HttpPost
    global static void addContact() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        try {
            String requestBody = req.requestBody.toString();
            List<Contact> contactsToInsert = new List<Contact>();
            if (requestBody.startsWith('[')) {
                contactsToInsert = (List<Contact>)JSON.deserialize(requestBody, List<Contact>.class);
            } else {
                Contact singleContact = (Contact)JSON.deserialize(requestBody, Contact.class);
                contactsToInsert.add(singleContact);
            }
            insert contactsToInsert;
            res.statusCode = 201;
            res.responseBody = Blob.valueOf('{"Status": "Created successfully"}');
        } catch (Exception e) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf('{"Error": "' + e.getMessage() + '"}');
        }
    }
    @HttpDelete
    global static void deleteContact(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try {
            String firstName= req.params.get('firstName');
            String lastName = req.params.get('lastName');
            if (String.isBlank(firstName) || String.isBlank(lastName)) {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf('{"Error": "Contact not found"}');
                return;
            }
            List<Contact> contactsToDelete = [SELECT Id, FirstName, LastName FROM Contact WHERE FirstName = :firstName AND LastName = :lastName LIMIT 100];
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