@isTest
public with sharing class ContactWebServiceMock implements HttpCalloutMock {
    public HttpResponse respond( HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        if (req.getMethod() == 'POST') {
            res.setBody('{"Status": "Created"}');
            res.setStatusCode(201);
        } else if (req.getMethod() == 'GET') {
            res.setBody('{"FirstName": ", "LastName": "}');
            res.setStatusCode(200);
        }else if (req.getMethod() == 'DELETE') {
            res.setBody('');
            res.setStatusCode(204);
        }
        else {
            res.setStatusCode(405);
            res.setBody('{"Error": "Method not allowed"}');
        }
        return res;
    }
}