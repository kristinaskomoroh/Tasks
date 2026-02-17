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
}