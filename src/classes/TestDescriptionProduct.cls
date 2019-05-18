@isTest
public class TestDescriptionProduct {
    
    @testSetup static void setup() {
        List<Product_Table__c> listProduct = new List<Product_Table__c>();
        
        for(integer i=0;i<101;i++){
            
            listProduct.Add(new Product_Table__c(Name = 'TestProduct'+i));
        }
        insert listProduct;
    }
    
    @isTest static void testListProduct(){
        DescriptionProductController controller = new DescriptionProductController();
        List<Product_Table__c>  currentProduct =  controller.getlistProduct();
        List<Product_Table__c> expectedProduct =   [SELECT Image_Url__c, Name,Title__c, Product_Description__c, Unit_Price__c 
                                                    FROM Product_Table__c 
                                                    LIMIT 100];
        system.assertEquals(expectedProduct.Size(), currentProduct.Size());
    }
    
    @isTest static void testqueryProduct(){
        DescriptionProductController controller = new DescriptionProductController();
        controller.queryProduct = [SELECT id, Name
                                   FROM Product_Table__c 
                                   WHERE Name = 'TestProduct0'
                                   LIMIT 1];
        string productId = controller.queryProduct.Id;       
        ApexPages.currentPage().getParameters().put('Id', productId);
        Product_Table__c currentProduct = controller.getqueryProduct();
        Product_Table__c expectedProduct = [SELECT Name 
                                            FROM Product_Table__c 
                                            WHERE Id =: productId];
        system.assertEquals(expectedProduct, currentProduct);
    }
}