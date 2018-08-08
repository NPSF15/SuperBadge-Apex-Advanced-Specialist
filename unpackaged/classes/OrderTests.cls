@isTest
public class OrderTests
{
	@testSetup
	static void testSetup()
	{
		TestDataFactory.insertTestData(12);
	}

	@isTest
	static void OrderUpdate_UnitTest()
	{
		List<Order> orders = [SELECT Id, Status FROM Order];
		List<Product2> originalProducts = [SELECT Id, Quantity_Ordered__c FROM Product2];
		for (Order ord : orders)
		{
			ord.Status = Constants.ACTIVATED_ORDER_STATUS;
		}
		Test.startTest();
			update orders;
		Test.stopTest();

		List<Product2> updatedProducts = [SELECT Id, Quantity_Ordered__c FROM Product2];
		for (Integer i = 0; i < orders.size(); i++)
		{
			TestDataFactory.VerifyQuantityOrdered(originalProducts.get(i), updatedProducts.get(i), Constants.DEFAULT_ROWS);
		}
	}
	
	@isTest
	static void OrderExtension_UnitTest()
	{
		Order orderRecord = [SELECT Id, Name FROM Order LIMIT 1];
		PageReference pageReference = Page.OrderEdit;
		Test.setCurrentPage(pageReference);
		OrderExtension ext = new OrderExtension(new ApexPages.StandardController(orderRecord));

		Test.startTest();
			System.assertEquals(Constants.DEFAULT_ROWS,ext.orderItemList.size());
			ext.next();
			ext.last();
			ext.previous();
			ext.first();
			System.assertEquals(1, ext.pageNumber);

			ext.selectedFamily = 'Dessert';
			ext.SelectFamily();
			ext.orderItemList.get(0).Quantity = 1;
			ext.OnFieldChange();
			ext.save();
		Test.stopTest();
	}
}