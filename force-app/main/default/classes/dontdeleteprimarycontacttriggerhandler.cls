public class dontdeleteprimarycontacttriggerhandler {

    public static void main(List<Contact> listofoldcontacts)
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