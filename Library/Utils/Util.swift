//
//  Util.swift
//  DuClothes
//
//  Created by zhaoxiaolu on 15/3/11.
//  Copyright (c) 2015年 zhaoxiaolu. All rights reserved.
//

import Foundation
import CoreLocation
class Util: NSObject {
    
    /**
    判断相机是否可用
    
    :returns: bool
    */
    class func isCameraAvailable() -> Bool {
        return UIImagePickerController.isCameraDeviceAvailable(.Rear) && UIImagePickerController.isSourceTypeAvailable(.Camera)
    }
    
    /**
    json转object
    
    :param: jsonStr json
    
    :returns: object
    */
    class func objectFromJSONString(jsonStr:NSString) -> AnyObject {
        if (jsonStr.isEqualToString("")) {
            return jsonStr
        }
        var jsonData:NSData = jsonStr.dataUsingEncoding(NSUTF8StringEncoding)!
        var error:NSError?
        var returnValue:AnyObject! = NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers, error: &error)
        if let err = error {
            NSLog("json数据转换失败: %@", error!)
            return jsonStr
        }
        return returnValue
    }
    
    /**
    计算两个点之间的距离
    
    :param: lat1 经度
    :param: lng1 纬度
    :param: lat2 经度
    :param: lng2 纬度
    
    :returns: 距离
    */
    class func distanceBetweenOrderBy(lat1:Double, lng1:Double, lat2:Double, lng2:Double) -> Double {
        var curLocation:CLLocation = CLLocation(latitude: lat1, longitude: lng1)
        var otherLocation:CLLocation = CLLocation(latitude: lat2, longitude: lng2)
        var distance:Double = curLocation.distanceFromLocation(otherLocation)
        
        return distance
    }
    
    /**
    封装的获取文件路径方法
    
    :param: fileName 文件名字
    
    :returns: return value description
    */
    class func getPath(fileName: String) -> String {
        return NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0].stringByAppendingPathComponent(fileName)
    }
    
    /**
    复制文件的操作封装
    
    :param: fileName <#fileName description#>
    */
    class func copyFile(fileName: NSString) {
        var dbPath: String = getPath(fileName as String)
        var fileManager = NSFileManager.defaultManager()
        if !fileManager.fileExistsAtPath(dbPath) {
            var fromPath: String? = NSBundle.mainBundle().resourcePath?.stringByAppendingPathComponent(fileName as String)
            fileManager.copyItemAtPath(fromPath!, toPath: dbPath, error: nil)
        }
    }
    
    /**
    获取document路径
    
    :returns: return value description
    */
    class func  getDocumentPath() -> String {
        var path:Array = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory,NSSearchPathDomainMask.UserDomainMask,true)
        return path[0] as! String
    }
    
    /**
    获取cache路径
    
    :returns: return value description
    */
    class func  getCachesPath() -> String {
        var path:Array = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory,NSSearchPathDomainMask.UserDomainMask,true)
        return path[0] as! String
    }
    
    /**
    获取图片
    
    :param: fileName 图片名
    
    :returns: uiimage obejct
    */
    class func getImageForBundle(fileName: String!) -> UIImage {
        return UIImage(named:fileName)!
    }
    
    /**
    从document获取image
    
    :param: fileName 图片名
    
    :returns: uiimage
    */
    class func getImageFormDecoument(fileName: String!)->UIImage{
        return UIImage(contentsOfFile: getDocumentPath()+"/"+fileName)!
    }
    
    /**
    存储图片
    
    :param: imageName     原图片名
    :param: saveImageName 存储的图片名
    
    :returns: bool
    */
    class func saveBundleImageToDoc(imageName: String!, saveImageName: String!) -> Bool {
        var uniquePath:String = getDocumentPath()+"/"+saveImageName
        
        var blHave:Bool = NSFileManager.defaultManager().fileExistsAtPath(uniquePath)
        if blHave {
            var blDele:Bool = NSFileManager.defaultManager().removeItemAtPath(uniquePath, error: nil)
            if blDele {
                println("delet success")
            }else{
                println("delet erro")
                return false
            }
        }
        var arry =  imageName.componentsSeparatedByString(".")
        var path:String =  NSBundle.mainBundle().pathForResource(arry[0] as String, ofType: arry[1] as String)!
        var data:NSData = NSData(contentsOfFile: path, options: NSDataReadingOptions.DataReadingMapped, error: nil)!
        var result:Bool = data.writeToFile(uniquePath, atomically: true)
        return result
    }
    
    /**
    删除文件方法封装
    
    :param: fileName 文件名
    
    :returns: bool
    */
    class func deletFileFromDoc(fileName: String!) -> Bool {
        var blHave:Bool = NSFileManager.defaultManager().fileExistsAtPath(getDocumentPath()+"/"+fileName)
        if blHave {
            return NSFileManager.defaultManager().removeItemAtPath(getDocumentPath()+"/"+fileName, error: nil)
        }else{
            return false
        }
    }
    
    /**
    将数据存储到一个plist文件中
    
    :param: plistName 文件名
    :param: listData  数据
    
    :returns: bool
    */
    class func saveDataPlistToDoc(plistName:String!, listData:NSMutableDictionary!) -> Bool {
        var result:Bool =  listData.writeToFile(getDocumentPath()+"/"+plistName, atomically: true)
        return result;
    }
    
    /**
    计算uilabel中的字体高度
    
    :param: text  字体
    :param: font  font值
    :param: width 宽度
    
    :returns: 高度
    */
    class func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, width, CGFloat.max))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
    /**
    计算uilabel中的文字宽度 默认单行
    
    :param: targetLabel  目标label
    :param: contentStr  label内容
    
    :returns: size
    */
    class func getLabelSizeToContent(targetLabel: UILabel, contentStr: NSString) -> CGSize {
        targetLabel.text = contentStr as String
        var constrantSize: CGSize = CGSizeZero
        var labelSize: CGSize = contentStr.boundingRectWithSize(constrantSize, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: targetLabel.font], context: nil).size
        return labelSize
    }
    
    /**
    复制view
    
    :param: view uiview
    
    :returns: uiview
    */
    class func copyView(view:UIView) -> UIView {
        var tempArchive:NSData = NSKeyedArchiver.archivedDataWithRootObject(view)
        return NSKeyedUnarchiver.unarchiveObjectWithData(tempArchive) as! UIView
    }
    
    /**
    延时执行
    
    :param: delay   时间
    :param: closure block
    */
    class func hwcDelay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    /**
    将object转换成json数据
    
    :param: object objct
    
    :returns: json类型
    */
    class func JSONStringFromObject(object:AnyObject) -> NSString {
        var jsonString:NSString!
        var error:NSError? = nil
        var jsonData:NSData = NSJSONSerialization.dataWithJSONObject(object, options: NSJSONWritingOptions.PrettyPrinted, error: &error)!
        if (jsonData.length > 0 && error == nil) {
            jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding)
        }
        return jsonString
    }
    
    /**
    生成统一样式的alertView
    
    :param: title  alertview头部标题
    :param: message  主体警告信息
    :param: delegate  delegate
    :param: cancelButtonTitle  按钮文字
    
    */
    class func createAlertView(title: String, message: String, delegate: AnyObject!, cancelButtonTitle: String) {
        let alert = UIAlertView(title: title, message: message, delegate: delegate, cancelButtonTitle: cancelButtonTitle)
        alert.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        alert.show()
    }
    
    /**
    动画封装
    
    :param: aniView  执行动画的view
    :param: aniName  动画命名（不重要）
    :param: duration  动画时长
    :param: curveStyle  动画时间曲线
    :param: customHandler  动画终态定义
    
    */
    class func animateHandler(aniView: AnyObject, aniName: String, duration: NSTimeInterval, curveStyle: UIViewAnimationCurve, repeatCount: Float, customHandler: (() -> Void)) {
        UIView.beginAnimations(aniName, context: nil)
        UIView.setAnimationDuration(duration)
        UIView.setAnimationCurve(curveStyle)
        UIView.setAnimationRepeatCount(repeatCount)
//        UIView.setAnimationRepeatAutoreverses(true)
        customHandler()
        UIView.commitAnimations()
    }
    
    
}
