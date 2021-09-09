@isTest
public class TestHttpCalls {
    @isTest
    static void getAccessTokenTest(){
        Test.setMock(HttpCalloutMock.class, new Mock());
        Test.startTest();
        String response = HttpCalls.getAccessToken();
        Test.stopTest();
        system.assertEquals('tokenspoken', response);
    }
    @isTest
    static void getRequestDigestTest(){
        Test.setMock(HttpCalloutMock.class, new Mock());
        Test.startTest();
        String response = HttpCalls.getRequestDigest('token');
        Test.stopTest();
        system.assertEquals('TEST', response);
    }
    @isTest
    static void findFolderTest(){
        Test.setMock(HttpCalloutMock.class, new Mock());
        Test.startTest();
        Integer response = HttpCalls.findFolder('token', 'folderName');
        Test.stopTest();
        system.assertEquals(200, response);
    }
    @isTest
    static void createFolderTest(){
        Test.setMock(HttpCalloutMock.class, new Mock());
        Test.startTest();
        Integer response = HttpCalls.createFolder('token', 'formDigestValue', 'relativeFolderPath');
        Test.stopTest();
        system.assertEquals(200, response);
    }
    @isTest
    static void createFileTest(){
        String bodyStr = '11111111111111111111111';
        for(integer i = 0; i < 1000; i++){
            bodyStr = bodyStr + '1111111111111111111111111111111111111111111111111111111111111111';
        }        
        Blob fileBody = blob.valueOf(bodyStr);
        Test.setMock(HttpCalloutMock.class, new Mock());
        Test.startTest();
        HttpCalls.createFile('token', 'relativeFolderPath', 'fileName', fileBody);
        Integer callouts = Limits.getCallouts();
        Test.stopTest();
        system.assertEquals(1, callouts, 'A callout should be made');
    }   

    @isTest
    static void findFileTest(){
        Test.setMock(HttpCalloutMock.class, new Mock());
        Test.startTest();
        HttpCalls.findFile('token', 'fileName', 'relativeFolderPath');
        Integer callouts = Limits.getCallouts();
        Test.stopTest();
        system.assertEquals(1, callouts, 'A callout should be made');
    } 
    
    public class Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            if (req.getEndpoint().contains('_api/web/folders')) {
                HTTPResponse res = new HTTPResponse();
                res.setStatus('OK');
                res.setStatusCode(200);
                res.setBody('SUCCESS');
                return res;
            } else if (req.getEndpoint().contains('GetFolderByServerRelativeUrl')) {
                HTTPResponse res = new HTTPResponse();
                res.setStatus('OK');
                res.setStatusCode(200);
                res.setBody('SUCCESS');
                return res;
            } else if(req.getEndpoint().contains('tokens/OAuth/2')){
                HttpResponse response = new HttpResponse();
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"access_token":"tokenspoken"}');
                response.setStatusCode(200);
                response.setStatus('OK');
                return response;                 
            } else if(req.getEndpoint().contains('contextinfo')){
                HttpResponse response = new HttpResponse();
                response.setHeader('Content-Type', 'application/json');
                String result = TestHttpCalls.getXml();
                system.debug(result);
                response.setBody(result);
                response.setStatusCode(200);
                response.setStatus('OK');
                return response;                 
            } else {
                System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
                return null;
            }
        }
    }
    
    public class EditSharepointLinksMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            if (req.getEndpoint().contains('_api/web/folders')) {
                HTTPResponse res = new HTTPResponse();
                res.setStatus('OK');
                res.setStatusCode(200);
                res.setBody('SUCCESS');
                return res;
            } else if (req.getEndpoint().contains('GetFolderByServerRelativeUrl')) {
                HTTPResponse res = new HTTPResponse();
                String jsonInput = '{"d":{"results":[{"Name": "00P5700002bmehTEAQ_Narzan+signed.pdf"}]}}';
                res.setBody(jsonInput);
                res.setStatusCode(200);
                res.setStatus('OK');
                return res;
            } else if(req.getEndpoint().contains('tokens/OAuth/2')){
                HttpResponse response = new HttpResponse();
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"access_token":"tokenspoken"}');
                response.setStatusCode(200);
                response.setStatus('OK');
                return response;                 
            } else if(req.getEndpoint().contains('contextinfo')){
                HttpResponse response = new HttpResponse();
                response.setHeader('Content-Type', 'application/json');
                String result = TestHttpCalls.getXml();
                system.debug(result);
                response.setBody(result);
                response.setStatusCode(200);
                response.setStatus('OK');
                return response;                 
            } else {
                System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
                return null;
            }
        }
    }    
    
    public class FailureMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            if (req.getEndpoint().contains('_api/web/folders')) {
                HTTPResponse res = new HTTPResponse();
                //res.setBody('{}');
                res.setStatusCode(200);
                return res;
            } else if (req.getEndpoint().contains('GetFolderByServerRelativeUrl')) {
                CalloutException e = (CalloutException)CalloutException.class.newInstance();
                e.setMessage('Exception');
                throw e;                
            } else if(req.getEndpoint().contains('tokens/OAuth/2')){
                HttpResponse response = new HttpResponse();
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"access_token":"tokenspoken"}');
                response.setStatusCode(200);
                return response;                 
            }else if(req.getEndpoint().contains('contextinfo')){
                HttpResponse response = new HttpResponse();
                response.setHeader('Content-Type', 'application/json');
                String result = TestHttpCalls.getXml();
                response.setBody(result);
                response.setStatusCode(200);
                return response;                 
            } else {
                System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
                return null;
            }
        }
    }
    
    public static String getXml() {
        XmlStreamWriter w = new XmlStreamWriter();
        w.writeStartDocument(null, '1.0');
        w.writeProcessingInstruction('target', 'data');
        w.writeStartElement('m', 'FormDigestValue', 'http://www.book.com');
        w.writeNamespace('m', 'http://www.book.com');
        //w.writeComment('Book starts here');
        w.writeCharacters('TEST');
        w.setDefaultNamespace('http://www.defns.com');
        w.writeCData('<Cdata> I like CData </Cdata>');
        w.writeStartElement(null, 'book', null);
        w.writedefaultNamespace('http://www.defns.com');
        w.writeAttribute(null, null, 'author', 'Manoj');
        w.writeCharacters('This is my book');
        w.writeEndElement(); //end book
        w.writeEmptyElement(null, 'ISBN', null);
        w.writeEndElement(); //end library
        w.writeEndDocument();
        String xmlOutput = w.getXmlString();
        w.close();
        return xmlOutput;
    }       
    
}