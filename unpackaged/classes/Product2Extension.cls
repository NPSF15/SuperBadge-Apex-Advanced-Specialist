public class Product2Extension
{
	public List<ProductWrapper> productsToInsert {get; set;}
	public List<ChartHelper.ChartData> productRemainingQuantities {get; set;}

	public Product2Extension(ApexPages.StandardController controller)
	{
		this.productsToInsert = new List<ProductWrapper>();
		this.productRemainingQuantities = ChartHelper.GetInventory();
		this.addRows();
	}

	public void addRows()
	{
		for (Integer i = 0; i < Constants.DEFAULT_ROWS; i++)
		{
			this.productsToInsert.add(new ProductWrapper(new Product2(Initial_Inventory__c = 0), new PricebookEntry(UnitPrice = 0.0)));
		}
	}

	public List<ChartHelper.ChartData> getInventory()
	{
		return ChartHelper.getInventory();
	}

	public PageReference save()
	{
		Savepoint sp = Database.setSavepoint();
		try
		{
			List<Product2> products = new List<Product2>();
			List<PricebookEntry> entries = new List<PricebookEntry>();

			for (ProductWrapper product : this.productsToInsert)
			{
				if (product != null && !String.isBlank(product.productRecord.Name) && !String.isBlank(product.productRecord.Family) &&
								product.productRecord.Family != Constants.SELECT_ONE && product.productRecord.isActive &&
								product.pricebookEntryRecord.UnitPrice != null && product.productRecord.Initial_Inventory__c != null &&
								product.productRecord.Initial_Inventory__c != 0 && product.pricebookEntryRecord.UnitPrice != 0)
				{
					products.add(product.productRecord);
				}
			}
			Database.SaveResult[] productSaveResult = Database.insert(products, false);
			for (Integer i = 0; i < productSaveResult.size(); i++)
			{
				PricebookEntry entry = this.productsToInsert.get(i).pricebookEntryRecord;
				entry.Product2Id = productSaveResult[i].Id;
				entry.IsActive = true;
				entry.Pricebook2Id = constants.STANDARD_PRICEBOOK_ID;
				entries.add(entry);
			}
			insert entries;

			ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, productsToInsert.size() + ' Inserted'));
			productsToInsert.clear();
			addRows();
		}
		catch(Exception ex)
		{
			Database.rollback(sp);
			ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, constants.ERROR_MESSAGE));
			System.debug(ex.getMessage());
		}
		return null;
	}

	public List<SelectOption> getFamilyOptions()
	{
		List<SelectOption> options = new List<SelectOption>{new SelectOption(Constants.SELECT_ONE, Constants.SELECT_ONE)};
		for (Schema.PicklistEntry picklistEntry : Constants.PRODUCT_FAMILY)
		{
			options.add(new SelectOption(picklistEntry.getValue(), picklistEntry.getLabel()));
		}
		return options;
	}

	public with sharing class ProductWrapper
	{
		public Product2 productRecord {get; set;}
		public PricebookEntry pricebookEntryRecord {get; set;}

		public ProductWrapper(Product2 productRecord, PricebookEntry pricebookEntryRecord)
		{
			this.productRecord = productRecord;
			this.pricebookEntryRecord = pricebookEntryRecord;
		}
	}
}