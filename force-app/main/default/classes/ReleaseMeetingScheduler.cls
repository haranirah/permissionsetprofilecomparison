global class ReleaseMeetingScheduler implements Schedulable {

    global void execute(SchedulableContext sc) {

        Date today = Date.today();

        Datetime startOfDay = Datetime.newInstance(today, Time.newInstance(0,0,0,0));
        Datetime endOfDay   = Datetime.newInstance(today, Time.newInstance(23,59,59,999));

        List<Release_Schedule__c> rows = [
            SELECT Id, Release_Number__c, CAB_Number__c,
                   GoNoGo_Start__c, Deployment_Start__c, Recipients__c
            FROM Release_Schedule__c
            WHERE GoNoGo_Start__c >= :startOfDay
            AND GoNoGo_Start__c <= :endOfDay
        ];

        String organizer = 'releasebot@yourcompany.com';
        String ctTimeZone = 'Central Standard Time';

        for (Release_Schedule__c r : rows) {

            String subjectGo =
                '#' + r.CAB_Number__c + ' - ' +
                r.Release_Number__c + ' - ' +
                r.GoNoGo_Start__c.format('MMMM d') + ' ' +
                r.GoNoGo_Start__c.format('hh:mm a') +
                ' CT - Deployment Plan WalkThru - Go / No Go';

            String body =
                'The following Teams Meeting is the same bridge for the duration of our deployment for ' +
                r.Release_Number__c +
                '.<br/><br/>...';

            List<String> attendees = new List<String>();

            if (r.Recipients__c != null) {
                for (String e : r.Recipients__c.split(',')) {
                    String t = e.trim();
                    if (!String.isEmpty(t)) {
                        attendees.add(t);
                    }
                }
            }

            Datetime startDt = r.GoNoGo_Start__c;
            Datetime endDt = r.GoNoGo_Start__c.addMinutes(30);

            Map<String,Object> payload =
                MSGraphService.buildEventPayload(
                    subjectGo,
                    body,
                    startDt,
                    ctTimeZone,
                    endDt,
                    ctTimeZone,
                    attendees,
                    true
                );

            System.enqueueJob(new CreateGraphEventJob(organizer, payload));

            Datetime depStart = r.Deployment_Start__c;

            String subjectDep =
                '#' + r.CAB_Number__c + ' - ' +
                r.Release_Number__c + ' - ' +
                depStart.format('MMMM d') + ' ' +
                depStart.format('hh:mm a') +
                ' CT - Deployment';

            Map<String,Object> payloadDep =
                MSGraphService.buildEventPayload(
                    subjectDep,
                    body,
                    depStart,
                    ctTimeZone,
                    depStart.addHours(2),
                    ctTimeZone,
                    attendees,
                    true
                );

            System.enqueueJob(new CreateGraphEventJob(organizer, payloadDep));
        }
    }
}