//
//  NetworkDataRetrievalOperation.swift
//  SwiftWeather
//
//  Created by Mykhailo Vorontsov on 29/03/2016.
//  Copyright © 2016 Mykhailo Vorontsov. All rights reserved.
//

import UIKit

private let Consts = (
  networkTimeout : 60.0,
  allowedCharacters : (
    generalDelimitersToEncode : ":#[]@", // does not include "?" or "/" due to RFC 3986 - Section 3.4
    subDelimitersToEncode : "!$&'()*+,;="
  ),
  headerContentTypeKey : "Content-Type"
)

open class NetworkDataRetrievalOperation: DataRetrievalOperation, NetworkDataRetrievalOperationProtocol {
  
  open var task: URLSessionTask? = nil
  open var session:URLSession? = nil
  open var request: URLRequest? = nil
  open var requestEndPoint: String? = nil
  open var requestPath: String? = nil
  
  open var requestMethod: NetworkRequestMethod = .GET
  open var requestParametersEncoding: NetworkParameterEncoding = .JSON
  
  open lazy var requestParameters: [String : AnyObject] = {return [String : AnyObject]()}()
  open lazy var requestHeaders: [String : String] = {return [String : String]()}()
  
  open var response: URLResponse? = nil
  
  func encodeParameters(_ parameters:[String : AnyObject]) -> String {
    var parametersString = ""
    let generalDelimitersToEncode = Consts.allowedCharacters.generalDelimitersToEncode
    let subDelimitersToEncode = Consts.allowedCharacters.subDelimitersToEncode
    
    let allowedCharacterSet = (CharacterSet.urlQueryAllowed as NSCharacterSet).mutableCopy() as! NSMutableCharacterSet
    allowedCharacterSet.removeCharacters(in: generalDelimitersToEncode + subDelimitersToEncode)
    
    for (key, value) in parameters {
      parametersString += parametersString.characters.count > 0 ? "&" : ""
      if let formattedKey = NSString(string:key).addingPercentEncoding(withAllowedCharacters: allowedCharacterSet as CharacterSet),

        let formattedValue = String(describing: value).addingPercentEncoding(withAllowedCharacters: allowedCharacterSet as CharacterSet) {

        parametersString += "\(formattedKey)=\(formattedValue)"
      }
    }
    return parametersString
  }
  
  override open func prepareForRetrieval() throws {
    try super.prepareForRetrieval()
    // Generate base URL by endPoint. No request possible without endPoint
    guard
      let base = requestEndPoint,
      var url = URL(string: base)
      else {
        throw DataRetrievalOperationError.invalidParameter(parameterName: "URL")
    }
    // Add path if any
    if let path = requestPath {
      url = url.appendingPathComponent(path)
    }
    
    let method = requestMethod
    
    if  requestParameters.count > 0 {
      switch method {
      case .GET:
        let parametersString = encodeParameters(requestParameters)
        url = URL(string: "?" + parametersString, relativeTo: url) ?? url
      case .POST:
        //TODO: Insert some code for assembling POST reuqest if needed
        break
      }
    }
    
    //MARK: Construct request
    let theRequest = NSMutableURLRequest(url:url)
    theRequest.httpMethod = method.rawValue
    var headers = requestHeaders
    headers[Consts.headerContentTypeKey] = requestParametersEncoding.rawValue
    for (key, value) in headers {
      theRequest.addValue(value, forHTTPHeaderField: key)
    }
    
    request = theRequest as URLRequest
  }
  
  override open func retriveData() throws {
    try super.retriveData()
    
    // If no particular session specified - use shared session
    if nil == session {
      session = URLSession.shared
    }
    
    guard let session = session,
      let request = request else {
        throw DataRetrievalOperationError.invalidParameter(parameterName: "Session")
    }
    let semaphore = DispatchSemaphore(value: 0)
    var inTaskError:DataRetrievalOperationError? = nil
    
    task = session.dataTask(with: request, completionHandler: {[unowned self] (data, response, nserror) -> Void in
      
      guard false == self.isCancelled else {
        return
      }
      
      self.response = response
      self.data = data
      
      //// For debug purpose: print string representation of response data, if any. Uncoment code bellow.
      //      if let data = data {
      //        let stringRepresentation = NSString(data: data, encoding: 0)
      //        print("Request:\(self.task?.originalRequest)\nResponse:\(response)\nData:\(stringRepresentation)")
      //      }
      
      // Process possible network layer errors:
      if let nserror = nserror {
        inTaskError = DataRetrievalOperationError.networkError(error: nserror as NSError)
        
      }
      //  Process server errors
      if let response = response as? HTTPURLResponse,
        let statusCode:Int = response.statusCode,
        false == (200 ..< 299 ~= statusCode),
        nil == inTaskError {
        inTaskError = DataRetrievalOperationError.serverResponse(
          errorCode: statusCode,
          errorResponse: response,
          responseData: data
        )
        
      }
      
      // Release semaphore
      semaphore.signal()
    }) 
    
    guard let task = task else {
      throw DataRetrievalOperationError.invalidParameter(parameterName: "Task")
    }
    task.resume()
    
    let timeout = session.configuration.timeoutIntervalForRequest + 1.0
    _ = semaphore.wait(timeout: DispatchTime.now() + Double(Int64(timeout * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC))
    
    // If error occured during netwrok tesk execution - throw
    if let taskError = inTaskError {
      throw taskError
    }
    
    // If network task doesn't completed - throw
    guard .completed == task.state else {
      throw DataRetrievalOperationError.networkError(error: nil)
    }
  }
  
  open override func convertData() throws {
    try super.convertData()
    guard let data = data else {
      throw DataRetrievalOperationError.wrongDataFormat(error: nil)
    }
    do {
      let converted = try JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions(rawValue:0))
      convertedObject = converted as AnyObject
    }
    catch {
      throw DataRetrievalOperationError.wrongDataFormat(error: error)
    }
  }
  
  open override func cancel() {
    task?.cancel()
    super.cancel()
  }
  
}
