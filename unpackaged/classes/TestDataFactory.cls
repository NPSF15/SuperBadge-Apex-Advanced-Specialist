/**
 * @name TestDataFactory
 * @description Contains methods to construct and/or validate commonly used records
**/
public with sharing class TestDataFactory {

	public static CollaborationGroup ConstructCollaborationGroup()
	{
		CollaborationGroup ChatterGroup = new CollaborationGroup(
				Name = 'TEST'+ Constants.INVENTORY_ANNOUNCEMENTS,
				CollaborationType = 'Public',//CanHaveGuests = true,
				IsArchived = false,
				IsAutoArchiveDisabled = true
		);
		return ChatterGroup;
	}

	public static List<Product2> ConstructProducts(Integer cnt)
	{
		List<Product2> products = new List<Product2>();
		for (Integer i = 0; i < cnt; i++)
		{
			if (i >= Constants.PRODUCT_FAMILY.size())
			{
				products.add(new Product2(Name = 'Test PBE' + i, IsActive = true, Initial_Inventory__c = 10, Family =
						Constants.PRODUCT_FAMILY.get(0).getValue()));
			}
			else
			{
				products.add(new Product2(Name = 'Test PBE' + i, IsActive = true, Initial_Inventory__c = 10, Family =
						Constants.PRODUCT_FAMILY.get(i).getValue()));
			}
		}
		return products;
	}

	public static List<PricebookEntry> ConstructPricebookEntries(List<Product2> products)
	{
		List<PricebookEntry> priceBookEntries = new List<PricebookEntry>();
		for (Product2 product : products)
		{
			priceBookEntries.add(new PricebookEntry(IsActive = true,
					Product2Id = product.Id, UnitPrice = 10, Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID));
		}
		return priceBookEntries;
	}

	public static List<Account> ConstructAccounts(Integer cnt)
	{
		List<Account> accounts = new List<Account>();
		for (Integer i = 0; i < cnt; i++)
		{
			accounts.add(new Account(Name = 'Test Account' + i));
		}
		return accounts;
	}

	/**
	 * @name CreateContacts
	 * @description Constructs a list of Contacxt records for unit tests
	**/
	public static List<Contact> constructContacts(Integer cnt, List<Account> accounts)
	{
		List<Contact> contacts = new List<Contact>();
		for (Integer i = 0; i < cnt; i++)
		{
			contacts.add(new Contact(LastName = 'Test Contact' + i, AccountId = accounts.get(i).Id));
		}
		return contacts;
	}

	public static List<Order> ConstructOrders(Integer cnt, List<Account> accounts)
	{
		List<Order> orders = new List<Order>();
		for (Integer i = 0; i < cnt; i++)
		{
			orders.add(new Order(Name = 'Test Order' + i, AccountId = accounts.get(i).Id,
					Status = Constants.DRAFT_ORDER_STATUS, EffectiveDate = Date.today(), Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID));
		}
		return orders;
	}

	/**
	 * @name CreateOrderItems
	 * @description Constructs a list of OrderItem records for unit tests
	**/
	public static List<OrderItem> ConstructOrderItems(Integer cnt, List<PricebookEntry> pbEntires, List<Order> orders)
	{
		List<OrderItem> orderItems = new List<OrderItem>();
		for (Integer i = 0; i < cnt; i++)
		{
			orderItems.add(new OrderItem(Quantity = Constants.DEFAULT_ROWS, UnitPrice = 10,
					PricebookEntryId = pbEntires.get(i).Id, OrderId = orders.get(i).Id));
		}
		return orderItems;
	}

	public static void insertTestData(Integer cnt)
	{
		CollaborationGroup colG = ConstructCollaborationGroup();
		insert colG;

		List<Account> accounts = ConstructAccounts(cnt);
		insert accounts;

		List<Contact> contacts = ConstructContacts(cnt, accounts);
		insert contacts;

		List<Product2> products = ConstructProducts(cnt);
		insert products;

		List<PriceBookEntry> priceBookEntries = ConstructPricebookEntries(products);
		insert priceBookEntries;

		List<Order> orders = ConstructOrders(cnt, accounts);
		insert orders;

		List<OrderItem> orderItem = ConstructOrderItems(cnt, priceBookEntries, orders);
		insert orderItem;
	}

	public static void verifyQuantityOrdered(Product2 originalProduct, Product2 updatedProduct, Integer qtyOrdered)
	{
		System.assertEquals(updatedProduct.Quantity_Ordered__c == originalProduct.Quantity_Ordered__c + qtyOrdered, true, 'Value of Quantity Ordered is not right');
	}
}