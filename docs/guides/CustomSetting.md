### Update Assessment Settings for the org

In order for the preview functionality to work correctly, org values for the Assessment Settings need to be updated.

- Go to `Setup > Custom Settings`
- Click the `Manage` link to next to the `Assessment Settings` record

![CustomSetting](/docs/images/custom-settings/custom-settings-list.png?raw=true)


- Click the `New` button above the `Default Organization Level Value` section.

![CustomSetting](/docs/images/custom-settings/custom-settings-org-button.png?raw=true)

- Update the custom setting with the following parameters and click the `Save` button

    - ESW Channel Name : `The developer name of your Channel Menu`
    - Live Agent URL : `Your live agent url`  (you can get this from the embedded [channel menu code](/docs/guides/EmbeddedChatMenu.md#get-the-embedded-menu-deployment-code))

![CustomSetting](/docs/images/custom-settings/custom-settings-values.png?raw=true)

Next Step, [Add a new CORS entry in your org](CORS.md)