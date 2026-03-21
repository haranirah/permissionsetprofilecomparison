public class ApexRestCalloutDemo {
 	public static void getUsersFromExternalSystem()
    {
       HTTP httpobj = new HTTP();
       HTTPRequest req = new HTTPRequest();
        req.setEndpoint('https://reqres.in/api/users');
        req.setHeader('Content-Type','application/json');
        req.setMethod('GET');
        //req.setbody('');
        
       HTTPResponse res = new HTTPResponse();
       res = httpobj.send(req);
       System.debug('This is the response body'+res.getBody());
    }
    public static void createUserstoExternalSystem()
    {
        HTTP httpObj = new HTTP();
        HTTPRequest req = new HTTPRequest();
        req.setEndpoint('https://jsonplaceholder.typicode.com/users');
        req.setHeader('Content-Type','application/json');
        req.setMethod('POST');
        req.setBody('{ "name": "hariharan", "job": "leader"}');
        HTTPResponse res = new HTTPResponse();
        res = httpObj.send(req);
        System.debug('this is the response body'+res.getBody());
    }
}