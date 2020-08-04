### Update Assessment Settings for the org

In order for the preview functionality to work correctly, org values for the Assessment Settings need to be updated.

- Go to `Setup > Custom Settings`
- Click the `Manage` link to next to the `Assessment Settings` record

![CustomSetting](/docs/images/custom-settings/custom-settings-list.png?raw=true)


- Click the `New` button above the `Default Organization Level Value` section.

![CustomSetting](/docs/images/custom-settings/custom-settings-org-button.png?raw=true)

- Update the custom setting with the following parameters and click the `Save` button

    - Chat Deployment Name : `The developer name of your Chat Deployment`
    - Chat Button Name: `The developer name of your Chat Button`
    - ESW Deployment Dev Name : `The developer name of your Embedded Service Deployment`

- The following parameters can be obtained from the from the Embedded Service Deployment [code](/docs/guides/EmbeddedService.md#get-the-embedded-deployment-code)) :

    - Community URL : `Embedded Service deployment community url`
    - Live Agent URL : `Embedded Service deployment live agent url`
    - Live Agent Content URL : `Embedded Service deployment live agent content url`
    - ESW Live Agent Dev Name : `Embedded Service deployment ESW Live Agent Dev Name`

![CustomSetting](/docs/images/custom-settings/custom-settings-values.png?raw=true)

Next Step, [Add a new CORS entry in your org](CORS.md)