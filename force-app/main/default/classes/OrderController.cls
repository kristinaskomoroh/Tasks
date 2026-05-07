public with sharing class OrderController {

    public class OrderWrapper {
        @AuraEnabled public Order order;
        @AuraEnabled public Boolean isEntryPreregistered;
        @AuraEnabled public Boolean isEntryFixed;
        @AuraEnabled public String entryChangedStatus;
        @AuraEnabled public String orderChangedStatus;
    }

    @AuraEnabled(cacheable=true)
    public static OrderWrapper getOrder(Id recordId) {
        OrderWrapper wrapper = new OrderWrapper();

        List<Order> orders = [
            SELECT Id,
                   Name,
                   Ticket__c,
                   Ticket_status__c,
                   Ticket__r.Status__c,
                   Applicant__c,
                   Applicant__r.Debitor_number__c
            FROM   Order
            WHERE  Id = :recordId
              AND  Ticket_status__c = :DataHelper.ORDER_STATUS_PREREGISTERED
              AND  Ticket__r.Status__c IN (:DataHelper.ENTRY_STATUS_PREREGISTERED, :DataHelper.ENTRY_STATUS_FIXED)
        ];

        if (!orders.isEmpty()) {
            Order order = orders.get(0);

            wrapper.order = order;
            wrapper.isEntryPreregistered = order.Ticket__r.Status__c == DataHelper.ENTRY_STATUS_PREREGISTERED;
            wrapper.isEntryFixed = order.Ticket__r.Status__c == DataHelper.ENTRY_STATUS_FIXED;
            wrapper.entryChangedStatus = DataHelper.ENTRY_STATUS_FIXED;
            wrapper.orderChangedStatus = DataHelper.ORDER_STATUS_FIXED;
        }else {
            throw new AuraHandledException('Order not found');
        }
        return wrapper;
    }
}