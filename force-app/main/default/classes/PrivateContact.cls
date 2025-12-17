public class PrivateContact extends Type {
    private Integer CardNumber;
    private Contact ContactRecord;

    
    public PrivateContact(String ContactType, Decimal AmountOfMoney, Integer CardNumber, Contact contactRecord) {
        super(ContactType, AmountOfMoney);
        this.AmountOfMoney = contactRecord.Amount__c;
        this.CardNumber = cardNumber;
        this.ContactRecord = contactRecord;
    }

   
    public void setContactRecord(Contact c) {
        ContactRecord = c;
    }

    
    public Integer getCardNumber() {
        return CardNumber;
    }

    public Contact getContactRecord() {
        return ContactRecord;
    }

    public void randomCardNumber() {
        CardNumber = Math.abs(Math.mod((Crypto.getRandomInteger()), 1000000));
        checkDigits();
    }

    private void checkDigits() {
        String cardNumberStr = String.valueOf(CardNumber);
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
                this.ContactType = 'Premier';
                return;
            }
        }
        this.ContactType = 'Person';
    }
    
}