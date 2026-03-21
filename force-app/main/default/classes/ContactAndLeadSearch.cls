public class ContactAndLeadSearch {
    public static List<List<SObject>> searchContactsAndLeads(String searchName) {
        // Perform SOSL search on Contacts and Leads based on FirstName or LastName
        List<List<SObject>> searchResults = [FIND :searchName IN NAME FIELDS 
                                             RETURNING Contact(FirstName, LastName), 
                                                       Lead(FirstName, LastName)];
        return searchResults;
    }
}