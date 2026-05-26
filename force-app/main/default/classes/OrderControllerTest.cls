@isTest
public with sharing class OrderControllerTest {
    @TestSetup
    private static void createTestData() {

        Account testAcc = new Account(Name = 'Test Account');
        insert testAcc;

        Contract testContract = new Contract(
            AccountId = testAcc.Id,
            Status = 'Draft',
            StartDate = Date.today(),
            ContractTerm = 4
        );
        insert testContract;

        Entry__c testEntry = new Entry__c(
            Status__c = 'Preregistered'
        );
        insert testEntry;

        Order testOrder = new Order(
            AccountId = testAcc.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Ticket__c = testEntry.Id,
            Ticket_status__c = 'Preregistered',
            ContractId = testContract.Id
        );
        insert testOrder;
    }

    @IsTest
    static void testGetOrder_PreregisteredStatus_Success() {
        Order testOrder = [SELECT Id, Ticket_status__c, Ticket__c FROM Order LIMIT 1];
        Id entryId = testOrder.Ticket__c;
        Entry__c testEntry = [SELECT Id, Status__c FROM Entry__c WHERE Id = :entryId];

        testEntry.Status__c = DataHelper.ENTRY_STATUS_PREREGISTERED;
        update testEntry;

        testOrder.Ticket_status__c = DataHelper.ORDER_STATUS_PREREGISTERED;
        update testOrder;
        Test.startTest();
        OrderController.OrderWrapper result = OrderController.getOrder(testOrder.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Wrapper should not be null');
        System.assertEquals(testOrder.Id, result.order.Id, 'Order ID should match');

        System.assertEquals(true, result.isEntryPreregistered, 'isEntryPreregistered should be true');
        System.assertEquals(false, result.isEntryFixed, 'isEntryFixed should be false');
    }

    @IsTest
    static void testGetOrder_FixedStatus_Success() {
        Order testOrder = [SELECT Id, Ticket_status__c, Ticket__c FROM Order LIMIT 1];
        Id entryId = testOrder.Ticket__c;
        Entry__c testEntry = [SELECT Id, Name, Status__c FROM Entry__c WHERE Id = :entryId];

        testEntry.Status__c = DataHelper.ENTRY_STATUS_FIXED;
        update testEntry;

        testOrder.Ticket_status__c = DataHelper.ORDER_STATUS_PREREGISTERED;
        update testOrder;

        Test.startTest();
        OrderController.OrderWrapper result = OrderController.getOrder(testOrder.Id);
        Test.stopTest();

        System.assertEquals(true, result.isEntryFixed, 'isEntryFixed should be true');
        System.assertEquals(false, result.isEntryPreregistered, 'isEntryPreregistered should be false');
    }

    @IsTest
    static void testGetOrder_NotFound_ThrowsException() {
        Order testOrder = [SELECT Id, Ticket__c, Ticket_status__c FROM Order LIMIT 1];
        Id entryId = testOrder.Ticket__c;
        Entry__c testEntry = [SELECT Id, Name, Status__c FROM Entry__c WHERE Id = :entryId];

        testEntry.Status__c = '';
        update testEntry;

        testOrder.Ticket_status__c = '';
        update testOrder;

        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            OrderController.OrderWrapper result = OrderController.getOrder(testOrder.Id);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Standard Aura exception message mismatch');
        }
        Test.stopTest();

        System.assertEquals(true, exceptionThrown, 'AuraHandledException should have been thrown for missing order');
    }
}