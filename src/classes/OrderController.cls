public class OrderController {
    public class UnitsAvailableException extends Exception {}
    
    public Order_Table__c currentOrder;    
    public List<Product_Table__c> productList;
    public List<Contact> currentContact;
    ID productId;
    @TestVisible decimal amount;
    public String currentEmail{get;set;}
    public String firstName{get;set;}
    public String lastName{get;set;}
    public String productName{get;set;}
    public integer unitCount{get;set;}
    public decimal Cost{get;set;}
    public decimal totalAmount{get{return amount;}}
    
    public PageReference countAmount(){
        amount = Cost*unitCount;
        return null;
    }
    
    public OrderController(){   
        
        productId = ApexPages.currentPage().getParameters().get('Id');
        productList = [SELECT Id, Name, Unit_Price__c, Units_Available__c    
                       FROM Product_Table__c 
                       WHERE Id =:productId
                       LIMIT 1];
        
        productName = productList.get(0).Name;
        Cost = productList.get(0).Unit_Price__c;
        unitCount = 1;
        amount =  productList.get(0).Unit_Price__c;       
    }
    
    public PageReference searchContact() {       
        currentContact = [SELECT Id, FirstName, LastName, Email
                          FROM Contact
                          WHERE Email=:currentEmail
                         ];
        
        if(!(currentContact.isEmpty())){
            firstName = currentContact[0].FirstName;
            lastName = currentContact[0].LastName;
            update currentcontact;
        }else{
        }
        return null;
    }
    
    public List<Contact> InsertOrUpdateContact(){
        if(currentContact.isEmpty()){
            
            currentContact.Add(new Contact(Email = currentEmail,
                                           FirstName = firstName,
                                           LastName = lastName));
            insert currentContact;
        }else{
            currentContact[0].FirstName = firstName;
            currentContact[0].LastName = lastName;
            update currentContact;
            
        }    
        return currentcontact;
    }
    
    
    public boolean updateUnitsAvailable(){
        boolean flag = false;
        if((productList.get(0).Units_Available__c >= 0) && (productList.get(0).Units_Available__c >= unitCount)){
            productList.get(0).Units_Available__c -= unitCount;
            update productList;
            flag = true;
        }else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'No product');
            ApexPages.addMessage(myMsg);
        }
        return flag;
    }
    
    public PageReference Buy(){      
        if (!(string.isEmpty(lastName))) {
            currentcontact = InsertOrUpdateContact();
            currentOrder = new Order_Table__c(Product_Table__c = productId,
                                              Units__c = unitCount,
                                              Order_Amount__c = totalAmount,
                                              Contact__c =  currentContact[0].Id
                                             );   
            if (updateUnitsAvailable()){
                insert currentOrder;
                return ToShopping();
            }
        }else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'field value is empty');
            ApexPages.addMessage(myMsg);
        }
        return null;
    }
    
    public PageReference ToShopping(){
        PageReference reference = Page.ProductPage;
        reference.setRedirect(true); 
        return reference; 
    }
}