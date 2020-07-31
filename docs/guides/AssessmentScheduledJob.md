# Schedule the Assessment Schedule Actions Job

This application includes an Apex job that cares of the following :

- Flagging assessment sessions that were left with `In Progress` status as `Abanadoned` if the status hasn't changed in 2 hours
- Deleting associated Transcript records (e.g. LiveChatTranscript or MessagingSessions) for Assessment Definition where the `Delete Transcript on Completion` is enabled

To enable the job to run once a day go to `Setup > Apex` and click the `Schedule Apex` button

![Scheduled](/docs/images/apex-scheduler/schedule-apex-button.png?raw=true)

Next, configure a new schedule job with the following parameters:

    - Job Name : `AssessmentScheduledActions` (suggested)
    - Apex Class : `AssessmentScheduledActions` (if you can't find the class you might need to first find the class, click edit and then save)
    - Scheduled Apex execution : `Set it to run weekly, and select every day`

![Scheduled](/docs/images/apex-scheduler/daily-schedule.png?raw=true)

If you want to run this job with higher frequency, you can configure it to run every hour by opening the Developer Console, go to `Debug > Open Execute Anonymous Window` and run the following command:

`System.schedule('Hourly', '0 0 * * * ?', new AssessmentScheduledActions());`

![Scheduled](/docs/images/apex-scheduler/hourly-schedule.png?raw=true)

Once you have schedule the apex code you should see AssessmentScheduledActions listed under `Setup > Scheduled Jobs`

![Scheduled](/docs/images/apex-scheduler/scheduled-job-list.png?raw=true)