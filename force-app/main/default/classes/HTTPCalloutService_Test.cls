/**
 * @description       : Test class for HTTPCalloutService
 * @author            : Nick Guia
 * @last modified on  : 24-03-2023
 * @last modified by  : Nick Guia
**/
@isTest(isParallel=true)
private class HTTPCalloutService_Test {

    private class TestHTTPCalloutService extends HTTPCalloutService {

        private void setEndpoint() {
            req.setEndpoint('https://example.com/test');
        }

        public HttpResponse doPost() {
            return setMethod('POST').setBody('fakeRequest : fake').sendRequest();
        }
    }

    /** 
     * Test coverage for HTTPCalloutService base class.
     * The response is mocked so there's no special business
     * logic being tested here
     */
    @isTest
    static void shouldSendRequest() {

        // GIVEN
        Test.setMock(HttpCalloutMock.class, new HTTPCalloutServiceMockResponse_Test());

        HttpResponse result;

        Test.startTest();

        // WHEN
        result = new TestHTTPCalloutService().doPost();

        Test.stopTest();

        // THEN
        Assert.areEqual(HTTPCalloutServiceMockResponse_Test.CONTENT_TYPE, result.getHeader('Content-Type'));
        Assert.areEqual(HTTPCalloutServiceMockResponse_Test.BODY, result.getBody());
        Assert.areEqual(HTTPCalloutServiceMockResponse_Test.STATUS_CODE, result.getStatusCode());
    }
}