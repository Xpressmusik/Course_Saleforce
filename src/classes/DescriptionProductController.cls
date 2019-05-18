public class DescriptionProductController {
	public List<Product_Table__c> listProduct;
	public Product_Table__c queryProduct;    
    public DescriptionProductController (){        
        
    }
    
    public List<Product_Table__c> getlistProduct(){
      listProduct = [SELECT Id, Image_Url__c, Name,Title__c, Product_Description__c, Unit_Price__c 
                       FROM Product_Table__c 
                       LIMIT 100];
        return listProduct;
    }
    
    public Product_Table__c getqueryProduct(){
       queryProduct = [SELECT Id, Image_Url__c, Name,Title__c, Product_Description__c, Units_Available__c 
                        FROM Product_Table__c 
                        WHERE Id =: ApexPages.currentPage().getParameters().get('Id')
                      	LIMIT 1];
        return queryProduct;
    }
}