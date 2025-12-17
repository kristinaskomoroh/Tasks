public class AccountSwitcherImpl implements AccountSwitcher {

    public List<Type> AllContacts = new List<Type>();
    

    public class DataResult {
        public List<PrivateContact> ChangedPrivateContacts = new List<PrivateContact>();
        public List<PublicContact> ChangedPublicContacts = new List<PublicContact>();  
        public List<PrivateContact> NonChangedPrivateContacts = new List<PrivateContact>();

}

    public AccountSwitcherImpl.DataResult switchAccount() {
        List<PrivateContact> privateContacts = new List<PrivateContact>();
        List<PublicContact> publicContacts = new List<PublicContact>();
       
        AccountSwitcherImpl.DataResult dr = new DataResult();
        
        for(Type t : AllContacts){
            if(t instanceof PrivateContact){
                privateContacts.add((PrivateContact)t);
            }
            else {
                publicContacts.add((PublicContact)t);
            }  
        }

        for(Integer i = 0; i < privateContacts.size(); i++){
            PrivateContact privateItem = privateContacts[i];
            PublicContact publicItem = publicContacts[i];
            
            if(privateItem.getContactType() == 'Premier')
            {
                dr.NonChangedPrivateContacts.add(privateItem);
                continue;
            }
           else{
               Id tempAccountId =  privateItem.getContactRecord().AccountId;
               privateItem.getContactRecord().AccountId = publicItem.getContactRecord().AccountId;
               publicItem.getContactRecord().AccountId = tempAccountId;
            }
            dr.ChangedPrivateContacts.add(privateItem);
            dr.ChangedPublicContacts.add(publicItem);
        }

        if(privateContacts.size() != publicContacts.size()){
            System.debug('Different number of contacts');
        }
            

        List<Contact> contactsToUpdate = new List<Contact>();
        for(PrivateContact privateC : dr.ChangedPrivateContacts){
            contactsToUpdate.add(privateC.getContactRecord());
        }

        for(PublicContact publicC : dr.ChangedPublicContacts){
            contactsToUpdate.add(publicC.getContactRecord());
        }

        try{
            update contactsToUpdate;
            System.debug('Contacts updated');
        }
        catch(DMLException e){
            System.debug('DML Error' + e.getMessage());
        }
        return dr;
    }


    
    public void getAndSort() {
        List<Contact> contacts = [SELECT Id, LastName, FirstName, Amount__c, AccountId FROM Contact WHERE Amount__c != null ];
        for(Contact c : contacts){
            if(c.Amount__c > 10000){
                PrivateContact pc = new PrivateContact('', 0.0, 0, c);
                pc.setContactRecord(c);
                pc.getAmountOfMoney();
                pc.randomCardNumber();
                this.AllContacts.add(pc);

            }
            else {
                PublicContact pb = new PublicContact('', 0.0, 0, c);
                pb.setContactRecord(c);
                pb.randomVolunteerNumber();
                pb.getAmountOfMoney();
                this.AllContacts.add(pb);
            }   
        }
    }
}