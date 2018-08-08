public class Product2Helper
{
    static List<CollaborationGroup> COLLABORATION_GROUP = [SELECT Id FROM CollaborationGroup
                                                                    WHERE Name = :Constants.INVENTORY_ANNOUNCEMENTS
                                                                    OR Name = :('TEST'+Constants.INVENTORY_ANNOUNCEMENTS)
                                                                    LIMIT 1];

    public static void afterUpdate(List<Product2> newList)
    {
        List<Product2> needsAnnouncement = new List<Product2>();
        Map<String, Decimal> productQuantity = new Map<String, Decimal>();
        List<Inventory_Setting__mdt> inventorySettings = [SELECT Id, DeveloperName, Low_Quantity_Alert__c FROM Inventory_Setting__mdt];

        for(Inventory_Setting__mdt inventoryMtd : inventorySettings)
        {
            productQuantity.put(inventoryMtd.DeveloperName, inventoryMtd.Low_Quantity_Alert__c);
        }

        for(Product2 product : newList)
        {
            if(productQuantity.containsKey(product.Family) && product.Quantity_Remaining__c < productQuantity.get(product.Family))
            {
                needsAnnouncement.add(product);
            }
        }
        postAlerts(needsAnnouncement);
    }

    public static void postAlerts(List<Product2> productList)
    {
        List<ConnectApi.AnnouncementInput> toPost = new List<ConnectApi.AnnouncementInput>();

        for (Product2 product : productList)
        {
            ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
            ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
            ConnectApi.AnnouncementInput announcementInput = new ConnectApi.AnnouncementInput();

            announcementInput.expirationDate = Date.today().addDays(1);
            announcementInput.sendEmails = false;
            announcementInput.parentId = COLLABORATION_GROUP[0].Id;
            textSegmentInput.text = product.Name + ' ' + Constants.INVENTORY_LEVEL_LOW;
            messageBodyInput.messageSegments = new List<ConnectApi.messageSegmentInput>();
            messageBodyInput.messageSegments.add(textSegmentInput);
            announcementInput.body = messageBodyInput;

            toPost.add(announcementInput);
        }

        AnnouncementQueueable queueable = new AnnouncementQueueable();
        queueable.toPost = toPost;
        System.enqueueJob(queueable);
    }
}
