public class PublicContact extends Type {
    private Integer VolunteerNumber;
    private Contact ContactRecord;

    public PublicContact(String ContactType, Decimal AmountOfMoney, Integer volunteerNumber, Contact contactRecord)
    {
        super(ContactType, AmountOfMoney);
        this.AmountOfMoney = contactRecord.Amount__c;
        this.VolunteerNumber = volunteerNumber;
        this.ContactRecord = contactRecord;
        
    }

    public void setContactRecord(Contact c) {
        ContactRecord = c;
    }

    public Integer getVolunteerNumber() {
        return VolunteerNumber;
    }

    public Contact getContactRecord() {
        return ContactRecord;
    }

    public void randomVolunteerNumber() {
        VolunteerNumber = Math.abs(Math.mod(Crypto.getRandomInteger(), 1000000));
        this.ContactType = 'Person';
    }
}