public class PublicContact extends Type {
    private Integer volunteerNumber;
    private Contact contactRecord;
    public PublicContact(String contactType, Decimal amountOfMoney, Integer volunteerNumber, Contact contactRecord)
    {
        super(contactType, amountOfMoney);
        this.amountOfMoney = contactRecord.Amount__c;
        this.volunteerNumber = volunteerNumber;
        this.contactRecord = contactRecord;
    }

    public void setContactRecord(Contact c) {
        contactRecord = c;
    }

    public Integer getVolunteerNumber() {
        return volunteerNumber;
    }

    public Contact getContactRecord() {
        return contactRecord;
    }

    public void randomVolunteerNumber() {
        volunteerNumber = Math.abs(Math.mod(Crypto.getRandomInteger(), 1000000));
        this.contactType = 'Person';
    }
}