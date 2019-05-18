@isTest
public class TestOrder {
    @testSetup static void setup() {
        List<Product_Table__c> listProduct = new List<Product_Table__c>();    
        for(Integer i=0;i<2;i++) { 
            listProduct.Add(new Product_Table__c(Name = 'TestProduct'+i, Units_Available__c = 100, Unit_Price__c = 350));
        }
        insert listProduct;
        List<Product_Table__c> testProduct = [SELECT id, Name, Units_Available__c, Unit_Price__c 
                                              FROM Product_Table__c 
                                              WHERE Name = 'TestProduct0' 
                                              LIMIT 1];
        List<Contact> testContact = new List<Contact>();
        
        for(integer i=0;i<2;i++){
            string email = 'testEmail'+ i + '@mail.com';
            string firstname = 'FirstName'+i;
            string lastname = 'LastName' + i;
            testContact.Add(new Contact(Email = email, FirstName = firstname, LastName = lastname));
        }
        insert testContact;
    }
    
    @isTest static void testInsertOrUpdateContact(){   
        Product_Table__c testProduct = [SELECT id, Name, Units_Available__c, Unit_Price__c 
                                        FROM Product_Table__c 
                                        WHERE Name = 'TestProduct0' 
                                        LIMIT 1];
        
        PageReference testPage = Page.OrderPage;
        testPage.getParameters().put('id', String.valueOf(testProduct.Id));
        Test.setCurrentPage(testPage);
        
        OrderController controller = new OrderController();
        
        controller.currentEmail = 'ivanov@gmail.by';
        controller.firstName = 'Ivan';
        controller.lastName = 'Ivanov';
        controller.searchContact();
        
        Test.startTest();
        controller.currentContact = controller.InsertOrUpdateContact();
        List<Contact> expectedContact = new List<Contact>();
        expectedContact.Add(new Contact(Email = 'ivanov@gmail.by', FirstName = 'Ivan', LastName = 'Ivanov', ID = controller.currentContact.get(0).Id));     
        system.assertEquals(expectedContact, controller.currentContact);
        
        controller.firstname = 'Petr';
        controller.lastname = 'Petrov';
        
        controller.currentContact = controller.InsertOrUpdateContact();
        expectedContact[0].FirstName = 'Petr';
        expectedContact[0].LastName = 'Petrov';
        Test.stopTest();
        system.assertEquals(expectedContact, controller.currentContact);
        
    }
    
    @isTest static void TestGetTotalAmount(){
        List<Product_Table__c> testProduct = [SELECT id, Name, Units_Available__c, Unit_Price__c 
                                              FROM Product_Table__c 
                                              WHERE Name = 'TestProduct0' 
                                              LIMIT 1];
        
        PageReference testPage = Page.OrderPage;
        testPage.getParameters().put('id', String.valueOf(testProduct.get(0).Id));
        Test.setCurrentPage(testPage);
        
        OrderController controller = new OrderController();
        Test.startTest();
        controller.productList = testProduct;
        controller.Cost = controller.productList.get(0).Unit_Price__c;
        decimal expectedTotalAmount = 350;
        decimal currentTotalAmount = controller.totalAmount;
        Test.stopTest();
        system.assertEquals(expectedTotalAmount, currentTotalAmount);
        
    }
    @isTest static void TestcountAmount(){
        List<Product_Table__c> testProduct = [SELECT id, Name, Units_Available__c, Unit_Price__c 
                                              FROM Product_Table__c 
                                              WHERE Name = 'TestProduct0' 
                                              LIMIT 1];
        
        PageReference testPage = Page.OrderPage;
        testPage.getParameters().put('id', String.valueOf(testProduct.get(0).Id));
        Test.setCurrentPage(testPage);
        
        OrderController controller = new OrderController();
        Test.startTest();
        controller.productList = testProduct;
        controller.unitCount = 2;
        controller.Cost = controller.productList.get(0).Unit_Price__c;
        decimal expectedTotalAmount = 700;
        controller.countAmount();
        decimal currentTotalAmount = controller.totalAmount;
        Test.stopTest();
        system.assertEquals(expectedTotalAmount, currentTotalAmount);
        
    }
    
