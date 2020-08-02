IMPORTANT: Make sure you've completed the Post-installation steps described [here](/README.md) before going over this guide.

# Overview

Compared to a survey, an assessment is closer to a conversation where a score, recommendation or feedback is provided to the end user based on their responses.

The Conversation Assessments package provides a solution for delivering assessments in a conversational form through Salesforce Einstein Bots and analyzing the results using the reporting capabilities of the Salesforce Platform.

The following guide will explain in more detail the capabilities of the solution.

# User Roles

Before you can start using the application, your user needs to been assigned to one of the 3 different user permission sets. Select the appropriate permission based on the user role :

### Assessment Admin

Assign this permission set to any user that should have Administrative access for all Assessment Definitions and Assessment Sessions. This permission set will give View All and Modify All access for all Assessment related objects.

### Assessment User

Assign this permission set to users that need access to create Assessments but shouldn't need access to other assessments created by other users or Edit access to Assessment sessions.

### Assessment Bot

It's recommended to assign a specific user to a Bot configuration to simplify audit and permission assignment. If you're using a Custom Bot User, this permission set will provide the minimum permissions needed for the Bot to deliver assessments. 
A Bot user should use this permission or the Assessment Admin permission set.

# Assessment Management Application

Once your user has been assigned to one of the permission sets, you should be able to see the `Assessment Manager` application in the App Launcher:

![App](/docs/images/assessment-manager-app/app-selection.png?raw=true)

![App](/docs/images/assessment-manager-app/assessment-manager-app.png?raw=true)

This application provides entry points for configuring and analyzing Assessment Definitions. To start creating an assessment definition, click on the `Assessment Definition` tab.

![App](/docs/images/assessment-manager-app/assessment-manager-tabs.png?raw=true)


# Scenario

Throughout this guide, we will work on creating solving a hypothetical scenario of building an assessment that can give an internet speed recommendation for user looking to buy an internet package.  The following guide illustrates the decision tree that will be used for the assessment.

![UserGuide](/docs/images/userguide/decision-tree.png?raw=true)

This assessment will start by greeting the user with a Message, then asking for consent to continue the assessment. If not consent is given, we will redirect to a No Consent message and fire a `No Consent` signal on entry to this message and then end the chat. If user consent is given, we will start asking 3 questions about their device and usage situation. The first question will show a couple of options, if the `12 +` option is selected, we will fire a `High Device Volume` signal and continue to the next item.

Next, we will ask a couple of True/False question to determine if the user does Streaming or Gaming and fire corresponding signals for each of these actions.  Once we have collected the signals, we will move on to doing a few decision based on the collected signals. Based on the collected signals we will show an alert to the user indicating the recommended internet speed for their use case.


# Application Components

### Assessment Definition

An Assessment definition represents is the main object for an Assessment, assessment-level properties are configured here. The Signals, Messages, Questions, Decision items will be created under the assessment definition. Additionally, Assessment sessions will be linked to the corresponding Assessment Definition for reporting purposes.


### Assessment Definition Signal

Represents a particular signal to be analyzed as part of an Assessment Definition. Signals can be fired from Assessment Definition Item events or when certain choices are selected. Signals that are only relevant for internal decision making and not needed for reporting purposes can be marked as `Internal` signals and will be excluded from the out of the box reports and dashboards.

### Assessment Definition Item

An Assessment Definition Item represents a step in the Assessment Definition decision tree. There are different types of items : `Message`, `Alert`, `Question` and `Decision`. Each item needs a name which should be unique under an Assessment Definition. An item should indicate the next item to be executed as part of the `Next Item Name (Default Outcome)` field or as part of Question choices. If no next item name can be determined or if the Next Item Name is empty then it will be treated as an End of Chat operation.

### Assessment Definition Item Choices

For Assessment Definition Items of type `Question` and where Question Type is `Choices`, the different choices available for the user will be stored in this object along with an optional `Next Item Name` if the default next item should be overwritten and a Signal to be fired on selection of a specific choice.

### Assessment Definition Decision Signal

Assessment Definition Items of type `Decision` perform conditional logic based on the signals configured in this object. By default, the `Decision` item performs and `AND` operation of all the configured signals but this can be override by setting the `Next Item Condition Value` to `OR` in the Assessment Definition Item.

### Assessment Definition Deployment

This object stores a reference to the Developer Name of the Channel Deployments on which a particular Assessment Definition should be served. It's required to have an entry here for the Assessment to be served outside of the `Preview` mode. 

### Assessment Session

An Assessment Session will be created for every chat session on any of the Channel Deployments on which the Assessment is delivered. Assessment Sessions keep track of the status of the Assessment along with a link to the source Transcript record in Salesforce (e.g. LiveChatTranscript or MessagingSession)

