public with sharing class BoxElementsController {
    public static final String BOX_CLIENT_ID = 'UPDATE_ME';
    public static final String BOX_CLIENT_SECRET = 'UPDATE_ME';

    public static final String HEADER_CONTENT_TYPE = 'Content-Type';
    public static final String HEADER_APPLICATION_ENCODED = 'application/x-www-form-urlencoded';
    public static final String HEADER_APPLICATION_JSON = 'application/json';
    public static final String TOKEN_URL_STRING = 'https://api.box.com/oauth2/token';
    public static final String GET_CURRENT_USER_URL = 'https://api.box.com/2.0/users/me';

    @AuraEnabled()
    public static Map<String, String> downscopeToken(String resourceType, String recordId, String scopes) {
        box.Toolkit boxToolkit = new box.Toolkit();

        // Get the pageref and assoc params
        Pagereference pageRef = boxToolkit.getFolderUrl(recordId, true);
        Map<String, String> params = pageRef.getParameters();
        String parentToken = params.get('login_token');
        box__FRUP__c frup = [SELECT box__Folder_ID__c, box__Record_ID__c, box__Box_user__c FROM box__FRUP__c WHERE box__Record_ID__c = :recordId AND box__Box_user__c != NULL LIMIT 1];
        String userId = frup.box__Box_user__c;
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
        String folderId;
        Map<String, String> downscopeTokenMap = new Map<String, String>();
        if(resourceType.endsWithIgnoreCase('folders')) {
            folderId = frup.box__Folder_ID__c;
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
