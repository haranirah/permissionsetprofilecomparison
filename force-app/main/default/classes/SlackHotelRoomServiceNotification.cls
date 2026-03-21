public with sharing class SlackHotelRoomServiceNotification {
    
    private static final String SLACK_BOT_TOKEN = ''; // Replace with actual token
    private static final String SLACK_API_URL = 'https://slack.com/api/chat.postMessage';

    public class SlackInput {
        @InvocableVariable(required=true)
        public String reservationId; // Input: Reservation_ID__c

        @InvocableVariable(required=true)
        public String slackChannel; // Slack Channel name 
    }

    public class SlackOutput {
        @InvocableVariable
        public String responseMessage;
    }

    @InvocableMethod(label='Send Slack Notification by Reservation')
    public static List<SlackOutput> sendNotifications(List<SlackInput> inputs) {
        List<SlackOutput> results = new List<SlackOutput>();

        Set<String> reservationIds = new Set<String>();
        for (SlackInput input : inputs) {
            reservationIds.add(input.reservationId);
        }

        // Query related room service requests
        Map<String, List<Room_Service_Request__c>> reservationToRequests = new Map<String, List<Room_Service_Request__c>>();
        for (Room_Service_Request__c req : [
            SELECT Name, Request_Type__c, Requested_Item__c, Status__c, Reservation_ID__c
            FROM Room_Service_Request__c
            WHERE Reservation_ID__c IN :reservationIds
        ]) {
            if (!reservationToRequests.containsKey(req.Reservation_ID__c)) {
                reservationToRequests.put(req.Reservation_ID__c, new List<Room_Service_Request__c>());
            }
            reservationToRequests.get(req.Reservation_ID__c).add(req);
        }

        for (SlackInput input : inputs) {
            List<Room_Service_Request__c> requests = reservationToRequests.get(input.reservationId);
            SlackOutput output = new SlackOutput();

            if (requests == null || requests.isEmpty()) {
                output.responseMessage = 'No room service requests found for Reservation ID: ' + input.reservationId;
                results.add(output);
                continue;
            }

            String channel = formatChannelName(input.slackChannel);

            for (Room_Service_Request__c req : requests) {
                String message = '🛎️ *Room Service Notification*\n' +
                                 '*Reservation ID:* ' + req.Reservation_ID__c + '\n' +
                                 '*Request ID:* ' + req.Name + '\n' +
                                 '*Request Type:* ' + req.Request_Type__c + '\n' +
                                 '*Requested Item:* ' + req.Requested_Item__c + '\n' +
                                 '*Status:* ' + req.Status__c;

                String response = sendToSlack(channel, message);
                output.responseMessage = response;
                results.add(output);
            }
        }

        return results;
    }

    private static String formatChannelName(String channel) {
        if (String.isBlank(channel)) return 'general';
        return channel.trim().toLowerCase().replaceAll('[^a-z0-9_-]', '');
    }

    private static String sendToSlack(String channel, String message) {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(SLACK_API_URL);
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + SLACK_BOT_TOKEN);
        req.setHeader('Content-Type', 'application/json; charset=utf-8');

        Map<String, Object> payload = new Map<String, Object>{
            'channel' => channel,
            'text'    => message
        };

        req.setBody(JSON.serialize(payload));

        try {
            HttpResponse res = http.send(req);
            return 'Status: ' + res.getStatus() + ' | Body: ' + res.getBody();
        } catch (Exception e) {
            return 'Failed: ' + e.getMessage();
        }
    }
}