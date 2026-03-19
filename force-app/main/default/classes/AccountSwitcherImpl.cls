public class AccountSwitcherImpl implements AccountSwitcher {

    public List<Type> allContacts = new List<Type>();
    
    public class DataResult {
        public List<PrivateContact> changedPrivateContacts = new List<PrivateContact>();
        public List<PublicContact> changedPublicContacts = new List<PublicContact>();  
        public List<PrivateContact> nonChangedPrivateContacts = new List<PrivateContact>();
    }

    public AccountSwitcherImpl.DataResult switchAccount() {
        List<PrivateContact> privateContacts = new List<PrivateContact>();
        List<PublicContact> publicContacts = new List<PublicContact>();
       
        AccountSwitcherImpl.DataResult dr = new DataResult();
        
        for(Type t : allContacts){
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
                dr.nonChangedPrivateContacts.add(privateItem);
            }
            else{
               Id tempAccountId =  privateItem.getContactRecord().AccountId;
               privateItem.getContactRecord().AccountId = publicItem.getContactRecord().AccountId;
               publicItem.getContactRecord().AccountId = tempAccountId;
            }
            dr.changedPrivateContacts.add(privateItem);
            dr.changedPublicContacts.add(publicItem);
        }
        if(privateContacts.size() != publicContacts.size()){
            System.debug('Different number of contacts');
        }
        List<Contact> contactsToUpdate = new List<Contact>();
        for(PrivateContact privateC : dr.changedPrivateContacts){
            contactsToUpdate.add(privateC.getContactRecord());
        }
        for(PublicContact publicC : dr.changedPublicContacts){
            contactsToUpdate.add(publicC.getContactRecord());
        }
        try{
            update contactsToUpdate;
        }
        catch(Exception e){
            System.debug(e.getMessage());
        }
        return dr;
    }

    public void getAndSort() {
        List<Contact> contacts = [SELECT Id, LastName, FirstName, Amount__c, AccountId FROM Contact WHERE Amount__c != null ORDER BY Amount__c DESC];
        for(Contact c : contacts){
            if(c.Amount__c > 10000){
                PrivateContact pc = new PrivateContact('', 0.0, 0, c);
                pc.setContactRecord(c);
                pc.getAmountOfMoney();
                pc.randomCardNumber();  
                this.allContacts.add(pc);
            }
            else {
                PublicContact pb = new PublicContact('', 0.0, 0, c);
                pb.setContactRecord(c);
                pb.randomVolunteerNumber();
                pb.getAmountOfMoney();
                this.allContacts.add(pb);
            }   
        } 
    }
}