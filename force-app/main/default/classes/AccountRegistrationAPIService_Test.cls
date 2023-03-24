/**
 * @description       : Test class for AccountRegistrationAPIService
 * @author            : Nick Guia
 * @group             : Test Classes
 * @last modified on  : 24-03-2023
 * @last modified by  : Nick Guia
**/
@isTest(isParallel=true)
private class AccountRegistrationAPIService_Test {

    /** 
     * Test coverage for AccountRegistrationAPIService
     * The response is mocked so there's no special business
     * logic being tested here
     */
    @isTest
    static void shouldSendRequest() {

        // GIVEN

        AccountRegistrationAPIService.PostResponse expectedResponse = new AccountRegistrationAPIService.PostResponse();
        expectedResponse.statusCode = 200;
        expectedResponse.success = true;
        expectedResponse.secretKey = '1234';

        Test.setMock(HttpCalloutMock.class, new HTTPCalloutServiceMockResponse_Test().setResponseBody(JSON.serialize(expectedResponse)));

        AccountRegistrationAPIService.PostRequest request = new AccountRegistrationAPIService.PostRequest();
        request.business_name = 'fake business name';

        AccountRegistrationAPIService.PostResponse actualResponse;

        Test.startTest();

        // WHEN
        actualResponse = AccountRegistrationAPIService.newInstance().doPost(request);

        Test.stopTest();

        // THEN
        Assert.areEqual(expectedResponse.statusCode, actualResponse.statusCode);
        Assert.areEqual(expectedResponse.success, actualResponse.success);
        Assert.areEqual(expectedResponse.secretKey, actualResponse.secretKey);
    }
}