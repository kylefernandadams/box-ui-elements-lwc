# Box UI Elements LWC
The Box UI Elements LWC project provides sample code to illustrate wrapping Box UI Elements in a VisualForce Page which is in-turn wrapped with an LWC component.

## Pre-Requisites

1. Clone this github repo.
2. Setup your Salesforce DX environment: https://trailhead.salesforce.com/en/content/learn/projects/quick-start-salesforce-dx/set-up-your-salesforce-dx-environment
3. Setup VS Code: https://trailhead.salesforce.com/content/learn/projects/quick-start-lightning-web-components/set-up-visual-studio-code
4. (Optional) Install and Configure the Box for Salesforce Managed Package: https://community.box.com/t5/How-to-Guides-for-Integrations/Installing-and-Configuring-Box-For-Salesforce/ta-p/180
    > Note: Dont forget to add the Box VisualForce components to each of the record type layouts.

5. Manual create a folder from a given sample record
6. Open the source from this repo in VS Code.
7. Create a [Custom Box App](https://developer.box.com/guides/authentication/client-credentials/) with Client Credentials Auth
8. In Salesforce Setup, go to Custom Metadata Types and create a new record for Box Client Credentials Grant.
   > Note: This will use the client id and client secret from the previous step.
9.  In VS Code, use the cmd+shift+p shortcut and select SFDX: Authorize Org
10. Confirm you've successfully authorized your org by listing orgs and their associated status:
```
sfdx force:org:list
```
1.  List the installed packaged for your org:
```
sfdx force:package:installed:list -u <username@domain.com>
```
1.   Deploy you project source to either you scratch org or developer org in the next section.

## Deploy to your Org
Push to Scratch Org:
```
sfdx force:source:push
```


Deploy to Developer/Production Org:
```
sfdx force:source:deploy -p force-app -u username@company.com
```


## Disclaimer
This project is a collection open source examples and should not be treated as an officially supported product. Use at your own risk. If you encounter any problems, please log an [issue](https://github.com/kylefernandadams/box-ui-elements-lwc/issues).

## License
 
The MIT License (MIT)

Copyright (c) 2022 Kyle Adams

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
