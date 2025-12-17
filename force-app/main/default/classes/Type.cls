public virtual class Type {
    protected String ContactType; 

    protected Decimal AmountOfMoney;

    public Type(String ContactType, Decimal AmountOfMoney) {
        this.ContactType = ContactType;
        this.AmountOfMoney = AmountOfMoney;
    }

    public String getContactType() {
        return ContactType;
    }

    public Decimal getAmountOfMoney() {
        return AmountOfMoney;
    }

   
}