### Assessment Session Signal

This object will store all of the signals that have been attached to a particular Assessment session and is used for reporting purposes.


# Configuring an Assessment Definition

Let's start by creating an Assessment Definition. 
Go to the Assessment Definition tab and click the `New` button. 

We will create a new Assessment called `Internet Speed Assessment`.

`Assessment Definition Id` : this field is required and this has to be a unique identifier across all Assessment definitions.

`Active` : checkbox  used to determine if a Bot should render the Assessment or not, if this is un-checked the Bot will just end the session. You can use this to quickly disable an Assessment as part of maintenance.

`Delete Transcript on Completion` : this checkbox can be enabled if you don't want to use the conversation transcript in Salesforce. If this option is enabled, a schedule process that runs once a day will delete all Transcripts for Assessment Sessions that have been completed or abandoned. 

`Initial Item Name` will be the name of the the first Item that will be used for the Assessment. The value you enter here must match the name of an Assessment Definition that you will create next under the Assessment Definition.

# Creating Assessment Definition Signals

Once we have created an Assessment Definition, we will create the Signals that we want to track for the Assessment by going to the `Details` tab in our Assessment Definition and click the `New` button under the Assessment Definition Signals section.

For our Internet Speed Assessment scenario, we will create the following signals:

- High Device Volume (Internal)
- Streaming (Internal)
- Gaming (Internal)
- No Consent
- 1000 Mbps
- 600 Mbps
- 300 Mbps
- 100 Mbps

For our use case, the first 3 signals will be configured as `Internal` since we will need these signals to make some conditional logic but don't provide value in Reports and Dashboards. Once we have configured our signals, our Assessment Definition should look like this:

![UserGuide](/docs/images/userguide/definition-signals.png?raw=true)

# Assessment Definition Item Types

We are now ready to create the different steps (aka items) for our Assessment. We will use the diagram above as a guide to create the different items and links. Let's start with the `Initial Message` item we configured as part of our Assessment Definition.

To start creating items, go to the `Configuration` tab under the Assessment definition record and click the `New` button under the `Assessment Definition Items` section. Our first item will be an item of type `Message`

## Message & Alert Items

Message and Alert items are used to show a message to end user without expecting to process a response. The different between an `Alert` and a `Message` type of item is that the `Alert` message will display a button to make allow the user to confirm that they have read a message. 

Back to our scenario, we will first create the greeting message in our assessment. Make sure the `Assessment Definition Item Name` matches the name of the initial item you gave in your Assessment Definition record. 

`Type` will be configured to `Message` as we only want to render a message and move on to the next item.

`Message` will contain the message that will be displayed to the end user, this message can contain up to 255 characters.

`Next Item Name (Default Outcome)` should contain the name of the next item to be displayed after this item. We will set it to be `Consent Question` and create an Item with this name after saving this record.

![UserGuide](/docs/images/userguide/message1.png?raw=true)

## Question Item

Question Items are steps in which we expect a user response. It's possible to conditionally select the next item based on a user response or fire specific signals when a specific choice for a question is selected. We'll cover the different types of question below.

### True False

Continuing with our use case, in our first question we want to ask for consent to continue with the assessment. Let's create a True/False question to capture this consent and call this item `Consent Question`.

`Type` will be configured to `Question`

`Question Type` will be configured to `TrueOrFalse` as we expect a Yes or No type of answer

`Message` will contain the question message that will be displayed to the end user, this message can contain up to 255 characters.

`Next Item Name (Default Outcome)` will contain the name of the next item (`Device Number Question`) when a user responds with a positive answer

Conditional Next Item Information will be configured for this question since we only want to redirect to `Device Number Question` if the responsive is true, otherwise we want to go to the `No Consent Message` item.

`Next Item Conditional Operator` will be set to `Equal To`

`Next Item Condition Value` will be set to `true` to indicate that only if the response is `Equal To TRUE` then we will move on the Default Outcome item, otherwise we will move the Other Outcome Item.

`Next Item Name Other Outcome` will be set to `No Consent Message`

![UserGuide](/docs/images/userguide/question1.png?raw=true)


### Choices


A Choices question provides a list of options to select from. The next step in our assessment is to present a choice question to ask for the number of devices connected to the network. Let's create a Choices question to capture this response and call it `Device Number Question`.

`Type` will be configured to `Question`

`Question Type` will be configured to `Choices` as we expect a Yes or No type of answer

`Message` will contain the question message that will be displayed to the end user, this message can contain up to 255 characters.

`Next Item Name (Default Outcome)` will contain the name of the next item (`Streaming Question`)

Since we just want to move on to the next item regardless of the user response there is no need to configure any parameters under the Conditional Next Item Information.

