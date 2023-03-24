/**
 * @description       : Test class for aef_AccountURLCalloutModule
 * @author            : Nick Guia
 * @group             : Test Classes
 * @last modified on  : 24-03-2023
 * @last modified by  : Nick Guia
**/
@isTest(isParallel=true)
private class aef_AccountURLCalloutModule_Test {

    /**
     * @description
     *  Test that AsyncStoreSecretKey was dispatched on account after insert.
     *  There should be one instance of the worker per account to be inserted
     *  as per design.
     */
    @istest
    static void shouldDispatchAsyncStoreSecretKeyOnAfterInsert() {

        // GIVEN

        AccountRegistrationAPIService.PostResponse expectedResponse = new AccountRegistrationAPIService.PostResponse();
        expectedResponse.statusCode = 200;
        expectedResponse.success = true;
        expectedResponse.secretKey = '1234';

        Test.setMock(HttpCalloutMock.class, new HTTPCalloutServiceMockResponse_Test().setResponseBody(JSON.serialize(expectedResponse)));

        // new account
        List<Account> accounts = aef_ApplicationTestDataFactory.getAccounts(2, true);

        // mock
		aef_ApplicationUnitOfWork mockUOW = (aef_ApplicationUnitOfWork) aef_MockUtility.mockUtility(aef_ApplicationUnitOfWork.class);

        // start stubbing
        aef_MockUtility.Mocks.startStubbing();

        // catch account update
		aef_MockUtility.Mocks.when(mockUOW.registerDirty((Account) fflib_Match.anySObject()))
            .thenAnswer(new aef_MockUtility.AnswerGenericRegisterUnitOfWorkDML());

        // end stubbing
        aef_MockUtility.Mocks.stopStubbing();

        Test.startTest();

        // WHEN
        aef_AccountURLCalloutModule module = aef_AccountURLCalloutModule.newInstance();
        module.onAfterInsert(accounts, mockUOW);

        Test.stopTest();

        // verify that worker was dispatched
		fflib_ArgumentCaptor stagedWorkerCapture = fflib_ArgumentCaptor.forClass(aef_ApplicationUnitOfWork.AsyncStagingWorker.class);
		((aef_ApplicationUnitOfWork) aef_MockUtility.Mocks.verify(mockUOW, aef_MockUtility.Mocks.times(2)))
            .registerAsyncWork((aef_ApplicationUnitOfWork.AsyncStagingWorker) stagedWorkerCapture.capture());

		aef_ApplicationUnitOfWork.AsyncStagingWorker stagedWorker = (aef_ApplicationUnitOfWork.AsyncStagingWorker) stagedWorkerCapture.getValue();

		Assert.areEqual(
            aef_AccountURLCalloutModule.AsyncStoreSecretKey.class, 
            stagedWorker.classType, 
            'AsyncStoreSecretKey was not enqueued');
    }

    /**
     * @description
     *  Test that Account Secret Key gets populated upon dispatching AsyncStoreSecretKey
     */
    @istest
    static void shouldPopulateSecretKeyOnAccountInsert() {
        // GIVEN

        AccountRegistrationAPIService.PostResponse expectedResponse = new AccountRegistrationAPIService.PostResponse();
        expectedResponse.statusCode = 200;
        expectedResponse.success = true;
        expectedResponse.secretKey = '1234';

        Test.setMock(HttpCalloutMock.class, new HTTPCalloutServiceMockResponse_Test().setResponseBody(JSON.serialize(expectedResponse)));

        // new account
        List<Account> accounts = aef_ApplicationTestDataFactory.getAccounts(1, true);
        aef_AccountURLCalloutModule.AsyncStoreSecretKeyParams asyncParams = new aef_AccountURLCalloutModule.AsyncStoreSecretKeyParams();
        asyncParams.accountId = accounts[0].Id;
        asyncParams.businessName = accounts[0].Name;

        // expected outcome
        Account expectedAccount = accounts[0].clone(true);
        expectedAccount.Secret_Key__c = expectedResponse.secretKey;

        // mock
		aef_ApplicationUnitOfWork mockUOW = (aef_ApplicationUnitOfWork) aef_MockUtility.mockUtility(aef_ApplicationUnitOfWork.class);

        // start stubbing
        aef_MockUtility.Mocks.startStubbing();

        // catch account update
		aef_MockUtility.Mocks.when(mockUOW.registerDirty((Account) fflib_Match.anySObject()))
            .thenAnswer(new aef_MockUtility.AnswerGenericRegisterUnitOfWorkDML());

        // end stubbing
        aef_MockUtility.Mocks.stopStubbing();

        aef_AccountURLCalloutModule.AsyncStoreSecretKey asyncWorker;

        Test.startTest();

        // WHEN
        asyncWorker = new aef_AccountURLCalloutModule.AsyncStoreSecretKey();
        asyncWorker.deserialiseParams(JSON.serialize(asyncParams));
		asyncWorker.execute(mockUOW);

        Test.stopTest();

        Assert.areEqual(Account.SObjectType, asyncWorker.getSObjectTypeGroup(), 'Unexpected SObjectType');
        Assert.areEqual(aef_AccountURLCalloutModule.AsyncStoreSecretKey.class, asyncWorker.getClassType(), 'Unexpected class type');

		// verify the Case will be updated correctly and capture the arguments for review
		fflib_ArgumentCaptor accountCasesCapture = fflib_ArgumentCaptor.forClass(List<Account>.class);
		((aef_ApplicationUnitOfWork) aef_MockUtility.Mocks.verify(mockUOW, aef_MockUtility.Mocks.times(1)))
            .registerDirty((Account) accountCasesCapture.capture());

		// verify that only one account was captured for update
		List<Object> accountUpdateList = (List<Object>) accountCasesCapture.getAllValues();
        Assert.areEqual(1, accountUpdateList.size(), 'Unexpected number of accounts attempted to update');
		// verify that the accounts being updated are the same
        Assert.areEqual(accounts[0].Id, ((Account) accountUpdateList[0]).Id, 'Unexpected Account record being updated');
		//verify that the Account secret key was updated
		Assert.areEqual(expectedAccount.Secret_Key__c, ((Account) accountUpdateList[0]).Secret_Key__c, 'Unexpected Secret Key value');
    }
}