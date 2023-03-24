/**
 * @description       : Base class for HTTP Callout services
 * @author            : Nick Guia
 * @last modified on  : 24-03-2023
 * @last modified by  : Nick Guia
**/
public inherited sharing abstract class HTTPCalloutService {

    @TestVisible
    protected Http h;
    @TestVisible
    protected HttpRequest req;

    protected HTTPCalloutService() {
        this.h = new Http();
        this.req = new HttpRequest();
        setHeaders();
        setEndpoint();
    }

    abstract void setEndpoint();

    @TestVisible
    protected virtual void setHeaders() {
        this.req.setHeader('Content-Type', 'application/json');
    }

    @TestVisible
    protected HTTPCalloutService setMethod(String httpMethod) {
        this.req.setMethod(httpMethod);
        return this;
    }

    @TestVisible
    protected HTTPCalloutService setbody(String requestBody) {
        this.req.setBody(requestBody);
        return this;
    }

    @TestVisible
    protected HttpResponse sendRequest() {
        return this.h.send(this.req);
    }
}