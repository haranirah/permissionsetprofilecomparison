public class ContactSearch {
       public static list<Contact> searchForContacts(String a, String b)
       {
            Contact[] var = [Select Id, Name from Contact where lastname =:a and MailingPostalCode =:b];
            return var;
           
       }
}