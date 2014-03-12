/***************************************************************************
 Name       : ContactLookupByEmailController
 Description  :  The Extension class for ContactLookupByEmail Visualforce Page

 Methods: The only method that is used is the getContacts RemoteAction method 
          that returns a wrapper of the Contact Record grouped by Email, 
           
****************************************************************************/

public with sharing class ContactLookupByEmailController {

    public MailingList__c mailingList  {get;set;}

    public ContactLookupByEmailController(ApexPages.StandardController controller){
      String mailingListId = ApexPages.currentPage().getParameters().get('id');
      if(mailingListId != null && mailingListId.length() > 0){
          mailingList = [Select Id, Name, Description__c From MailingList__c Where Id = :mailingListId];
      }
      
    }

    // Main remote action method that returns the ContactWrapper List

    @RemoteAction
    public static List<ContactWrap> getContacts(String emails){

        List<ContactWrap>  cWraps = new List<ContactWrap>();
        Set<String> emailList     = new Set<String>();
        String splitString        = '\n';
  
        // Split the Email Addresses
        for(String s : emails.split(splitString)){
            if(s.containsAny('@')) // must at least contain @ symbol
                emailList.add(s.trim().toLowerCase());
        }


        Map<String,List<Contact>> emailMap = new Map<String,List<Contact>>(); // Use the Map 

        // Iterate

        for(Contact c : [Select Id, Name, FirstName, LastName, Email from Contact where Email in :emailList LIMIT 50000]){
            
            List<Contact> cMap;
            
            if(emailMap.get(c.Email.toLowerCase()) != null){ // Check if map is already populated and if yes add Contact.
                cMap = emailMap.get(c.Email);
            }else{
                cMap = new List<Contact>();
            }

            cMap.add(c);
            emailMap.put(c.Email.toLowerCase(),cMap); // Add to the Map

        }
        
        // Generate the Wrapper Class

        for(String s : emailList){
            if(emailMap.get(s) != null)
                cWraps.add(new ContactWrap(s,emailMap.get(s))); 
            else
                cWraps.add(new ContactWrap(s,new list<Contact>()));  // Create a Empty List for all Emails that are not found
        }

        return cWraps;

    }

    /* Wrapper class grouped by Email Address, and will contain List of Contacts.*/

    public class ContactWrap {
        
        public String emailAddress           {get;set;}
        public List<Contact> matchedContacts {get;set;}
        public String status                 {get;set;}

        public ContactWrap(String email, List<Contact> matches){
            if(matches.size() > 0)
                this.status = 'Existing'; // If any Contacts found, set to existing
            else
                this.status = 'New'; // else set the status to new

            this.emailAddress       = email;
            this.matchedContacts    = matches;

        }

    }
    
}