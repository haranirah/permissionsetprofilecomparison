public class AccountHandler {
    public static Account insertNewAccount(String s)
    {
        if(String.IsEmpty(s))
        {
            return null;
        }
        
        Account acct = new Account();
        acct.name = s;
        
        try
        {
          insert acct;
          return acct;    
        }
        catch (DmlException e)
        {
            return null;
        }
    }

}