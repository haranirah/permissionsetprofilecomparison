public with sharing class MSGraphService {

    // Response wrapper
    public class GraphResponse {
        public Integer statusCode;
        public String body;
    }

    // Create Outlook Event
    public static GraphResponse createEvent(String organizerUserPrincipalName, Map<String, Object> eventPayload) {

        String endpoint = 'callout:MSGraph/v1.0/users/' +
            EncodingUtil.urlEncode(organizerUserPrincipalName, 'UTF-8') +
            '/events';

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSON.serialize(eventPayload));
        req.setTimeout(120000);

        Http http = new Http();
        HttpResponse res = http.send(req);

        GraphResponse response = new GraphResponse();
        response.statusCode = res.getStatusCode();
        response.body = res.getBody();

        return response;
    }

    // Helper to build event payload
    public static Map<String,Object> buildEventPayload(
        String subject,
        String bodyHtml,
        Datetime startDt,
        String startTz,
        Datetime endDt,
        String endTz,
        List<String> attendeeEmails,
        Boolean isOnlineMeeting
    ) {

        Map<String,Object> eventPayload = new Map<String,Object>();
        eventPayload.put('subject', subject);

        Map<String,Object> body = new Map<String,Object>();
        body.put('contentType','HTML');
        body.put('content', bodyHtml);
        eventPayload.put('body', body);

        // Start time
        Map<String,Object> startMap = new Map<String,Object>();
        startMap.put('dateTime', startDt.format('yyyy-MM-dd\'T\'HH:mm:ss'));
        startMap.put('timeZone', startTz);
        eventPayload.put('start', startMap);

        // End time (fixed variable name)
        Map<String,Object> endTimeMap = new Map<String,Object>();
        endTimeMap.put('dateTime', endDt.format('yyyy-MM-dd\'T\'HH:mm:ss'));
        endTimeMap.put('timeZone', endTz);
        eventPayload.put('end', endTimeMap);

        // Attendees
        List<Object> attendees = new List<Object>();

        for (String email : attendeeEmails) {

            Map<String,Object> attendee = new Map<String,Object>();

            Map<String,Object> emailAddress = new Map<String,Object>();
            emailAddress.put('address', email);

            attendee.put('emailAddress', emailAddress);
            attendee.put('type', 'required');

            attendees.add(attendee);
        }

        eventPayload.put('attendees', attendees);

        // Teams meeting
        eventPayload.put('isOnlineMeeting', isOnlineMeeting);

        if (isOnlineMeeting) {
            // Optional
            // eventPayload.put('onlineMeetingProvider','teamsForBusiness');
        }

        // Optional settings
        eventPayload.put('responseRequested', false);
        eventPayload.put('allowNewTimeProposals', false);

        return eventPayload;
    }
}