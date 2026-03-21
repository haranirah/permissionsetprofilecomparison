public class primarycondelTriggerHandler {

    public static void primarycon(List<Contact> listofoldcontacts)
    {
        for(Contact con:listofoldcontacts)
          {
             if(con.level__c =='Primary')
             {
                 con.addError('You cannot delete the primary contact');
             }
          }
    }


}