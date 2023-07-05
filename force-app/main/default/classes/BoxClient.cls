public class BoxClient {
    public static final String METHOD_POST = 'POST';
    public static final String CONTENT_TYPE_HEADER = 'Content-Type';
    public static final String APPLICATION_ENCODED_HEADER = 'application/x-www-form-urlencoded';
    public static final String TOKEN_URL_STRING = 'https://api.box.com/oauth2/token';

    public String clientId { get; set; }
    public String clientSecret { get; set; }
    public String subjectType { get; set; }
    public String subjectId { get; set; }

    public String accessToken { get; set; }
    public String refreshToken { get; set; }
    public Long lastRefresh { get; set; }
    public Long expires { get; set; }
    public String baseUrl { get; set; }
    public String baseUploadUrl { get; set; }
    public String asUserId { get; set; }
    
    public void authenticate(String boxClientCredentialsName) {
        BoxClientCredentialsGrant__mdt boxClientCredentialsGrant; 
        if(String.isNotBlank(boxClientCredentialsName)){
            boxClientCredentialsGrant = [
            SELECT Id, Label, BoxClientId__c, BoxClientSecret__c, BoxSubjectType__c, BoxSubjectId__c 
                FROM BoxClientCredentialsGrant__mdt 
                WHERE Label = :boxClientCredentialsName
                LIMIT 1
            ];
        }
        else {
            boxClientCredentialsGrant = [
            SELECT Id, Label, BoxClientId__c, BoxClientSecret__c, BoxSubjectType__c, BoxSubjectId__c 
                FROM BoxClientCredentialsGrant__mdt 
                LIMIT 1
            ];
        }

        if(boxClientCredentialsGrant != null) {
            
            // Create Client Credentials Grant
            this.setClientId(boxClientCredentialsGrant.BoxClientId__c);
            this.setClientSecret(boxClientCredentialsGrant.BoxClientSecret__c);
            this.setSubjectType(boxClientCredentialsGrant.BoxSubjectType__c);
            this.setSubjectId(boxClientCredentialsGrant.BoxSubjectId__c);

            // Get parent access token from Client Credentials Grant Auth
            Map<String, String> headers = new Map<String, String>();
            headers.put(CONTENT_TYPE_HEADER, APPLICATION_ENCODED_HEADER);

            String urlParameters = String.format(
                'grant_type=client_credentials&client_id={0}&client_secret={1}&box_subject_type={2}&box_subject_id={3}',
                new List<String>{
                    this.getClientId(),
                    this.getClientSecret(),
                    this.getSubjectType(),
                    this.getSubjectId()
                });
            System.debug('URL Params: ' + urlParameters);

            HttpResponse response = this.sendRequest(METHOD_POST, TOKEN_URL_STRING, headers, urlParameters);
            System.debug('Found response: ' + response.getBody());
            System.debug('Found status: ' + response.getStatus());

            if (response.getStatus() == 'OK') {
                String body = response.getBody();
                AuthenticationResponse authResponse = AuthenticationResponse.parse(body);
                this.setAccessToken(authResponse.access_token);
                this.setRefreshToken(authResponse.refresh_token);
                this.setLastRefresh(DateTime.now().getTime());
                this.setExpires(authResponse.expires_in * 1000);

            } else {
                throw new BoxClientException(
                    'BoxClient unable to generate new access token: ' +
                    response.toString()
                );
            }
        }
        else {
            System.debug('Box Client Credentials Grant metadata not found!');
        }
    }

    public String getAccessToken() {
        if (this.needsRefresh()) {
            this.refresh();
        }
        System.debug('Getting access token: ' + this.accessToken);
        return this.accessToken;
    }

    private Boolean needsRefresh() {
        Boolean needsRefresh;
        long now = DateTime.now().getTime();
        long tokenDuration = now - this.getLastRefresh();
        needsRefresh = (tokenDuration >= this.getExpires());
        return needsRefresh;
    }

    public void refresh() {
        Map<String, String> headers = new Map<String, String>();
        headers.put(CONTENT_TYPE_HEADER, APPLICATION_ENCODED_HEADER);

        String urlParameters = String.format(
                'grant_type=client_credentials&client_id={0}&client_secret={1}&box_subject_type={2}&box_subject_id={3}',
                new List<String>{
                    this.getClientId(),
                    this.getClientSecret(),
                    this.getSubjectType(),
                    this.getSubjectId()
                });
        
        HttpResponse response = this.sendRequest(METHOD_POST, TOKEN_URL_STRING, headers, urlParameters);
        if (response.getStatus() == 'OK') {
            String body = response.getBody();
            AuthenticationResponse authResponse = AuthenticationResponse.parse(body);
            this.setAccessToken(authResponse.access_token);
            this.setRefreshToken(authResponse.refresh_token);
            this.setLastRefresh(DateTime.now().getTime());
            this.setExpires(authResponse.expires_in * 1000);
        } else {
            throw new BoxClientException(
                'BoxClient unable to use refresh token to generate new access token: ' +
                response.toString()
            );
        }
    }

    public HttpResponse sendRequest(String httpMethod, String endpoint, Map<String, String> headers, String body) {
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setMethod(httpMethod);
        httpRequest.setEndpoint(endpoint);

        for(String key: headers.keySet()) {
            System.debug('Found key: ' + key + ' and value: ' + headers.get(key));
            httpRequest.setHeader(key, headers.get(key));
        }
        
        if(String.isNotBlank(body)) {
            httpRequest.setBody(body);
        }

        Http http = new Http();
        HttpResponse response = http.send(httpRequest);
        System.debug('Found response: ' + response.getBody());
        return response;

    }

    public String getClientId() {
        return this.clientId;
    }

    public void setClientId(String clientId) {
        this.clientId = clientId;
    }

    public String getClientSecret() {
        return this.clientSecret;
    }

    public void setClientSecret(String clientSecret) {
        this.clientSecret = clientSecret;
    }

    public String getSubjectType() {
        return this.subjectType;
    }

    public void setSubjectType(String subjectType) {
        this.subjectType = subjectType;
    }

    public String getSubjectId() {
        return this.subjectId;
    }

    public void setSubjectId(String subjectId) {
        this.subjectId = subjectId;
    }

    public void setAccessToken(String accessToken) {
        this.accessToken = accessToken;
    }

    public String getRefreshToken() {
        return this.refreshToken;
    }

    public void setRefreshToken(String refreshToken) {
        this.refreshToken = refreshToken;
    }

    public Long getLastRefresh() {
        return this.lastRefresh;
    }

    public void setLastRefresh(Long lastRefresh) {
        this.lastRefresh = lastRefresh;
    }

    public Long getExpires() {
        return this.expires;
    }

    public void setExpires(Long expires) {
        this.expires = expires;
    }

    public String getBaseUrl() {
        return this.baseUrl;
    }

    public void setBaseUrl(String baseUrl) {
        this.baseUrl = baseUrl;
    }

    public String getBaseUploadUrl() {
        return this.baseUploadUrl;
    }

    public void setBaseUploadUrl(String baseUploadUrl) {
        this.baseUploadUrl = baseUploadUrl;
    }

    public String getAsUserId() {
        return this.asUserId;
    }

    public void setAsUserId(String asUserId) {
        this.asUserId = asUserId;
    }

    public static String urlEncode(Map<String, String> urlParameterMap) {
        String result = '';
        for(String key : urlParameterMap.keySet()) {
            result += EncodingUtil.urlEncode(key, 'UTF-8') + '=' + EncodingUtil.urlEncode(urlParameterMap.get(key), 'UTF-8') + '&';
        }
        return result.removeEnd('&');    
      }

    public class BoxClientException extends Exception {
    }
}