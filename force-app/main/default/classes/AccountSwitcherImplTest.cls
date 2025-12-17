@IsTest
public with sharing class AccountSwitcherImplTest {
    @IsTest
    public static void getAndSortTest(){
        List<Contact> privateContacts = TestFactory.createPrivateContact();
        List<Contact> publicContacts = TestFactory.createPublicContact();
        List<Account> acc = [SELECT Id FROM Account WHERE Name = 'Private Account'];
        Account acc1 = acc[0];
        
        AccountSwitcherImpl switcher = new AccountSwitcherImpl();
        Test.startTest();
        switcher.getAndSort();
        Test.stopTest();

        System.Assert.areEqual(1, privateContacts.size(), 'One private contact');
        System.Assert.areEqual(1, publicContacts.size(), 'One public contact');
    }

    @IsTest
    public static void switchAccountTest(){
    
        List<Contact> privateContacts = TestFactory.createPrivateContact();
        List<Contact> publicContacts = TestFactory.createPublicContact();

        PrivateContact pr = new PrivateContact('Person', privateContacts[0].Amount__c, 114452, privateContacts[0]);
        PublicContact pu = new PublicContact('Person', publicContacts[0].Amount__c, 874536, publicContacts[0]);

        
        AccountSwitcherImpl impl = new AccountSwitcherImpl();
       
        impl.AllContacts.add(pr);
        impl.AllContacts.add(pu);

        
        Test.startTest();
        AccountSwitcherImpl.DataResult dr = impl.switchAccount();
        Test.stopTest();

        
        Contact updatedPrivate = [SELECT AccountId FROM Contact WHERE Id = :privateContacts[0].Id];
        Contact updatedPublic = [SELECT AccountId FROM Contact WHERE Id = :publicContacts[0].Id];

        System.assertEquals(publicContacts[0].AccountId, updatedPrivate.AccountId,'AccountId should change');
        System.assertEquals(privateContacts[0].AccountId, updatedPublic.AccountId,'AccountId should change');

       
        System.assertEquals(1, dr.ChangedPrivateContacts.size(), 'One contact should be in the list');
        System.assertEquals(1, dr.ChangedPublicContacts.size(), 'One contact should be in the list');
        System.assertEquals(0, dr.NonChangedPrivateContacts.size(), 'List is empty');
    
    }

}