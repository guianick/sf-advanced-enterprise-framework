/**
 * @description       : Module that handles any URL callouts necessary on Account DML
 * @author            : Nick Guia
 * @last modified on  : 24-03-2023
 * @last modified by  : Nick Guia
**/
public inherited sharing class aef_AccountURLCalloutModule extends aef_ApplicationDomain.Module {
    
    public aef_AccountURLCalloutModule() {
        getTriggerEvents().enableAfterInsert();
    }

    public static aef_AccountURLCalloutModule newInstance() {
        return (aef_AccountURLCalloutModule) aef_Application.Utilities.newInstance(aef_AccountURLCalloutModule.class);
    }

    public override void onAfterInsert(List<SObject> records, aef_ApplicationUnitOfWork uow) {
        accountRegistrationAPICallout((List<Account>) records, uow);
    }

    @TestVisible
    private void accountRegistrationAPICallout(List<Account> records, aef_ApplicationUnitOfWork uow) {
        /**
         * Assumption here is that the endpoint does not cater for a List request. 
         * Therefore, I designed this to dispatch an asyncworker per account ID.
         * Otherwise, the thread might timeout on bulk request (e.g. 200 records) if it takes
         * too long for the endpoint to respond for each Account record.
         * 
         * Ideally, the other endpoint should be able to handle multiple business names per transaction
         * so we can bulkify.
         */
        if(!records.isEmpty()) {
            // async params
            for(Account iAcc : records) {
                Map<String, Object> params = new Map<String, Object>{
                    'accountId' => iAcc.Id,
                    'businessName' => iAcc.Name
                };
                uow.registerAsyncWork(new aef_ApplicationUnitOfWork.AsyncStagingWorker(AsyncStoreSecretKey.class, params));
            }
        }
    }

    public without sharing class AsyncStoreSecretKey extends aef_ApplicationUnitOfWork.AsyncWorker implements Database.AllowsCallouts {

        AsyncStoreSecretKeyParams params;

        public override SObjectType getSObjectTypeGroup() {
			return Account.SObjectType;
		}

        public override Type getClassType() {
			return AsyncStoreSecretKey.class;
		}

        // deserialise params to ensure integrity of payload
        public override void deserialiseParams(String serialisedParams) {
            this.params = (AsyncStoreSecretKeyParams) JSON.deserialize(serialisedParams, AsyncStoreSecretKeyParams.class);
        }

        public override void execute(aef_ApplicationUnitOfWork  uow) {
            // build request 
            AccountRegistrationAPIService.PostRequest postReq = new AccountRegistrationAPIService.PostRequest();
            postReq.business_name = this.params.businessName;

            // invoke callout and capture response
            AccountRegistrationAPIService.PostResponse postResp = new AccountRegistrationAPIService().doPost(postReq);
            if(postResp.success) {
                Account acc = new Account(Id = this.params.accountId, Secret_Key__c = postResp.secretKey);
                uow.registerDirty(acc);
            } else {
                // we can reate exception or integration logs record here aside from debugs
                System.debug(
                    LoggingLevel.ERROR, 
                    'Unable to request secret key for account. Id : ' + this.params.accountId + ' name : ' + this.params.businessName + ' \n'
                    + 'With error : ' + postResp.error
                );
            }
        }
    }

    // expected parameters
    public class AsyncStoreSecretKeyParams {
        public Id accountId;
        public String businessName;
    }
}