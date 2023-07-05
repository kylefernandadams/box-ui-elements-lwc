import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import downscopeToken from '@salesforce/apex/BoxElementsController.downscopeToken';
import getVFOrigin from '@salesforce/apex/BoxElementsController.getVFOrigin';
import copyFilesToFolder from '@salesforce/apex/BoxContentPickerController.copyFilesToFolder';



export default class ContentPicker extends LightningElement {    
    @api elementTitle;
    @api objectApiName;
    @api recordId;
    @api height;
    @api scopes;
    @api folderId;
    @api buieURL;
    @api downscopedToken;
    @api chooseButtonLabel;


    error;

    @wire(getVFOrigin)
    vfOrigin;

    connectedCallback() {    
        window.addEventListener('message' , this.handleVFResponse.bind(this));

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

            // Set the buieURL used in the iframe src param
            this.buieURL = `${ltnOrigin}/apex/ContentPicker?recId=${this.recordId}&folderId=${this.folderId}&downscopedToken=${this.downscopedToken}&height=${this.height}&chooseButtonLabel=${this.chooseButtonLabel}`;
        })
        .catch(error => {
            this.error = error;
            console.log('LWC - Found error: ', error);
        });
    }

    handleVFResponse(message) {
        const boxItems = message.data;

        boxItems.forEach(boxItem => {
            copyFilesToFolder({
                recordId: this.recordId,
                sourceFileId: boxItem.id, 
                targetFolderId: null})
            .then(responseMap => {
                console.log('LWC - Found response map: ', responseMap);

                const toastEvent = new ShowToastEvent({
                    title: `Copied Box File` ,
                    message: `Successfully copied file \n${boxItem.name}`,
                    variant: 'success',
                });
                this.dispatchEvent(toastEvent);
            })
            .catch(error => {
                this.error = error;
                console.log('LWC - Found error: ', error);
                const toastEvent = new ShowToastEvent({
                    title: `Failed to Copy Box File` ,
                    message: `Failed to copy file \n${boxItem.name}`,
                    variant: 'error',
                });
                this.dispatchEvent(toastEvent);
            });
        });
    }
}