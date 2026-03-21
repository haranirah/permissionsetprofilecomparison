public with sharing class SlackHotelBookingNotifier {

    private static final String SLACK_BOT_TOKEN = 'xoxb-9210374808119-9226429963255-QOyI1lnDw9N8y5CBb4yPqawg';
    private static final String SLACK_API_URL = 'https://slack.com/api/chat.postMessage';

    public class SlackInput {
        @InvocableVariable(required=true)
        public String channel;

        @InvocableVariable(required=true)
        public String hotelName;

        @InvocableVariable(required=true)
        public String city;

        @InvocableVariable(required=true)
        public String customerName;

        @InvocableVariable(required=true)
        public String checkInDate;

        @InvocableVariable(required=true)
        public String checkOutDate;

        @InvocableVariable(required=true)
        public String roomType;

        @InvocableVariable(required=true)
        public String numberOfGuests;

        @InvocableVariable
        public String servicesAvailed;

        @InvocableVariable
        public String totalAmount;

        @InvocableVariable
        public String reservationId; // ✅ NEW FIELD
    }

    public class SlackOutput {
        @InvocableVariable
        public String responseMessage;
    }

    @InvocableMethod(label='Send Slack Hotel Booking Notification')
    public static List<SlackOutput> sendHotelBookingNotification(List<SlackInput> inputList) {
        List<SlackOutput> results = new List<SlackOutput>();

        for (SlackInput input : inputList) {
            String normalizedChannel = formatChannelName(input.channel);

            String message = '🏨 *New Hotel Booking Alert!*\n' +
                             '*Reservation ID:* ' + input.reservationId + '\n' + // ✅ ADDED HERE
                             '*Hotel:* ' + input.hotelName + '\n' +
                             '*City:* ' + input.city + '\n' +
                             '*Customer:* ' + input.customerName + '\n' +
                             '*Check-In:* ' + input.checkInDate + '\n' +
                             '*Check-Out:* ' + input.checkOutDate + '\n' +
                             '*Room Type:* ' + input.roomType + '\n' +
                             '*Guests:* ' + input.numberOfGuests + '\n' +
                             (String.isNotBlank(input.servicesAvailed) ? '*Services:* ' + input.servicesAvailed + '\n' : '') +
                             '*Total Amount:* ₹' + input.totalAmount;

            String response = sendToSlack(normalizedChannel, message);

            SlackOutput output = new SlackOutput();
            output.responseMessage = response;
            results.add(output);
        }

        return results;
    }

    private static String formatChannelName(String channel) {
        if (String.isBlank(channel)) return '#general';
        String cleanChannel = channel.trim().toLowerCase().replaceAll('\\s+', '');
        return cleanChannel.startsWith('#') ? cleanChannel : '#' + cleanChannel;
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