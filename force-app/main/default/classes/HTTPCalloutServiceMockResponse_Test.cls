/**
 * @description       : Mock response for HTTPCalloutService
 * @author            : Nick Guia
 * @last modified on  : 24-03-2023
 * @last modified by  : Nick Guia
**/
@isTest
global class HTTPCalloutServiceMockResponse_Test implements HttpCalloutMock {

    public static final String CONTENT_TYPE = 'application/json';
    public static final Integer STATUS_CODE = 200;
    public static final String BODY = '{"fakeResponse" : "passed"}'; //default response

    public static String responseBody {
        get {
            if(String.isBlank(responseBody)) {
                responseBody = BODY;
            }
            return responseBody;
        }
        set;
    } 

    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', CONTENT_TYPE);
        res.setBody(responseBody);
        res.setStatusCode(STATUS_CODE);
        return res;
    }

    public HTTPCalloutServiceMockResponse_Test setResponseBody(String body) {
        responseBody = body;
        return this;
    }
}