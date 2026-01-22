
public with sharing class AccountSearchRecords {
    public class AccountWrapper{
        @AuraEnabled public String accName; 
        @AuraEnabled public List<String> contactNames;

        public AccountWrapper(String name, List<String> contacts){
            this.accName = name;
            this.contactNames = contacts;
        }
    }
    @AuraEnabled
    public static String searchAccounts(String searchItem){
        if(String.isBlank(searchItem)){
            return '{"Search item is empty"}';
        }
        List<AccountWrapper> wrappers = new List<AccountWrapper>();
        String query = '%' + searchItem + '%';
        List<Account> accounts = [SELECT Id, Name, (SELECT Name FROM Contacts) FROM Account WHERE Name LIKE :query LIMIT 10];

        for(Account acc : accounts){
            List<String> contactsName = new List<String>();
            for(Contact con : acc.Contacts){
                contactsName.add(con.Name);
            }
            wrappers.add(new AccountWrapper(acc.Name, contactsName));
        }
        return JSON.serialize(wrappers);
        
    }

    /*public String searchContacts(String accountName){
        Http = new Http();
        HttpRequest req = new HttpRequest();
        

        String endPoint = 'https://orgfarm-ca36717993-dev-ed.develop.my.salesforce.com' + accountName;
        req.setEndpoint(endPoint);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
         try {
            HttpResponse res = new HttpResponse();
            res = http.send(req);
            if (res.getStatusCode() == 200) {
               List<AccountWrapper> results = (List<AccountWrapper>)JSON.deserialize(res.getBody(), List<AccountWrapper>.class);
               return JSON.serialize(results);
            } else {
                return '{"error": "Server returned status ' + response.getStatusCode() + '"}';
            }
        } catch (Exception e) {
            return '{"error": "' + e.getMessage() + '"}';
        }
    }*/
}