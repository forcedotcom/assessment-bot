# Conversational Assessments

Assessments represent a conversation where a score, recommendation or feedback is provded to end users based on their responses. The goal of this project is to provide a framework for building such assessments through simplec configuration using Einstein Bots + Digital Engagement. Assessments built in this framework provide out of the box support for signal detection, reporting and transcript deletion.  

Assessment definition trees can be configured through a Custom Object and a pre-configured Einstein Bot will be able to interpret and serve the assessment.

## Setup Instructions


### Pre-requisites

A Salesforce org with Chat and Einstein Bots enabled. Steps on how to enable these are available [here](docs/guides/PreRequisites.md)

### Installation steps

#### Method 1 : Un-managed package deployment

You can install this application by using one of the package installation links available in the "Releases" section of this repository. 
Once you go to that link it will guide through the setup process. Select the "Install for Admins Only" option, once installed you should see the package listed under Installed Packages.

![Package Install Wizard2](/docs/images/package/install-2.png?raw=true)

#### Method 2 : Non-Scratch Org quick deploy

<a href="https://githubsfdeploy.herokuapp.com">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

#### Method 3 : Scratch Org quick deploy

[![Deploy](https://deploy-to-sfdx.com/dist/assets/images/DeployToSFDX.svg)](https://deploy-to-sfdx.com/)

### Post-installation steps

Once you've installed the Conversation Assessments package, you will need to configure the complete the following steps for the package to fully work.

1. [Enable Omni-Channel](docs/guides/Omni.md)
2. [Create a Chat Deployment and Chat Button](docs/guides/Chat.md)
3. [Enable Communities and create a Community](docs/guides/Communities.md)
4. [Create an Embedded Service Deployment](docs/guides/EmbeddedService.md)
5. [Create en Embedded Chat Menu](docs/guides/EmbeddedChatMenu.md)
6. [Update Assessment Manager custom setting](docs/guides/CustomSetting.md)
7. [Add a new CORS entry in your org](docs/guides/CORS.md)
8. [Update the Assessment Bot configuration](docs/guides/BotConfig.md)
9. [Assign the Assessment Admin permission set to your user](docs/guides/AdminPermSet.md)
10. [Open the Assessment Manager app](docs/guides/AssessmentManagerApp.md)
11. [Create and test your first Assessment](docs/guides/HelloWorldAssessment.md)
12. [Schedule Assessment Session apex jobs](docs/guides/AssessmentScheduledJob.md)

## User Guide

To learn more about how to create, report and deploy assessments you can refer to the [User Guide](docs/guides/UserGuide.md)