public without sharing class ChartHelper
{
    @AuraEnabled
    public static List<ChartData> getInventory()
    {
        List<ChartData> productRemainingQuantities = new List<ChartData>();
        List<AggregateResult> productAG = [SELECT Family fam, SUM(Quantity_Remaining__c) sumQR FROM Product2 WHERE Quantity_Remaining__c > 0 AND IsActive = TRUE GROUP BY Family];
        for (AggregateResult ag : productAG)
        {
            productRemainingQuantities.add(new ChartData((String)ag.get('fam'), (Decimal)ag.get('sumQR')));
        }
        return productRemainingQuantities;
    }

    public class ChartData
    {
        public String name { get; set; }
        public Decimal val { get; set; }

        public ChartData(String name, Decimal val)
        {
            this.name = name;
            this.val = val;
        }
    }
}