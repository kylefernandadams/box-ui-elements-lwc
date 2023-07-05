import { LightningElement, api } from 'lwc';
import boxLogo from '@salesforce/resourceUrl/logos';
import downscopeToken from '@salesforce/apex/BoxElementsController.downscopeToken';

export default class MetadataQuery extends LightningElement {
    @api elementTitle;
    @api boxLogoPNG;
    @api recordId
    @api height;
    @api folderId;
    @api buieURL;
    @api downscopedToken;
    @api from;
    @api fields;
    @api query;
    @api queryParams;
    @api orderBy;
    @api fieldsToShow;


    error;

    connectedCallback() {    
        this.boxLogoPNG =  boxLogo + '/box.png';
        // Call apex method to get downscoped token
        downscopeToken({
            resourceType: 'metadata',
            recordId: this.recordId
        })
        .then(responseMap => {
            console.log('LWC - Found Apex response: ', responseMap);
            console.log('LWC - Found folderId: ', this.folderId);
            console.log('LWC - Found from: ', this.from);
            console.log('LWC - Found fields: ', this.fields);
            console.log('LWC - Found query: ', this.query);
            console.log('LWC - Found queryParams: ', this.queryParams);
            console.log('LWC - Found orderBy: ', this.orderBy);
            console.log('LWC - Found fieldsToShow: ', this.fieldsToShow);


            this.folderId = responseMap.folderId;
            this.downscopedToken = responseMap.accessToken;      
            const ltnOrigin = responseMap.ltnOrigin;
            console.log('Found ltn origin: ', ltnOrigin);

            // Set the buieURL used in the iframe src param
            this.buieURL = `${ltnOrigin}/apex/MetadataQuery?folderId=${this.folderId}&downscopedToken=${this.downscopedToken}&from=${this.from}&fields=${this.fields}&query=${this.query}&queryParams=${this.queryParams}&orderBy=${this.orderBy}&fieldsToShow=${this.fieldsToShow}`;
        })
        .catch(error => {
            this.error = error;
            console.log('Found error: ', error);
        });
    }
}