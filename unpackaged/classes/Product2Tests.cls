@isTest
public class Product2Tests
{
    @testSetup
    static void testSetup()
    {
        TestDataFactory.insertTestData(12);
    }

    @isTest
    static void product2Extension_UnitTest()
    {
        Product2 product = [SELECT Id, Name, Family, Initial_Inventory__c, Quantity_Ordered__c, Quantity_Remaining__c FROM Product2 LIMIT 1];
        PageReference pageReference = Page.Product2New;
        Test.setCurrentPage(pageReference);
        Product2Extension ext = new Product2Extension(new ApexPages.StandardController(product));

        Test.startTest();
            System.assertEquals(Constants.DEFAULT_ROWS,ext.productsToInsert.size());
            ext.AddRows();
            System.assertEquals(Constants.DEFAULT_ROWS*2, ext.productsToInsert.size());

            ext = new Product2Extension(new ApexPages.StandardController(product));
            ext.AddRows();
            for (Product2Extension.ProductWrapper pw : ext.productsToInsert)
            {
                pw.productRecord.Name = 'Cake';
                pw.productRecord.IsActive = true;
                pw.productRecord.Initial_Inventory__c = 10;
                pw.productRecord.Family = 'Dessert';
                pw.pricebookEntryRecord.UnitPrice = 20;
            }
            ext.save();
            ext.GetFamilyOptions();
            ext.GetInventory();
        Test.stopTest();
    }

    @isTest
    static void product2Trigger_UnitTest()
    {
        Product2 product = [SELECT Id, Name, Family, Quantity_Ordered__c FROM Product2 LIMIT 1];
        product.Quantity_Ordered__c = 50;

        Test.startTest();
            update product;
        Test.stopTest();
    }
}