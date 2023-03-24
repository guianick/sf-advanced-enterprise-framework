/**
 * @description       : Initiates an HTTP Callout to Account Registration API
 * @author            : Nick Guia
 * @last modified on  : 24-03-2023
 * @last modified by  : Nick Guia
**/
public inherited sharing class AccountRegistrationAPIService extends HTTPCalloutService {

    private static final String ACCOUNT_REGISTRATION_API_ENDPOINT = 'https://enterpriseminded.com/api/';

    public static AccountRegistrationAPIService newInstance() {
        return (AccountRegistrationAPIService) aef_Application.Utilities.getInstance(AccountRegistrationAPIService.class);
    }

    private void setEndpoint() {
        req.setEndpoint(ACCOUNT_REGISTRATION_API_ENDPOINT);
    }

    /**
    * @description invoke a POST callout to Account Registration API.
    * @author Nick Guia | 24-03-2023 
    * @param PostRequest postReq : The request structure should comply with the class
    * @return PostResponse : an instance of the PostResponse to represent the API response
    **/
    public PostResponse doPost(PostRequest postReq) {
        // prepare request and send
        HttpResponse httpResp = setMethod('POST').setBody(JSON.serialize(postReq)).sendRequest();

        // get response
        PostResponse postResp = (PostResponse) JSON.deserialize(httpResp.getBody(), PostResponse.class);
        postResp.statusCode = httpResp.getStatusCode();
        return postResp;
    }

    // POST Request structure
    public class PostRequest {
        public String business_name;
    }

    // POST Response structure
    public class PostResponse {
        public Integer statusCode;
        public Boolean success;
        public String secretKey;
        public String error;
    }
}