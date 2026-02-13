@isTest
public with sharing class CrowCalcTest {
    Integer count = 15;
    @TestSetup
     public static void createCrows() {
        List<Crow__c> crows = new List<Crow__c>();
        for (Integer i = 0; i < count; i++) {
            crows.add(new Crow__c());
        }
        insert crows;
    }

    @isTest
    public static void testAddCrows() {
        Boolean addCrowsResult = CrowCalc.addCrows(10);
        Integer current = [SELECT COUNT() FROM Crow__c];
        System.assertEquals(count + 10, current, 'Number of crows should be 25!');
        System.assertEquals(addCrowsResult, 'Success addition not "true"');
    }

    @isTest
    public static void testSubtractCrows() {
        Boolean substractCrowsResult = CrowCalc.subtractCrows(10);
        Integer current = [SELECT COUNT() FROM Crow__c];
        System.assertEquals(count - 10, current, 'Number of crows should be 5!');
        System.assertEquals(substractCrowsResult, 'Success substraction not "true"');
    }

    @isTest
    public static void testGetTotal() {
        Integer current = CrowCalc.getTotal();
        System.assertEquals(true, current > 0);
        System.assertEquals(count, current, 'Number of crows should be 15!');
    }

    @isTest
    public static void testResetCalc() {
        Boolean resetCalcResult = CrowCalc.resetCalc();
        Integer result = [SELECT COUNT() FROM Crow__c];
        System.assertEquals(resetCalcResult, 'Success reset not "true"');
        System.assertEquals(0, result, 'Number of crows should be 0!');
    }

    @IsTest
    public static void testAddCrowsZero() {
        Boolean addCrowsResult = CrowCalc.addCrows(0);
        Integer current = [SELECT COUNT() FROM Crow__c];
        System.assertEquals(count, current);
        System.assertEquals(addCrowsResult, 'Success addition not "true"');
    }

    @IsTest
    public static void testAddCrowsException() {
        Boolean addCrowsResult = CrowCalc.addCrows(null);
        System.assertEquals(false, addCrowsResult, 'Records should not be added');
    }

    @IsTest
    public static void testSubtractCrowsException() {
        Boolean substractCrowsResult = CrowCalc.subtractCrows(null);
        System.assertEquals(false, substractCrowsResult, 'Records should not be substracked');
    }

   @isTest
    public static void testAddCrowsNegativeNumber() {
        Boolean result = CrowCalc.addCrows(-10);
        System.assertEquals(false, result, 'Records should not be added');
    }

    @isTest
    public static void testSubtractCrowsNegativeNumber() {
        Boolean result = CrowCalc.subtractCrows(-100);
        System.assertEquals(false, result, 'Records should not be substracked');
    }

    @IsTest
    public static void testSubtractCrowsZero() {
        Boolean substractCrowsResult = CrowCalc.subtractCrows(0);
        System.assertEquals(false, substractCrowsResult, 'Number of crows should be 15!');
    }

    @IsTest
    public static void addBulkCrows() {
        Boolean addCrowsResult = CrowCalc.addCrows(100);
        Integer current = [SELECT COUNT() FROM Crow__c];
        System.assertEquals(count + 100, current, 'Number of crows should be 115!');
        System.assertEquals(addCrowsResult, 'Success addition not "true"');
    }
}