    @isTest static void testsearchContact(){
        List<Product_Table__c> testProduct = [SELECT id, Name, Units_Available__c, Unit_Price__c 
                                              FROM Product_Table__c 
                                              WHERE Name = 'TestProduct0' 
                                              LIMIT 1];
        
        PageReference testPage = Page.OrderPage;
        testPage.getParameters().put('id', String.valueOf(testProduct.get(0).Id));
        Test.setCurrentPage(testPage);
        
        OrderController controller = new OrderController();
        Test.startTest();
        List<Contact> expectedContact = [SELECT Id, FirstName, LastName, Email
                                         FROM Contact
                                         WHERE Email=:'testEmail0@mail.com'
                                        ];
        controller.currentEmail = 'testEmail0@mail.com';
        controller.searchContact();
        system.assertEquals(expectedContact, controller.currentContact);
        string exfirstName = 'FirstName0';
        string exlastName = 'LastName0';
        Test.stopTest();
        system.assertEquals (exfirstName, controller.firstName);
        system.assertEquals (exlastName, controller.lastName);
        
    }
    
    @isTest static void testupdateUnitsAvailable(){
        List<Product_Table__c> testProduct = [SELECT id, Name, Units_Available__c, Unit_Price__c 
                                              FROM Product_Table__c 
                                              WHERE Name = 'TestProduct0' 
                                              LIMIT 1];
        
        PageReference testPage = Page.OrderPage;
        testPage.getParameters().put('id', String.valueOf(testProduct.get(0).Id));
        Test.setCurrentPage(testPage);
        
        OrderController controller = new OrderController();
        Test.startTest();
        controller.unitCount = 10;
        system.assertEquals (true, controller.updateUnitsAvailable());
        controller.unitCount = 1000;
        system.assertEquals (false, controller.updateUnitsAvailable());
        Test.stopTest();
    }
    
    @isTest static void testBuy(){
        List<Product_Table__c> testProduct = [SELECT id, Name, Units_Available__c, Unit_Price__c 
                                              FROM Product_Table__c 
                                              WHERE Name = 'TestProduct0' 
                                              LIMIT 1];
        
        PageReference testPage = Page.OrderPage;
        testPage.getParameters().put('id', String.valueOf(testProduct.get(0).Id));
        Test.setCurrentPage(testPage);
        OrderController controller = new OrderController();
        List<Contact> testContact = [SELECT Id, FirstName, LastName, Email
                                     FROM Contact
                                     WHERE Email=:'testEmail0@mail.com'
                                    ];
        controller.currentContact = testContact;
        controller.lastName = testContact.get(0).LastName;
        controller.unitCount = 5;       
        
        Test.startTest();
        controller.countAmount();
        controller.Buy();
        Order_Table__c expectedOrder = new Order_Table__c(Product_Table__c = testProduct.get(0).Id,
                                                          Units__c = 5,
                                                          Order_Amount__c = 1750.00,
                                                          Contact__c =  testContact.get(0).Id,
                                                          id = controller.currentOrder.Id
                                                         );
        Test.stopTest();
        system.assertEquals(expectedOrder,controller.currentOrder);
    }
    
    @isTest static void testNegativeUnitCount(){
        List<Product_Table__c> testProduct = [SELECT id, Name, Units_Available__c, Unit_Price__c 
                                              FROM Product_Table__c 
                                              WHERE Name = 'TestProduct0' 
                                              LIMIT 1];
        
        PageReference testPage = Page.OrderPage;
        testPage.getParameters().put('id', String.valueOf(testProduct.get(0).Id));
        Test.setCurrentPage(testPage);
        boolean except;
        OrderController controller = new OrderController();
        controller.unitCount = 500;
        Test.startTest();     
        if (!controller.updateUnitsAvailable()){
            except = true;
        }     
        Test.stopTest();
        system.assert(except,'Order should have thrown an exception');  
    }
    
    @isTest static void testNullPointerNegativeBuy(){
        List<Product_Table__c> testProduct = [SELECT id, Name, Units_Available__c, Unit_Price__c 
                                              FROM Product_Table__c 
                                              WHERE Name = 'TestProduct0' 
                                              LIMIT 1];
        PageReference testPage = Page.OrderPage;
        testPage.getParameters().put('id', String.valueOf(testProduct.get(0).Id));
        Test.setCurrentPage(testPage);
        OrderController controller = new OrderController();
        Test.startTest(); 
        try{
            controller.Buy();  
        }catch(NullPointerException ex){ 
            system.assert(ex.getMessage().contains('Attempt to de-reference a null object'),ex.getMessage()); 
        }
        Test.stopTest();
    }
}