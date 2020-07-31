#!/bin/bash
set -e

# default parameter values
default_scratch_org_days=15
default_scratch_org_wait=15

# extract arguments
while [[ "$#" -gt 0 ]]
do
	case $1 in
		-d|--days)
			DAYS="$2"
			;;
		-w|--wait)
			WAIT="$2"
			;;
	esac
	shift
done

scratch_org_days=${DAYS:-$default_scratch_org_days}
scratch_org_wait=${WAIT:-$default_scratch_org_wait}

echo "Creating a new scratch org ..."
sfdx force:org:create -f config/project-scratch-def.json -d $scratch_org_days -w $scratch_org_wait -a current-assess-so -s --json

echo "Pushing source code..."
sfdx force:source:push

echo "Assigning the admin perm set to the current user ..."
sfdx force:user:permset:assign -n Assessment_Admin

echo "Creating a bot user in the org ..."
sfdx force:user:create --setalias bot-user --definitionfile config/bot-user-def.json

echo "Assigning permission sets to bot user ..."
sfdx force:user:permset:assign -n Assessment_Bot -o bot-user

echo "Loading sample data ..."
sfdx force:data:tree:import --plan sfdx-out/covid19-Assessment_Definition__c-Assessment_Definition_Signal__c-Assessment_Definition_Item__c-Assessment_Definition_Item_Choice__c-Assessment_Definition_Item_Event__c-plan.json
sfdx force:data:tree:import --plan sfdx-out/speed_assess-Assessment_Definition__c-Assessment_Definition_Signal__c-Assessment_Definition_Item__c-Assessment_Definition_Decision_Signal__c-Assessment_Definition_Item_Choice__c-Assessment_Definition_Item_Event__c-plan.json

echo "⚡ Setting password for admin user ..."
sfdx force:user:password:generate -u current-assess-so

echo "⚡ Setting password for bot user ..."
sfdx force:user:password:generate -u current-assess-so -o bot-user