![UserGuide](/docs/images/userguide/question2.png?raw=true)

Now it's time to add the choices under this question. To do this, go into the details for the `Device Number Question` item and click the `New` button under the `Assessment Definition Item Choices` section.

![UserGuide](/docs/images/userguide/choices-new-button.png?raw=true)

And create 2 new choices, one for the `1-11` and another one for the `12+` options. Leave the `Next Item Name (Override)` field empty for both choices as we don't want to add any conditional redirection logic based on response, but select make sure you set the `Signal (On Selection)` field to `High Device Volume` since we want to fire that signal when the `12+` choice is selected.

![UserGuide](/docs/images/userguide/choice1.png?raw=true)

![UserGuide](/docs/images/userguide/choice2.png?raw=true)

![UserGuide](/docs/images/userguide/choices-list.png?raw=true)


### Number & Dates

It's also possible to capture Number and Date responses and run conditional logic similar to how it was done for the True/False question items in this example. `Greater Than` and `Less Than` operators will be accessible for conditional logic when selecting these question types.

## On-Condition Signal Events

If you need to fire signals based on the outcome of the conditional logic of an item or on a true/false response for a question, you can use `Assessment Definition Item Events` option under Question Items.

In our Internet Speed Assessment, our next step is to ask if the user streams shows or movies. Let's create a True/False question for this like below:

![UserGuide](/docs/images/userguide/question3.png?raw=true)

Once the question has been created, go the question Details and click the `New` button under the `Assessment Definition Item Events` section. Here we will configure the `On True Condition` event to fire the internal `Streaming` signal.

![UserGuide](/docs/images/userguide/event1.png?raw=true)

Once we have saved the item event, let's create a new question under our Assessment Definition but this time to ask about gaming and fire the corresponding signal. 

![UserGuide](/docs/images/userguide/question4.png?raw=true)

## Decision Item

As shown in the `Gaming Question` item, the next item in our decision tree is an item of type `Decision` called `Gaming and Streaming Decision`. 

Decision items provide a way for routing to another item based on the signals that have been collected so far as part of an Assessment Session. For our example, we want give a 1000 Mbps recommendation if we have fired the `Gaming` AND `Streaming` signals. 

Let's configure this item by creating a `Decision` step with the following parameters:

`Type` will be configured to `Decision`

`Next Item Name (Default Outcome)` will contain the name of the next item (`1000 Mbps Recommendation`) if the decision outcome evaluates to true

`Next Item Condition Value` will define the Conditional Logic to be used when comparing signals for this decision. By default it will do an AND condition between all configured signals but this can also be configured to perform and OR condition.

`Next Item Name (Other Outcome)` will contain the name of the next item (`Gaming Decision`) if the decision outcome evaluates to false.


![UserGuide](/docs/images/userguide/decision1.png?raw=true)

Once we have created the decision item, the signals to be used by the decision item can be added by clicking the `New` button under the `Assessment Definition Decision Signals` section. For this decision item we want to evaluate to true if both the `Gaming` AND `Streaming` signals have been fired.

![UserGuide](/docs/images/userguide/decision1-signals.png?raw=true)

Our possible next items at this point can be `Gaming Decision` or `1000 Mbps Recommendation`. Let's create the `1000 Mbps Recommendation` alert item next and try out our assessment so far.

## On-Entry Signal Events

We have a few items in our decision tree for which it would be useful to be able to fire a signal just by visiting that item. To do this, we can create an On-Entry Signal event. Let's create the `1000 Mbps Recommendation` alert item and configure this signal event.

![UserGuide](/docs/images/userguide/alert1-event.png?raw=true)


## Transfer Item

We will not use this type of item for this scenario, but you can use the `Transfer` item type if you need to transfer to a specific Agent, Queue, Bot or event another Assessment Definition then as part of your assessment.

To create a transfer item, create a new Assessment Definition Item with the `Transfer` record type and configure the transfer type to be one of the following values:

- Agent : Escalate this session to an agent, default routing in the button will be used
- Bot : Transfer the session to the Bot name configured in the `Transfer Target Name` field. NOTE: Name in this field should be the Bot Developer Name.
- Queue : Transfer the session to the Queue name configured in the `Transfer Target Name` field. NOTE: Name in this field should be the Queue Developer Name.
- Assessment : Start a new assessment session using the Assessment Definition configured in the `Transfer Target Name` field. NOTE: Name in this field should be the Assessment Definition Id of the desired assessment.

![UserGuide](/docs/images/userguide/transfer-item.png?raw=true)


# Scenario Testing

At this point we have configure and end to end branch of our assessment definition, let's try it out by going to the Preview tab and responding the following way:

