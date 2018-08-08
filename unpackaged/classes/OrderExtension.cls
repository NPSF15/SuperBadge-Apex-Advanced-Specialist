public class OrderExtension
{
	public Order orderRecord {get; set;}
	public List<OrderItem> orderItemList {get; set;}
	public String selectedFamily {get; set;}
	public List<ChartHelper.ChartData> pieData {get; set;}
	public Decimal total {get; set;}
	private String query;
	public Map<Id, OrderItem> orderItemMap;
	ApexPages.StandardSetController standardSetController;
	public Integer pageNumber
	{
		get
		{
			return standardSetController.getPageNumber();
		}
		set;
	}

	public Integer totalPages
	{
		get
		{
			Integer total = (Integer)(standardSetController.getResultSize() / ((Decimal)Constants.DEFAULT_ROWS)).round(
					System.RoundingMode.CEILING);
			return (total == 0) ? 1 : total;
		}
		set;
	}

	public OrderExtension(ApexPages.StandardController standardController)
	{
		orderRecord = (Order)standardController.getRecord();
		orderItemMap = new Map<Id, OrderItem>();
		if (orderRecord.Id != null)
		{
			orderRecord = queryOrderRecord(orderRecord.Id);
		}
		this.refreshPriceBookEntries();
		this.total = 0;

		for (OrderItem item : orderRecord.OrderItems)
		{
			orderItemMap.put(item.Product2Id, item);
			if (item.Quantity > 0)
			{
				if (pieData == null)
				{
					pieData = new List<ChartHelper.ChartData>();
				}
				pieData.add(new ChartHelper.ChartData(item.Product2.Name, item.Quantity * item.UnitPrice));
				total += item.UnitPrice * item.Quantity;
			}
		}
		this.loadData();
	}

	public void onFieldChange()
	{
		for (OrderItem item : this.orderItemList)
		{
			this.orderItemMap.put(item.Product2Id, item);
		}

		this.pieData = null;
		this.total = 0;
		for (OrderItem oi : this.orderItemMap.values())
		{
			if (oi.Quantity > 0)
			{
				if (null == this.pieData)
				{
					this.pieData = new List<ChartHelper.ChartData>();
				}
				this.pieData.add(new ChartHelper.ChartData(oi.Product2.Name, oi.Quantity * oi.UnitPrice));
				this.total += oi.UnitPrice * oi.Quantity;
			}
		}
	}

	public void selectFamily()
	{
		this.refreshPriceBookEntries();
		this.loadData();
	}

	private void refreshPriceBookEntries()
	{
		this.query = 'SELECT Name, Product2.Family, Product2.Name, Product2Id, UnitPrice, Product2.Quantity_Remaining__c' +
				' FROM PricebookEntry WHERE IsActive = TRUE';
		if (this.selectedFamily != null && selectedFamily != Constants.SELECT_ONE)
		{
			this.query += ' AND Product2.Family = \'' + this.selectedFamily + '\'';
		}
		this.standardSetController = new ApexPages.StandardSetController(Database.query(query));
		this.standardSetController.setPageSize(Constants.DEFAULT_ROWS);
	}

	private void loadData()
	{
		this.orderItemList = new List<OrderItem>();
		for (PricebookEntry pbE : (List<PricebookEntry>)this.standardSetController.getRecords())
		{
			if (orderItemMap.containsKey(pbE.Product2Id))
			{
				orderItemList.add(orderItemMap.get(pbE.Product2Id));
			}
			else
			{
				OrderItem ordItem = new OrderItem(PricebookEntryId = pbe.Id, Product2Id = pbe.Product2Id,
						UnitPrice = pbe.UnitPrice, Quantity = 0, Product2 = pbe.Product2);
				orderItemList.add(ordItem);
				orderItemMap.put(pbe.Product2Id, ordItem);
			}
		}
	}

	public PageReference save()
	{
		Savepoint sp = Database.setSavepoint();
		try
		{
			if (this.orderRecord.Pricebook2Id == null)
			{
				this.orderRecord.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
			}
			upsert this.orderRecord;

			List<OrderItem> orderItemsToUpsert = new List<OrderItem>();
			List<OrderItem> orderItemsToDelete = new List<OrderItem>();
			for (OrderItem item : this.orderItemMap.values())
			{
				if (item.Quantity > 0)
				{
					if (item.OrderId == null)
					{
						item.OrderId = this.orderRecord.Id;
					}
					orderItemsToUpsert.add(item);
				}
				else if (item.Id != null)
				{
					orderItemsToDelete.add(item);
				}
			}
			upsert orderItemsToUpsert;
			delete orderItemsToDelete;
		}
		catch(Exception ex)
		{
			Database.rollback(sp);
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Something went wrong.. ' + ex.getMessage()));
			return null;
		}

		PageReference redirectSuccess = new ApexPages.StandardController(this.orderRecord).view();
		return redirectSuccess;
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

	public static Order queryOrderRecord(Id orderId)
	{
		return [SELECT Id, AccountId, EffectiveDate, Name, Status, Pricebook2Id,
				(SELECT Id, OrderId, Quantity, UnitPrice, PricebookEntryId, Product2Id,
						Product2.Name, Product2.Family, Product2.Quantity_Remaining__c
						FROM OrderItems)
				FROM Order
				WHERE Id = :orderId
		];
	}

	public PageReference cancel()
	{
		return this.standardSetController.cancel();
	}

	public void first()
	{
		standardSetController.first();
		this.loadData();
	}

	public void next()
	{
		standardSetController.next();
		this.loadData();
	}

	public void previous()
	{
		standardSetController.previous();
		this.loadData();
	}

	public void last()
	{
		standardSetController.last();
		this.loadData();
	}

	public Boolean getHasPrevious()
	{
		return this.standardSetController.getHasPrevious();
	}

	public Boolean getHasNext()
	{
		return this.standardSetController.getHasNext();
	}
}