public with sharing class BoxElementsController {
    public static final String BOX_CLIENT_ID = 'UPDATE_ME';
    public static final String BOX_CLIENT_SECRET = 'UPDATE_ME';

    public static final String HEADER_CONTENT_TYPE = 'Content-Type';
    public static final String HEADER_APPLICATION_ENCODED = 'application/x-www-form-urlencoded';
    public static final String HEADER_APPLICATION_JSON = 'application/json';
    public static final String TOKEN_URL_STRING = 'https://api.box.com/oauth2/token';
    public static final String GET_CURRENT_USER_URL = 'https://api.box.com/2.0/users/me';

    public string lexOrigin {get{ return URL.getOrgDomainUrl().toExternalForm().split('\\.')[0] + '.lightning.force.com';} set;}

    @AuraEnabled(cacheable = true)
    public static string getVFOrigin() {
        string vfOrigin = '';
        string baseURL = URL.getOrgDomainUrl().toExternalForm(); // Expected Format = https://domain.my.salesforce.com

        // Expected Format for DE, Sandbox & Production ORgs = https://domain--c.visualforce.com
        vfOrigin = baseURL.split('.my.')[0] + '--c.' + 'visualforce.com';

        /* ********* Below odd Discrepancy was found while implementing this in a Trailhead Playground ***********
        Organization oOrg = [SELECT InstanceName, IsSandbox, OrganizationType FROM Organization LIMIT 1];
        if(oOrg.OrganizationType == 'Developer Edition'){
        // Expected Format for Trailhead Playground DE Org = https://domain--c.ap4.visual.force.com
        vfOrigin = baseURL.split('.my.')[0]+'--c.'+oOrg.InstanceName.toLowercase()+'.visual.force.com';
        } else {
        // Expected Format for personal DE, Sandbox & Production Orgs = https://domain--c.visualforce.com
        vfOrigin = baseURL.split('.my.')[0]+'--c.'+'visualforce.com';
        }  */

        return vfOrigin;
    }


    @AuraEnabled()
    public static Map<String, String> downscopeToken(String resourceType, String recordId, String scopes) {
        box.Toolkit boxToolkit = new box.Toolkit();

        // Get userId and folderId from FRUP record
        box__FRUP__c frup = [SELECT box__Folder_ID__c, box__Record_ID__c, box__Box_user__c FROM box__FRUP__c WHERE box__Record_ID__c = :recordId AND box__Box_user__c != NULL LIMIT 1];
        String userId = frup.box__Box_user__c;
        String folderId = frup.box__Folder_ID__c;

        System.debug('Found user id: ' + userId);

        // Create Client Credentials Grant map
        Map<String, String> clientCredentialsGrantMap = new Map<String, String>();
        clientCredentialsGrantMap.put('client_id', BOX_CLIENT_ID);
        clientCredentialsGrantMap.put('client_secret', BOX_CLIENT_SECRET);
        clientCredentialsGrantMap.put('grant_type', 'client_credentials');
        clientCredentialsGrantMap.put('box_subject_type', 'user');
        clientCredentialsGrantMap.put('box_subject_id', userId);

        // Get parent access token from Client Credentials Grant Auth
        String encodedUrl = urlEncode(clientCredentialsGrantMap);          
        String parentAccessToken = getAccessToken(encodedUrl);

        // Create map for downscoped token request
        String resource = 'https://api.box.com/2.0/' + resourceType;
        Map<String, String> downscopeTokenMap = new Map<String, String>();
        if(resourceType.endsWithIgnoreCase('folders')) {
            System.debug('Found folder with id: ' + folderId);
            resource += '/' + folderId;
            downscopeTokenMap.put('resource', resource);
        } 

        downscopeTokenMap.put('subject_token', parentAccessToken);
        downscopeTokenMap.put('subject_token_type', 'urn:ietf:params:oauth:token-type:access_token');
        downscopeTokenMap.put('scope', scopes);
        downscopeTokenMap.put('grant_type', 'urn:ietf:params:oauth:grant-type:token-exchange');

        // Get downsceoped token
        String downscopedEncodedUrl = urlEncode(downscopeTokenMap);
        String downscopedToken = getAccessToken(downscopedEncodedUrl);

        // Set folderId and downscoped token to pass back to LWC javascript controller
        Map<String, String> buieMap = new Map<String, String>();
        buieMap.put('folderId', folderId);
        buieMap.put('downscopedToken', downscopedToken);

        return buieMap;
    }



    private static String getAccessToken(String encodedUrl) {
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setMethod('POST');
        httpRequest.setEndpoint(TOKEN_URL_STRING);
        httpRequest.setHeader(HEADER_CONTENT_TYPE, HEADER_APPLICATION_ENCODED);
        httpRequest.setBody(encodedUrl);

        Http http = new Http();
        HttpResponse response = http.send(httpRequest);
        System.debug('Found response: ' + response);
        String body = response.getBody();
        AuthenticationResponse authResponse = AuthenticationResponse.parse(body);
        
        return authResponse.access_token;
    }

    private static String urlEncode(Map<String, String> urlParameterMap) {
      String result = '';
      for(String key : urlParameterMap.keySet()) {
          result += EncodingUtil.urlEncode(key, 'UTF-8') + '=' + EncodingUtil.urlEncode(urlParameterMap.get(key), 'UTF-8') + '&';
      }
      return result.removeEnd('&');    
  }
}
