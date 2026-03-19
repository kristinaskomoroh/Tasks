public virtual class Type{
    protected String contactType; 
    protected Decimal amountOfMoney;

    public Type(String contactType, Decimal amountOfMoney) {
        this.contactType = contactType;
        this.amountOfMoney = amountOfMoney;
    }

    public String getContactType() {
        return contactType;
    }

    public Decimal getAmountOfMoney() {
        return amountOfMoney;
    }
}