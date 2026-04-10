public with sharing class OrderItemExtension {
    public Order order {get; set;}
    public List<OrderItem> items {get; set;}

    public OrderItemExtension(ApexPages.StandardController controller) {
        this.order = (Order)controller.getRecord();
        items = [SELECT Id, Product2Id, Quantity, UnitPrice FROM OrderItem WHERE OrderId = :order.Id];
    }
}