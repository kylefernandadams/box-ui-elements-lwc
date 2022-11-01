import { LightningElement, api } from 'lwc';
import downscopeToken from '@salesforce/apex/BoxElementsController.downscopeToken';

export default class ContentExplorer extends LightningElement {
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
            scopes: 'base_explorer item_preview item_download item_rename item_delete item_share item_upload root_readwrite annotation_view_all annotation_edit',
        })
        .then(responseMap => {
            this.folderId = responseMap.folderId;
            this.downscopedToken = responseMap.downscopedToken;      

            // Set the buieURL used in the iframe src param
            this.buieURL = `/apex/ContentExplorer?recId=${this.recordId}&folderId=${this.folderId}&downscopedToken=${this.downscopedToken}&height=${this.height}`;
        })
        .catch(error => {
            this.error = error;
            console.log('Found error: ', error);
        });
    }
}