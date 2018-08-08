public without sharing class OrderHelper
{
    public static void AfterUpdate(List<Order> newList, List<Order> oldList)
    {
        Set<Id> orderIds = new Set<Id>();
        for (Integer i=0; i<newList.size(); i++)
        {
            if (newList[i].Status == Constants.ACTIVATED_ORDER_STATUS && oldList[i].Status == Constants.DRAFT_ORDER_STATUS)
            {
                orderIds.add(newList[i].Id);
            }
        }
        rollUpOrderItems(orderIds);
    }

    public static void rollUpOrderItems(Set<Id> activatedOrderIds)
    {
        List<OrderItem> orderItems = [SELECT Id, Product2Id, Order.ActivatedDate, Product2.Quantity_Ordered__c, Quantity FROM OrderItem WHERE OrderId IN :activatedOrderIds];
        Map<Id, Product2> productMap = new Map<Id, Product2>();
        for (OrderItem item : orderItems)
        {
            productMap.put(item.Product2Id, item.Product2);
        }

        List<AggregateResult> ags = [SELECT Product2Id, SUM(Quantity) FROM OrderItem WHERE Product2Id IN :productMap.keyset() GROUP BY Product2Id];
        for (AggregateResult ag : ags)
        {
            productMap.get((Id)ag.get('Product2Id')).Quantity_Ordered__c = (Decimal) ag.get('expr0');
        }
        update productMap.values();
    }

}