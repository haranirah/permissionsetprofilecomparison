public class CreateGraphEventJob implements Queueable, Database.AllowsCallouts {

    private String organizerUser;
    private Map<String,Object> eventPayload;

    public CreateGraphEventJob(String organizerUserPrincipalName, Map<String,Object> payload) {
        this.organizerUser = organizerUserPrincipalName;
        this.eventPayload = payload;
    }

    public void execute(QueueableContext context) {

        MSGraphService.GraphResponse response =
            MSGraphService.createEvent(organizerUser, eventPayload);

        System.debug('Graph create event status: ' + response.statusCode);
        System.debug('Graph create event body: ' + response.body);

        // Optional: You can store response in a custom logging object for audit
    }
}