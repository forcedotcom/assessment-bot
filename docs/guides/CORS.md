# Add a new CORS (Cross-Origin Resource Sharing) entry in your org

In order for the assessment preview to render correctly, you need to add a new CORS entry that can allow visual force pages to be rendered in the Lightning UI.

- Go to `Setup > CORS` and click the `New` button
- The value of the Whitelisted origin will be different depending on wheter you have a custom domain enabled for your org. 

    - IF you have My Custom Domain enabled, then the value should be `https://YOUR-DOMAIN-NAME--c.visualforce.com` (e.g. `https://mycompany--c.visualforce.com`)
    - IF you do not have a Custom Domain enabled, then the value should be `https://c.YOUR-INSTANCE.visual.force.com` (e.g. `https://c.na30.visual.force.com`)

- Enter the corresponding value for your domain and click the `Save` button

![CORS](/docs/images/cors/cors-new.png?raw=true)

## How do I determine if I have my domain enabled and what value should I use?

With a custom domain enabled, you replace the instance URL that Salesforce assigned you, like https://na30.salesforce.com, with your chosen domain name, like https://mycompany.my.salesforce.com.

Next Step, [Update the Assessment Bot configuration](BotConfig.md)