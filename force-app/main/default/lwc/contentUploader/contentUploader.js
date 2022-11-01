import { LightningElement, api } from 'lwc';
import downscopeToken from '@salesforce/apex/BoxElementsController.downscopeToken';

export default class ContentUploader extends LightningElement {
    @api recordId
    @api height;
    @api folderId;
    @api buieURL;
    @api downscopedToken;

    error;
    
    connectedCallback() {    
        // Call apex method to get downscoped token
        downscopeToken({
            resourceType: 'folders',
            recordId: this.recordId,
            scopes: 'base_upload',
        })
        .then(responseMap => {
            this.folderId = responseMap.folderId;
            this.downscopedToken = responseMap.downscopedToken;      

            // Set the buieURL used in the iframe src param
            this.buieURL = `/apex/ContentUploader?recId=${this.recordId}&folderId=${this.folderId}&downscopedToken=${this.downscopedToken}&heigh=${this.height}`;
        })
        .catch(error => {
            this.error = error;
            console.log('Found error: ', error);
        });
    }
}