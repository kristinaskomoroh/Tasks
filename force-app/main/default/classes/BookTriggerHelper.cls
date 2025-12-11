public with sharing class BookTriggerHelper {
   
    private static final String LETTERS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    private static final String DIGITS  = '0123456789';

    public static String generateSerialNumber() {
        String letters2 = randomLetters(2);
        String digit1 = randomDigit();
        String letter1 = randomLetter();
        String digits4 = randomDigits(4);

        return letters2 + '-' + digit1 + '-' + letter1 + '-' + digits4; 
    }

    private static String randomLetter() {
        Integer idx = (Integer)Math.floor(Math.random() * LETTERS.length());
        return LETTERS.substring(idx, idx+1); 
    }

    private static String randomLetters(Integer count){
        String str = '';
        for (Integer i = 0; i < count; i++) {
            str += randomLetter();
        }
        return str;
    }

    private static String randomDigit() {
        Integer idx = (Integer)Math.floor(Math.random() * DIGITS.length());
        return DIGITS.substring(idx, idx+1); 
    }

    private static String randomDigits(Integer count) {
        String str = '';
        for (Integer i = 0; i < count; i++) {
            str += randomDigit();
        }
        return str;
    }
}