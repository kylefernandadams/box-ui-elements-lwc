public with sharing class BoxContentPickerController {
    public static final String HEADER_CONTENT_TYPE = 'Content-Type';
    public static final String HEADER_AUTHORIZATION = 'Authorization';
    public static final String HEADER_APPLICATION_JSON = 'application/json';
    public static final String USERS_URL_STRING = 'https://api.box.com/2.0/users?fields=id,type,name,login&filter_term=';
    public static final String COPY_FILES_URL_STRING = 'https://api.box.com/2.0/files/{0}/copy';


    @AuraEnabled(cacheable = true)
    public static Map<String, Object> copyFilesToFolder(String recordId, String sourceFileId, String targetFolderId) {
        Map<String, Object> copyResponseMap = new Map<String, Object>();

        BoxClient boxClient = new BoxClient();
        boxClient.authenticate(null);

        box__FRUP__c frup;
        if(String.isEmpty(targetFolderId)) {
            frup = [SELECT box__Folder_ID__c, box__Record_ID__c, box__Box_user__c FROM box__FRUP__c WHERE box__Record_ID__c = :recordId LIMIT 1];
            targetFolderId = frup.box__Folder_ID__c;
        }


        HttpRequest copyRequest = new HttpRequest();
        copyRequest.setMethod('POST');

        String copyFileEndpoint = String.format(COPY_FILES_URL_STRING, 
        new List<String> {sourceFileId});
        copyRequest.setEndpoint(copyFileEndpoint);
        copyRequest.setHeader(HEADER_CONTENT_TYPE, HEADER_APPLICATION_JSON);
        copyRequest.setHeader(HEADER_AUTHORIZATION, 'Bearer ' + boxClient.getAccessToken());

        FileCopyRequest copyBody = new FileCopyRequest();
        FileCopyRequest.Parent parentFolder = new FileCopyRequest.Parent();
        parentFolder.id = targetFolderId;
        copyBody.parent = parentFolder;
        copyRequest.setBody(JSON.serialize(copyBody));

        System.debug('Found copy endpoint: ' + copyFileEndpoint);
        System.debug('Found target folder id: ' + targetFolderId);
        System.debug('Found request body: ' + JSON.serialize(copyBody));
        
        Http copyHttp = new Http();
        HttpResponse copyResponse = copyHttp.send(copyRequest);
        System.debug('Found response: ' + copyResponse);
        String copyResponseBody = copyResponse.getBody();

        FileCopyResponse fileCopyResponse = FileCopyResponse.parse(copyResponseBody);
        System.debug('Found file copy response: ' + copyResponseBody);
        copyResponseMap.put('isSuccessful', true);

        return copyResponseMap;
    }
}