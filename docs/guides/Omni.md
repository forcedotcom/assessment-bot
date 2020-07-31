### Enable Omni-Channel

- Go to `Setup > Omni-Channel Settings`
- Toggle the `Enable Omni-Channel` checkbox and click the `Save` button.

![Omni](/docs/images/omni/omni-pref.png?raw=true)


### Create a Routing Configuration

- Go to `Setup > Routing Configurations` and click the `New` button

![Omni](/docs/images/omni/routing-config-list.png?raw=true)

- Create a new Routing configuration with the following parameters and click the `Save` button :

    - Routing Configuration Name : `Assessment Routing Configuration` (suggested)
    - Developer Name : `Assessment_Routing_Configuration` (suggested)
    - Routing Priority : `1`
    - Routing Model : `Least Active`
    - Units of Capacity : `1`
    - You can leave other fields blank or use the existing defaults.

![Omni](/docs/images/omni/routing-config-new.png?raw=true)


### Create a Queue

- Go to `Setup > Queues` and click the `New` button

![Queue](/docs/images/omni/queue-list.png?raw=true)

- Create a new Queue with the following parameters and click the `Save` button :

    - Label : `Assessment Queue` (suggested)
    - Queue Name : `Assessment_Queue` (suggested)
    - Routing Configuration : `Assessment_Routing_Configuration` (or the name of your routing configuration)
    - Supported Objects : Add `Chat Transcript` and `Messaging Session` (if available) to the Selected object list
    - You can leave other fields blank or use the existing defaults.

![Queue](/docs/images/omni/queue-info.png?raw=true)


Next Step, [Create a Chat Deployment and Chat Button](Chat.md)