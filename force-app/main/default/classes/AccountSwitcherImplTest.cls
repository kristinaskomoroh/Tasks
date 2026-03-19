@IsTest
public with sharing class AccountSwitcherImplTest {
    @IsTest
    public static void getAndSortTest(){
        List<Contact> privateContacts = TestFactory.createPrivateContact();
        List<Contact> publicContacts = TestFactory.createPublicContact();
        AccountSwitcherImpl switcher = new AccountSwitcherImpl();
        switcher.getAndSort();
        System.assertEquals(1, privateContacts.size(), 'One private contact');
        System.assertEquals(1, publicContacts.size(), 'One public contact');
    }

    @IsTest
    public static void switchAccountTest(){
        List<Contact> privateContacts = TestFactory.createPrivateContact();
        List<Contact> publicContacts = TestFactory.createPublicContact();
        Id originalPrivateAccountId = privateContacts[0].AccountId;
        Id originalPublicAccountId = publicContacts[0].AccountId;
        PrivateContact pr = new PrivateContact('Person', privateContacts[0].Amount__c, 114452, privateContacts[0]);
        PublicContact pu = new PublicContact('Person', publicContacts[0].Amount__c, 874536, publicContacts[0]);
        AccountSwitcherImpl impl = new AccountSwitcherImpl();
        impl.allContacts.add(pr);
        impl.allContacts.add(pu);
        AccountSwitcherImpl.DataResult dr = impl.switchAccount();
        Contact updatedPrivate = [SELECT AccountId FROM Contact WHERE Id = :privateContacts[0].Id];
        Contact updatedPublic = [SELECT AccountId FROM Contact WHERE Id = :publicContacts[0].Id];
        System.assertEquals(originalPublicAccountId, updatedPrivate.AccountId, 'Private should have Publics old Account');
        System.assertEquals(originalPrivateAccountId, updatedPublic.AccountId, 'Public should have Privates old Account');
        System.assertEquals(1, dr.ChangedPrivateContacts.size(), 'One contact should be in the list');
        System.assertEquals(1, dr.ChangedPublicContacts.size(), 'One contact should be in the list');
        System.assertEquals(0, dr.NonChangedPrivateContacts.size(), 'List is empty');
    }
}