import { LightningElement, api } from 'lwc';
import downscopeToken from '@salesforce/apex/BoxElementsController.downscopeToken';

export default class ContentExplorer extends LightningElement {
    @api elementTitle;
    @api recordId
    @api height;
    @api folderId;
    @api scopes;
    @api buieURL;
    @api downscopedToken;

    error;

    connectedCallback() {    
        // Call apex method to get downscoped token
        downscopeToken({
            resourceType: 'folders',
            recordId: this.recordId,
            boxItemId: this.folderId,
            scopes: this.scopes,
        })
        .then(responseMap => {
            this.folderId = responseMap.folderId;
            this.downscopedToken = responseMap.accessToken;      
            const ltnOrigin = responseMap.ltnOrigin;
            console.log('Found ltn origin: ', ltnOrigin);

            // Set the buieURL used in the iframe src param
            this.buieURL = `${ltnOrigin}/apex/ContentExplorer?recId=${this.recordId}&folderId=${this.folderId}&downscopedToken=${this.downscopedToken}&height=${this.height}`;
        })
        .catch(error => {
            this.error = error;
            console.log('Found error: ', error);
        });
    }
}