public with sharing class SlackNotificationService {

    private static final String SLACK_BOT_TOKEN = '';
    private static final String SLACK_API_URL = 'https://slack.com/api/chat.postMessage';

    public class SlackInput {
        @InvocableVariable(required=true)
        public String channel;
        
        @InvocableVariable(required=true)
        public String bookingNumber; // Auto Number field from Booking__c.Name

        @InvocableVariable(required=true)
        public String city;

        @InvocableVariable(required=true)
        public String customerName;

        @InvocableVariable(required=true)
        public String vehicleDetails;

        @InvocableVariable(required=true)
        public String startDate;

        @InvocableVariable(required=true)
        public String endDate;

        @InvocableVariable(required=true)
        public String withDriver; // 'Yes' or 'No'
    }

    public class SlackOutput {
        @InvocableVariable
        public String responseMessage;
    }

    @InvocableMethod(label='Send Slack Booking Notification with Details')
    public static List<SlackOutput> sendBookingNotification(List<SlackInput> inputList) {
        List<SlackOutput> results = new List<SlackOutput>();

        for (SlackInput input : inputList) {
            String cleanChannel = formatChannelName(input.channel);

            String message = '🚗 *New Booking!*\n' +
                 '*Booking Number:* ' + input.bookingNumber + '\n' +
                 '*City:* ' + input.city + '\n' +
                 '*Customer:* ' + input.customerName + '\n' +
                 '*Vehicle:* ' + input.vehicleDetails + '\n' +
                 '*Start Date:* ' + input.startDate + '\n' +
                 '*End Date:* ' + input.endDate + '\n' +
                 '*With Driver:* ' + input.withDriver;

            String response = sendToSlack(cleanChannel, message);

            SlackOutput output = new SlackOutput();
            output.responseMessage = response;
            results.add(output);
        }

        return results;
    }

    private static String formatChannelName(String channel) {
        if (String.isBlank(channel)) return 'general'; // default fallback

        // Otherwise clean up channel name (remove special characters, spaces)
        return channel.trim().toLowerCase().replaceAll('[^a-z0-9_-]', '');
    }

    private static String sendToSlack(String channel, String message) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(SLACK_API_URL);
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer ' + SLACK_BOT_TOKEN);
        request.setHeader('Content-Type', 'application/json; charset=utf-8');

        Map<String, Object> payload = new Map<String, Object>{
            'channel' => channel,
            'text'    => message
        };

        request.setBody(JSON.serialize(payload));

        try {
            HttpResponse response = http.send(request);
            System.debug('Slack Response Status: ' + response.getStatus());
            System.debug('Slack Response Body: ' + response.getBody());
            return 'Status: ' + response.getStatus() + ' | Body: ' + response.getBody();
        } catch(Exception e) {
            System.debug('Failed to send Slack message: ' + e.getMessage());
            return 'Failed: ' + e.getMessage();
        }
    }
}