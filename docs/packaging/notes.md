### Steps to create and publish new package versions

#### Create Scratch org and do your development

`sfdx force:org:create -a assessmentdev-so --definitionfile config/project-scratch-def.json`

#### Once done, create the Core Package

`sfdx force:package:create -n "Conversational Assessments" -r sfdx-source/main -t Unlocked`

#### Create a Core Package Version

`sfdx force:package:version:create -p "Conversational Assessments" --installationkeybypass -w 25`


#### Test Package Version installation

Create a subcriber org and then install the package using one of the following : 

`sfdx force:package:install --package "Conversational Assessments@1.0.9-1" --targetusername assessmentdev-subscriber --wait 15 --publishwait 15`

OR use the installation link `https://login.salesforce.com/packaging/installPackage.apexp?p0=PACKAGE_VERSION_ID`

#### Release Package Version

`sfdx force:package:version:promote -p "Conversational Assessments@1.0.9-1"`
