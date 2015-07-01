//
//  BDNetworkManager.swift
//  DuClothes
//
//  Created by zhaoxiaolu on 15/3/4.
//  Copyright (c) 2015年 zhaoxiaolu. All rights reserved.
//

import Foundation
import UIKit

class BDNetworkManager: NSObject {
    let AFHTTPManger = AFHTTPRequestOperationManager()
    var sessionManager:AFURLSessionManager!
    
    override init() {
        super.init()
        //设置timeout时间
        AFHTTPManger.requestSerializer.timeoutInterval = 20.0
        AFHTTPManger.securityPolicy.allowInvalidCertificates = true
        AFHTTPManger.responseSerializer.acceptableContentTypes = NSSet(object: "application/json") as Set<NSObject>
        AFHTTPManger.reachabilityManager.startMonitoring()
        AFHTTPManger.reachabilityManager.setReachabilityStatusChangeBlock { (status:AFNetworkReachabilityStatus) -> Void in
            switch status {
            case .Unknown,.ReachableViaWiFi,.ReachableViaWWAN:
                NETSTATUS = 1
                NSNotificationCenter.defaultCenter().postNotificationName("NetworkStatusNormal", object: nil)
//                println("网络状态正常")
                break
            case AFNetworkReachabilityStatus.NotReachable:
                NETSTATUS = 0
                NSNotificationCenter.defaultCenter().postNotificationName("NetworkStatusUnusual", object: nil)
//                println("网络状态异常")
                break
            default:
                break
            }
        }
        sessionManager = AFURLSessionManager(sessionConfiguration: NSURLSessionConfiguration.defaultSessionConfiguration())
        var mySerializer:AFHTTPResponseSerializer = AFHTTPResponseSerializer()
        mySerializer.acceptableContentTypes = NSSet(object: "application/json") as Set<NSObject>
        sessionManager.responseSerializer = mySerializer
        
        //网络活动指示器
        AFNetworkActivityIndicatorManager.sharedManager().enabled = true
    }
    /**
    创建单例
    
    :returns: <#return value description#>
    */
    class func shareInstance()->BDNetworkManager{
        struct YRSingleton{
            static var predicate:dispatch_once_t = 0
            static var instance:BDNetworkManager? = nil
        }
        dispatch_once(&YRSingleton.predicate,{
            YRSingleton.instance=BDNetworkManager()
            }
        )
        return YRSingleton.instance!
    }
    
    /**
    get方法封装
    
    :param: url        url
    :param: parameters 参数
    :param: success    成功回调
    :param: failure    失败回调
    */
    func getMethod(url: NSString,
        parameters: NSDictionary,
        success:((AnyObject) -> Void),
        failure:((NSString) -> Void)) -> Void {
            AFHTTPManger.GET(
                url as String,
                parameters: parameters,
                success: {
                    (operation:AFHTTPRequestOperation!,
                    responseObject: AnyObject!) in
                    
                    var responseDict = responseObject as! NSDictionary
                    var respCode = responseDict.objectForKey("code")?.intValue
                    if respCode == 0 {
                        success(responseDict.objectForKey("data")!)
                    } else {
                        failure(responseDict.objectForKey("message") as! String)
                    }
                    
                },
                failure: {(operation: AFHTTPRequestOperation!,
                    error: NSError!) in
                    
                    failure(error.localizedDescription)
                    println("Error: " + error.localizedDescription)
            })
    }
    
    /**
    post方法封装
    
    :param: url        url
    :param: parameters 参数
    :param: success    成功回调
    :param: failure    失败回调
    */
    func postMethod(url: NSString,
        parameters:NSDictionary,
        success:((NSDictionary)->Void),
        failure:((NSString)->Void)) {
            
            AFHTTPManger.POST(
                url as String,
                parameters: parameters,
                success: {
                    (operation:AFHTTPRequestOperation!,
                    responseObject: AnyObject!) in
                    
                    let responseDict = responseObject as! NSDictionary!
                    success(responseDict)
                },
                failure: {(operation: AFHTTPRequestOperation!,
                    error: NSError!) in
                    
                    failure(error.localizedDescription)
                    println("Error: " + error.localizedDescription)
            })
    }
    
    /**
    post上传方法封装
    
    :param: url            <#url description#>
    :param: parameters     <#parameters description#>
    :param: fileParamsDict <#fileParamsDict description#>
    :param: success        <#success description#>
    :param: failure        <#failure description#>
    */
    func postUpfile(url:String,
        parameters:AnyObject,
        fileParamsDict:NSDictionary,
        success:((AnyObject)->Void),
        failure:((NSString)->Void)) {
            
            var serializer:AFHTTPRequestSerializer = AFHTTPRequestSerializer()
            var urlRequest:NSMutableURLRequest = serializer.multipartFormRequestWithMethod(
                "POST",
                URLString: url,
                parameters: parameters as! [NSObject : AnyObject],
                constructingBodyWithBlock: { (formData:AFMultipartFormData!) -> Void in
                    var keys:NSArray = fileParamsDict.allKeys
                    for key in keys as! [String] {
                        formData.appendPartWithFileData(
                            fileParamsDict.objectForKey(key) as! NSData,
                            name: key,
                            fileName: "a.jpg",
                            mimeType: "image/jpeg"
                        )
                    }
            }, error: nil)

            var requestOperation:AFHTTPRequestOperation = self.AFHTTPManger.HTTPRequestOperationWithRequest(urlRequest,
                success: { (operation:AFHTTPRequestOperation!, responseObject:AnyObject!) -> Void in
                    var respDict:NSDictionary = responseObject as! NSDictionary
                    var respCode = respDict.objectForKey("code")?.intValue
                    if respCode == 0 {
                        success(respDict.objectForKey("data")!)
                    } else {
                        failure(respDict.objectForKey("message") as! String)
                    }
                },
                failure:  {
                    (operation:AFHTTPRequestOperation!, error:NSError!) -> Void in
                    failure(error.localizedDescription)
            })
            
            requestOperation.start()
//            return requestOperation
    }
    
}
