## Create a new Embedded Service Deployment

- Go to `Setup > Embedded Service Deployments` and click the `New Deployment` button
- Create a new deployment with the following parameters and click the `Save` button

    - Embedded Service Deployment Name : `Assessment Bot` (suggested)
    - API Name : `Assessment_Bot` (suggested)
    - Site endpoint : `YOUR COMMUNITY NAME`

![Embedded](/docs/images/embedded-service/snapin-create.png?raw=true)

## Enable Chat Settings for your new deployment

- Click the `Start` button under the `Chat Settings` section for the Embedded Service Deployment you just created
- Configure Chat settings with the following parameters and click the `Save` button

    - Chat Deployment : `Assessment Deployment` (or the name of your previously created Chat Deployment)
    - Chat Button : `Assessment Button` (or the name of your previously created Chat Button)
    - You can leave other fields blank or use the existing defaults.

![Embedded](/docs/images/embedded-service/snapin-chat-enabled.png?raw=true)

## Disable the pre-chat form page

- After enabling Chat Settings, click the `Edit` button under the `Chat Settings` section for the Embedded Service Deployment you just created

![Embedded](/docs/images/embedded-service/snapin-chat-button.png?raw=true)

- Disable the pre-chat page checkbox

![Embedded](/docs/images/embedded-service/snapin-disable-prechat.png?raw=true)

## Enable Support Guest API

- If you see a warning under the Offline Support section related to `Guest Access to the Support API`, click on the Enable link.

![Embedded](/docs/images/embedded-service/snapin-enable-guest-api.png?raw=true)


## Get the Embedded Deployment Code

- In the Embedded Deployment details, click the `Get Code` button under the Embedded Service Code Snippets section.

![Embedded](/docs/images/embedded-service/snapin-deployment-code.png?raw=true)

- Copy the highlighted params as they will need to be stored in a custom setting in the next step

![Embedded](/docs/images/embedded-service/snapin-deployment-code-params.png?raw=true)


Next Step, [Update Assessment Manager custom setting](CustomSetting.md)