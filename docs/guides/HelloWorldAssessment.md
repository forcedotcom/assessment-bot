# Create a new Assessment Definition

- Go to the Assessment Definitions tab and click the `New` button and set the following parameters:

    - Assessment Definition Name : `Hello World Assessment`
    - Assessment Definition Id : `Hello World Assessment`
    - Active : `enabled`
    - Initial Item Name : `Initial Message`
    - You can leave other fields blank or use the existing defaults

![Assessment](/docs/images/sample-assessment-def/assess-def-new.png?raw=true)

- Go to Assessment Definition details and click the `Configuration` tab 
- Click the `New` button under the `Assessment Definition Items` section and enter the following parameters:

    - Record Type : `Alert`
    - Assessment Definition Item Name : `Initial Message`
    - Message : `Hello World`

![Assessment](/docs/images/sample-assessment-def/assess-def-item.png?raw=true)

# Preview the Assessment Definition

- Go to the `Preview` tab under the Assessment Definition details, you should see a `Chat with an Expert` button on the bottom right

![Assessment](/docs/images/sample-assessment-def/assess-def-preview-1.png?raw=true)

*If the button doesn't render correctly verify your custom setting parameters and then reload the page*

- Click on the button and you should see a Bot respond with the initial message previously configured

![Assessment](/docs/images/sample-assessment-def/assess-def-preview-2.png?raw=true)

If you are able to see the Bot response you should be ready to create new Assessment Definitions. For more info read the user guide.

Next Step, [Schedule Assessment Session apex jobs](AssessmentScheduledJob.md)