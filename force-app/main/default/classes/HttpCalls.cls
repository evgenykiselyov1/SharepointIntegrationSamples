public class HttpCalls {
	
    public static String getAccessToken(){
        String tenantIDrealm = '63cbe529-197e-4e1a-8492-f500e7174ee0';
        String clientID = '97145705-6a29-489a-a577-5a6838efdaed'; 
        String clientSecret = 'ANSe8BFLPOo6oS5TrEzZB320Gz4qhMp+t06Ia+AGINk=';
        String resourceClient_id = '00000003-0000-0ff1-ce00-000000000000';
        system.debug('access token reception process is started');
        HttpRequest httpRequestToSend = new HttpRequest();
        httpRequestToSend.setEndpoint('https://accounts.accesscontrol.windows.net/' + tenantIDrealm + '/tokens/OAuth/2');
        httpRequestToSend.setMethod('POST');
        httpRequestToSend.setHeader('Authorization', 'Bearer ' + '');
        httpRequestToSend.setHeader('Content-Type','application/x-www-form-urlencoded');
        
        String body = 'grant_type=client_credentials'+
            '&client_id='+EncodingUtil.urlEncode(clientID + '@' + tenantIDrealm,'UTF-8')+
            '&client_secret='+EncodingUtil.urlEncode(clientSecret,'UTF-8')+
            '&resource='+EncodingUtil.urlEncode(resourceClient_id + '/globalsharepoint2019.sharepoint.com@' + tenantIDrealm,'UTF-8');
        
        httpRequestToSend.setBody(body);
        Http http = new Http();   
        HttpResponse httpResponse = http.send(httpRequestToSend);  
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
        system.debug('access token is received: ' + m.get('access_token'));
        return String.valueof(m.get('access_token'));
    }
    
    public static String getRequestDigest(String token){
        system.debug('Form Digest reception process is started');
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://globalsharepoint2019.sharepoint.com/sites/SharePointRND/_api/contextinfo');
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer ' + token);
        request.setHeader('Content-Type','application/json;odata=verbose');
        request.setHeader('Content-Length', '125');
        request.setBody('Body');
        
        Http http1 = new Http();   
        HttpResponse response = http1.send(request);  
        String FormDigestValue;
        XmlStreamReader reader = new XmlStreamReader(response.getBody());
        while(reader.hasNext()) {
            if(reader.getLocalName() == 'FormDigestValue'){
                reader.next();
                if(reader.getEventType() == XmlTag.CHARACTERS) {
                    //system.debug(reader.getText());
                    FormDigestValue = reader.getText();
                }
            }
            reader.next();
        }   
		system.debug('Form Digest is received: ' + FormDigestValue);        
        return FormDigestValue;
    }
    
    public static Integer createFolder(String token, String formDigestValue, String relativeFolderPath){
        HttpRequest requestFolders = new HttpRequest();
        requestFolders.setEndpoint('https://globalsharepoint2019.sharepoint.com/sites/SharePointRND/_api/web/folders');
        requestFolders.setMethod('POST');
        requestFolders.setHeader('Authorization', 'Bearer ' + token);
        requestFolders.setHeader('Accept', 'application/json;odata=verbose');
        requestFolders.setHeader('Content-Type','application/json;odata=verbose');
        requestFolders.setHeader('X-RequestDigest', formDigestValue);
        string nameOfFolder = relativeFolderPath.replace(' ', '%20');
        String folderPath = 'Shared Documents/' + relativeFolderPath;
        
        /*if(relativeFolderPath.contains('%')){
            folderPath = 'Shared Documents/' + relativeFolderPath.replace(' ', '+');
        }else{
            folderPath = 'Shared Documents/' + relativeFolderPath;
        }*/
        system.debug(folderPath);
        
        String reqBody = '{'+
            ' "__metadata": {'+
            ' "type": "SP.Folder" '+
            '},'+
            ' "ServerRelativeUrl": "https://globalsharepoint2019.sharepoint.com/sites/SharePointRND/' + folderPath + '" '+
            '}';
        requestFolders.setBody(reqBody);
        Http http2 = new Http();   
        HttpResponse response1 = http2.send(requestFolders); 
        System.debug('***** httpResponse-->' + response1.getStatusCode() + '  ' + response1.getStatus());
        if(!Test.isRunningTest() && response1.getStatusCode() != 200 && response1.getStatusCode() != 201){
            CalloutException e = (CalloutException)CalloutException.class.newInstance();
            e.setMessage('relativeFolderPath: ' + relativeFolderPath + ':' + 'getStatusCode: ' + response1.getStatusCode() + ':' + 'getStatus: ' + response1.getStatus());
            throw e;   
        }  
        return response1.getStatusCode();
        //System.debug('***** httpResponse-->' + response1);
    }
    
    public static Integer findFolder(String token, String folderName){
        HttpRequest requestFolders = new HttpRequest();
        string nameOfFolder = folderName.replace(' ', '%20');
        nameOfFolder = EncodingUtil.urlEncode((folderName), 'UTF-8').replace('+', '%20').replace('%', '%25').replace('/', '%2F').replace('|', '%7C').replace('&', '%26');
        requestFolders.setEndpoint('https://globalsharepoint2019.sharepoint.com/sites/SharePointRND/_api/web/GetFolderByServerRelativeUrl(\'Shared%20Documents/' + nameOfFolder +'\')');
        requestFolders.setMethod('GET');
        requestFolders.setHeader('Authorization', 'Bearer ' + token);
        requestFolders.setHeader('Accept', 'application/json;odata=verbose');
        
        Http http2 = new Http();   
        HttpResponse response1 = http2.send(requestFolders);  
        //System.debug('***** httpResponse-->' + response1);   
        return response1.getStatusCode();
    }
    
    public static Map<integer, string> createFile(String token, String relativeFolderPath, String fileName, blob fileBody){
		String folderPath = EncodingUtil.urlEncode(('Shared Documents/' + relativeFolderPath), 'UTF-8').replace('+', '%20').replace('/', '%2F').replace('|', '%7C').replace('&', '%26');//.replace('%', '%25')
		//String folderPath = ('Shared%20Documents/' + relativeFolderPath);
        //String folderPath = ('Shared Documents/' + relativeFolderPath).replace('+', '%20').replace('%', '%25').replace('/', '%2F').replace('|', '%7C').replace('&', '%26');
        string nameOfFile = EncodingUtil.urlEncode(fileName, 'UTF-8');//%2E
        /*  The less mistakes when it is so
		String folderPath = EncodingUtil.urlEncode(('Shared Documents/' + relativeFolderPath), 'UTF-8').replace('+', '%20');  //EncodingUtil.urlEncode(relativeFolderPath, 'UTF-8');//relativeFolderPath.replace(' ', '%20');
        string nameOfFile = EncodingUtil.urlEncode(fileName, 'UTF-8');//fileName.replace(' ', '%20');
         */
        HttpRequest requestFile = new HttpRequest();
        system.debug('https://globalsharepoint2019.sharepoint.com/sites/SharePointRND/_api/web/GetFolderByServerRelativeUrl(\'' + folderPath + '\')/Files/add(url=\''+nameOfFile+'\',overwrite=true)');
        requestFile.setEndpoint('https://globalsharepoint2019.sharepoint.com/sites/SharePointRND/_api/web/GetFolderByServerRelativeUrl(\'' + folderPath + '\')/Files/add(url=\''+nameOfFile+'\',overwrite=true)');
        requestFile.setMethod('POST');
        requestFile.setHeader('Authorization', 'Bearer ' + token);
        requestFile.setHeader('Accept', 'application/json;odata=verbose');
        requestFile.setHeader('Content-Length', '125');
        //String fileBody = 'Test File Body';
        //requestFile.setBodyAsBlob(Blob.ValueOf(fileBody));
        requestFile.setBodyAsBlob(fileBody);
        Http http3 = new Http();   
        HttpResponse response2 = http3.send(requestFile);  
        System.debug('***** createFile httpResponse-->' + response2);
        /*System.debug(response2.getBody());
        Map<String, Object> mp = (Map<String, Object>) JSON.deserializeUntyped(response2.getBody());
        for(string key: mp.keySet()){
            system.debug(mp.get(key));
        }*/
        Map<integer, string> respRes = new Map<integer, string>();
        respRes.put(response2.getStatusCode(), response2.getStatus());
        return respRes;//response2.getStatusCode();
    }
    
    public static Integer findFile(String accessToken, String fileName, String folderName){
        String fileUrlEncoded = EncodingUtil.urlEncode(fileName, 'UTF-8');
        String folder = EncodingUtil.urlEncode(folderName, 'UTF-8');

        HttpRequest requestFolders = new HttpRequest();
		requestFolders.setEndpoint('https://globalsharepoint2019.sharepoint.com/sites/SharePointRND/_api/web/GetFolderByServerRelativeUrl(\'' + folder + '\')/Files(\''+ fileUrlEncoded +'\')');
        requestFolders.setMethod('GET');
        requestFolders.setHeader('Authorization', 'Bearer ' + accessToken);
        requestFolders.setHeader('Accept', 'application/json;odata=verbose');
        Http http2 = new Http();   
        HttpResponse response1 = http2.send(requestFolders); 
        return response1.getStatusCode();
    }
   
}
