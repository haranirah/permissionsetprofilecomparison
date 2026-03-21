public with sharing class RoomServiceRequestHandler {

    public class RoomServiceInput {
        @InvocableVariable(required=true)
        public String reservationId;

        @InvocableVariable(required=true)
        public String requestType; // Food, Spa, Housekeeping, Other

        @InvocableVariable(required=true)
        public String requestedItem; // e.g., Burger, Pizza
    }

    public class RoomServiceOutput {
        @InvocableVariable
        public String message;
    }

    @InvocableMethod(label='Create Room Service Request')
    public static List<RoomServiceOutput> createRequest(List<RoomServiceInput> inputs) {
        List<RoomServiceOutput> results = new List<RoomServiceOutput>();

        for (RoomServiceInput input : inputs) {
            try {
                Room_Service_Request__c req = new Room_Service_Request__c(
                    Reservation_ID__c = input.reservationId,
                    Request_Type__c = input.requestType,
                    Requested_Item__c = input.requestedItem,
                    Status__c = 'New'
                );
                insert req;

                RoomServiceOutput output = new RoomServiceOutput();
                output.message = 'Room service request submitted successfully for ' + input.requestType;
                results.add(output);
            } catch(Exception e) {
                RoomServiceOutput output = new RoomServiceOutput();
                output.message = 'Error: ' + e.getMessage();
                results.add(output);
            }
        }

        return results;
    }
}