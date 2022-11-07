import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import downscopeToken from '@salesforce/apex/BoxElementsController.downscopeToken';
import getVFOrigin from '@salesforce/apex/BoxElementsController.getVFOrigin';


export default class ContentUploader extends LightningElement {
    @api recordId
    @api height;
    @api folderId;
    @api buieURL;
    @api downscopedToken;

    error;

    @wire(getVFOrigin)
    vfOrigin;

    connectedCallback() {    
        window.addEventListener('message' , this.handleVFResponse.bind(this));

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

    handleVFResponse(message) {
        if (message.origin === this.vfOrigin.data) {
            const messageData = message.data;
            const toastEvent = new ShowToastEvent({
                title: messageData.title,
                message: messageData.errorMessage,
                variant: messageData.variant,
            });
            this.dispatchEvent(toastEvent);
        }
    }
}