1- Would you like to take the Assessment? -> Yes
2- How many devices connect to your network at a time? -> 12+
3- Do you stream shows and movies? -> Yes
4- Do you do online gaming? -> Yes

After responding this way, we should get a 1000 Mbps recommendation.

![UserGuide](/docs/images/userguide/e2etest.png?raw=true)

Go to the `Sessions` tab under our Assessment Defintion and you should now see a new session with a `Completed` status.

![UserGuide](/docs/images/userguide/sessionstab.png?raw=true)

Click on the Session Id to see the list of signals collected fro this session :

![UserGuide](/docs/images/userguide/session-details.png?raw=true)

You can continue to use the decision tree provided in this guide to complete the assessment and confirm other signals are captured as expected.

# Reports & Dashboards

Finally, we can go to the `Dashboard` tab to see charts related to the sessions and signals captured for this Assessment Definition.

![UserGuide](/docs/images/userguide/assessment-dashboard.png?raw=true)

# Deployment

Once you have tested your assessment and confirmed it works as expected then you're ready to deploy it to real customers! 

To deploy your assessment first you need to make sure the channel deployment has been configured in your org. (e.g Web, SMS, Facebook, Whatsapp, etc.). If you do not have access to setup this channel you must contact an admin in your org that can do this setup for you.

Once the channel has been configured you just need to know the Developer Name of channel and configure it as part of your Assessment Definition Deployments. The following steps demonstrate how to setup a Web channel deployment and how to configure your Assessment Definition to use this Web channel deployment.


## Setup your Channel Deployment 

#### Create your Channel Deployment

For a web channel, you must configure a Chat Button and an Embedded Service. We've done this already for previewing our Bot as part of the [Chat](Chat.md) configuration, you could use this existing channel deployment but it's recommended to create a specific channel deployment for each Assessment Definition as you can only have on Assessment Definition deployed to a specific channel deployment.

#### Associate the Assessment Bot to the Channel Deployment

Once you have configured your Channel Deployment, make sure you enable the `Assessment Bot` to be accessible in that deployment by going to the `Bot Buidler > Overview` and then adding the Channel Deployment in the Channels section.

![Deploy](/docs/images/deployment/deploy0.png?raw=true)

#### (Web Channel) Expose your channel in your Community

Go to your Community builder 

![Deploy](/docs/images/deployment/deploy3.png?raw=true)

Add your Deployment Channel to the Community. (NOTE: For Web Channel, you can use either `Channel Menu` or `Embedded Service Chat` just make sure you select the right deployment as part of the component properties)

![Deploy](/docs/images/deployment/deploy4.png?raw=true)

If you get a CSP Error then you must add the Live Agent endpoint to the list of trusted sites. 

![Deploy](/docs/images/deployment/deploy5.png?raw=true)

Copy the Live Agent Deployment URL portion 

![Deploy](/docs/images/deployment/deploy6.png?raw=true)

Add it to the Trusted Sites for Scripts section

![Deploy](/docs/images/deployment/deploy7.png?raw=true)

Publish the changes done to your Community

![Deploy](/docs/images/deployment/deploy8.png?raw=true)

## Add your Channel Deployment to your Assessment Definition

Go to your Assessment Definition Details and click the `New` button under the Assessment Definition Deployments section

![Deploy](/docs/images/deployment/deploy1.png?raw=true)

Create a new deployment with the following parameters and click the `Save` button

- Set the corresponding `Type` for your deployment :
    - Select `Web Chat` if your deployment channel is a Live Agent deployment (Chat Button)
    - Select `Messaging` if your deployment channel is any channel supported by Messaging (e.g. SMS, Facebook, Whatsapp, etc..)
- `Developer Name` should match the API Name (Developer Name) of your Deployment Channel

![Deploy](/docs/images/deployment/deploy2.png?raw=true)

## Validate deployment

Go to your community and validate the deployment renders correctly and that when you start a new session your Assessment Definition starts

![Deploy](/docs/images/deployment/deploy9.png?raw=true)


## Import/Export Assessment Definitions

It's possible to export and import assessment definitions from one org into another. To do this, go to the Assessment Import/Export tab in the Assessment Management application.

To export an Assessment Definition, go to the "Export" tab, select a definition from the dropdown and click the "Export" button. An importable JSON text will show up in the text are above, which you can copy manually or by clicking the "Copy" button.

```NOTE: You can't re-import an Assessment Definition in the same org unless you change the Assessment Definition Id since this has to be unique in the org.```

![Export](/docs/images/import-export/export.png?raw=true)

To import an Assessment Definition, go to the "Import" tab, paste the JSON generated from an exported definition and click the "Import" button. You should see a success message and the Assessment Definition will now be available in your org.

![Import](/docs/images/import-export/import.png?raw=true)
