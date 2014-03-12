/***************************************************************************
 Name       : TestContactLookupByEmailController 
 Description  :  Test Class for the ContactLookupByEmail Class
          
****************************************************************************/
@isTest
private class TestContactLookupByEmailController  {
  
  @isTest static void contactLookupByEmailTest1() {
    //Load Test Data
    
    Account testAcc = new Account(Name='Test Account');

    insert testAcc; // Load the test Account

    MailingList__c testMailingList = new MailingList__c(Name='Test List', Description__c='New List');

    insert testMailingList; // Load the test Account
    
    Contact testContact = new Contact(FirstName='John', LastName='Doe');
    
    MailingListMember__c testMailingListMember = new MailingListMember__c(Contact__c=testContact.Id, Mailing_List__c = testMailingList.Id);

    Apexpages.standardController con = new ApexPages.StandardController(testMailingListMember);

    List<Contact> contacts = new List<Contact>();

    // Insert 1000 Contacts with all different Emails
    for(Integer i=0;i<1000;i++){
      contacts.add(new Contact(LastName='Last'+i,FirstName='First'+i,Email='testCon'+i+'@test.com',AccountId=testAcc.Id));
    }

    contacts.add(new Contact(LastName='LastDup100',FirstName='FirstDup100',Email='testCon100@test.com',AccountId=testAcc.Id));

    system.debug(contacts[100]);
    system.debug(contacts[0]);

    insert contacts;

    Test.startTest();

      ContactLookupByEmailController testExt = new ContactLookupByEmailController(con); // Dummy to cover the Constructor

      // Start with some simple ones

      // 4 with 3 matching and 1 not found one

      String emailAddresses = 'testCon0@test.com\ntestCon1@test.com\ntestCon100@test.com\ntestNotFound@test.com';

      emailAddresses += '\ntestConInvalidemail'; // This is treated as invalid email address and not searched for  

      List<ContactLookupByEmailController.ContactWrap> wraps = ContactLookupByEmailController.getContacts(emailAddresses);
      system.debug('wraps ' + wraps);
      system.assertEquals(4,wraps.size()); // Assert the size returned

      for(ContactLookupByEmailController.ContactWrap cw : wraps){
          if(cw.emailAddress == 'testCon0@test.com')
            system.assertEquals('Existing',cw.status); // Assert the statuses
          if(cw.emailAddress == 'testNotFound@test.com')
            system.assertEquals('New',cw.status);  // Assert the statuses
          if(cw.emailAddress == 'testCon100@test.com')
            system.assertEquals(2,cw.matchedContacts.size()); // 2 records are present with same email   
            
      }

    Test.stopTest();


  }
  
  @isTest static void contactLookupByEmailTest2() {
    //Load Test Data
   
    Account testAcc = new Account(Name='Test Account');

    insert testAcc; // Load the test Account

    MailingList__c testMailingList = new MailingList__c(Name='Test List', Description__c='New List');

    insert testMailingList; // Load the test Account
    
    Contact testContact = new Contact(FirstName='John', LastName='Doe');
    
    MailingListMember__c testMailingListMember = new MailingListMember__c(Contact__c=testContact.Id, Mailing_List__c = testMailingList.Id);

    Apexpages.standardController con = new ApexPages.StandardController(testMailingListMember);

    List<Contact> contacts = new List<Contact>();

    // Insert 1000 Contacts with all different Emails
    for(Integer i=0;i<1000;i++){
      contacts.add(new Contact(LastName='Last'+i,FirstName='First'+i,Email='testCon'+i+'@test.com',AccountId=testAcc.Id));
      
    }

    insert contacts;

    Test.startTest();

      ContactLookupByEmailController testExt = new ContactLookupByEmailController(con); // Dummy to cover the Constructor

      // build a csv file

      String bulkEmails = '';

      for(Integer i=0;i<1000;i++){

        bulkEmails += 'testCon'+i+'@test.com'+'\n';

      }

    

      List<ContactLookupByEmailController.ContactWrap> wraps = ContactLookupByEmailController.getContacts(bulkEmails);

      system.assertEquals(1000,wraps.size());


    Test.stopTest();

  }
  
}