@isTest
public with sharing class CrowCalcTest {
    @TestSetup
     public static void createCrows() {
        List<Crow__c> crows = new List<Crow__c>();
        for (Integer i = 0; i < 15; i++) {
            crows.add(new Crow__c());
        }
        insert crows;
    }
    
    @isTest
    public static void testAddCrows() {


        Boolean addCrowsResult = CrowCalc.addCrows(10);

        Integer current = [SELECT COUNT() FROM Crow__c];

        System.assertEquals(25, current, 'Right answer!');

        System.assert(addCrowsResult, 'Success addition not "true"');

    }

    @isTest
    public static void testSubtractCrows() {

    Boolean substractCrowsResult = CrowCalc.subtractCrows(10);

    Integer current = [SELECT COUNT() FROM Crow__c];

    System.assertEquals(5, current, 'Right answer!');

    System.assertEquals(true, substractCrowsResult);
    }

    
    @isTest
    public static void testGetTotal() {

        Integer current = CrowCalc.getTotal();

        System.assertEquals(true, current > 0);

        System.assertEquals(15, current, 'Right answer!');
    }

    @isTest
    public static void testResetCalc() {
       
        Boolean resetCalcResult = CrowCalc.resetCalc();

        Integer current = [SELECT COUNT() FROM Crow__c];

        System.assertEquals(true, resetCalcResult);

    }

    @IsTest
    public static void testAddCrowsZero() {
        Boolean addCrowsResult = CrowCalc.addCrows(0);
        Integer current = [SELECT COUNT() FROM Crow__c];
        System.Assert.areEqual(15, current);
        System.Assert.areEqual(true, addCrowsResult);
    }

    @IsTest
    public static void testAddCrowsException() {
        Boolean addCrowsResult = CrowCalc.addCrows(null);
        System.Assert.areEqual(false, addCrowsResult);
    }

    @IsTest
    public static void testSubtractCrowsException() {
        Boolean substractCrowsResult = CrowCalc.subtractCrows(null);
        System.Assert.areEqual(false, substractCrowsResult);
    }

   @isTest
    public static void testAddCrowsNegativeNumber() {
    Integer initial = [SELECT COUNT() FROM Crow__c];
    Boolean result = CrowCalc.addCrows(-10);
    
    System.Assert.areEqual(initial, [SELECT COUNT() FROM Crow__c], 'Records should not be added');
    
}

    @isTest
    public static void testSubtractCrowsNegativeNumber() {
    Integer initial = [SELECT COUNT() FROM Crow__c];
    Boolean result = CrowCalc.subtractCrows(-100);
    System.Assert.areEqual(initial, [SELECT COUNT() FROM Crow__c], 'Records should not be substracked');
    }

    @IsTest
    public static void testSubtractCrowsZero() {
        Boolean substractCrowsResult = CrowCalc.subtractCrows(0);
        Integer current = [SELECT COUNT() FROM Crow__c];
       
        System.assertEquals(15, current);
    }

    @IsTest
    public static void addBulkCrows() {
        Boolean addCrowsResult = CrowCalc.addCrows(100);
        Integer current = [SELECT COUNT() FROM Crow__c];
        
        System.assertEquals(115, current);
    }
}
