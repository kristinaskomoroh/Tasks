public class PrivateContact extends Type{
    private Integer cardNumber;
    private Contact contactRecord;

    public PrivateContact(String contactType, Decimal amountOfMoney, Integer cardNumber, Contact contactRecord) {
        super(contactType, amountOfMoney);
        this.amountOfMoney = contactRecord.Amount__c;
        this.cardNumber = cardNumber;
        this.contactRecord = contactRecord;
    }

    public void setContactRecord(Contact c) {
        contactRecord = c;
    }

    public Integer getCardNumber() {
        return cardNumber;
    }

    public Contact getContactRecord() {
        return contactRecord;
    }

    public void randomCardNumber() {
        cardNumber = Math.abs(Math.mod((Crypto.getRandomInteger()), 1000000));
        checkDigits();
    }

    private void checkDigits() {
        String cardNumberStr = String.valueOf(cardNumber);
        Map<String, Integer> digitsMap = new Map<String, Integer>();
        for(Integer i = 0; i < cardNumberStr.length(); i++){
            String digits = cardNumberStr.substring(i, i+1);
            if(!digitsMap.containsKey(digits)){
                digitsMap.put(digits, 1);
            } else {
                digitsMap.put(digits, digitsMap.get(digits) + 1);
            }
        }
        for(String digit : digitsMap.keySet()){
            if(digitsMap.get(digit) >= 3){
                this.contactType = 'Premier';
                return;
            }
        }
        this.contactType = 'Person';
    }
}