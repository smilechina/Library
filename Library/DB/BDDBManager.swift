//
//  BDDBManager.swift
//  DuClothes
//
//  Created by zhaoxiaolu on 15/3/10.
//  Copyright (c) 2015年 zhaoxiaolu. All rights reserved.
//

import Foundation
class BDDBManager:NSObject {
    
    //前提将FMDBDatabase的头文件加入到桥接文件中
    var dbQueue:FMDatabaseQueue!
    var dbFilePath:NSString!
    
    /**
    创建单例
    
    :returns: return value description
    */
    class func shareInstance()->BDDBManager{
        struct qzSingle{
            static var predicate:dispatch_once_t = 0;
            static var instance:BDDBManager? = nil
        }
        //保证单例只创建一次
        dispatch_once(&qzSingle.predicate,{
            qzSingle.instance = BDDBManager()
        })
        return qzSingle.instance!
    }
    
    /**
    初始化数据库
    
    :param: name 数据库名字
    
    :returns: <#return value description#>
    */
    func initDBWithName(name:NSString) {
        //获取新建数据库语句的文件路径
        var filePath:NSString = NSBundle.mainBundle().pathForResource("create", ofType: "sql")!
        //用分号分割字符串
        //以字符串的方式读取文件
        var sql_string:NSString = NSString(contentsOfFile: filePath as String, usedEncoding: nil, error: nil)!
        var characterSet:NSCharacterSet = NSCharacterSet(charactersInString: ";")
        //讲字符串用；分割,sqls必须为mutable array
        var sqls:NSMutableArray = NSMutableArray(array: sql_string.componentsSeparatedByCharactersInSet(characterSet))
        //删除最后一个空的
        sqls.removeLastObject()
        //定义存放的路径
        self.dbFilePath = Util.getPath(NSString(format: "%@.db", name) as String)

        //队列执行
        self.dbQueue = FMDatabaseQueue(path: self.dbFilePath as String)
        //事务执行
        //这个地方好蛋疼的说，一个是executeUpdate执行的第一个参数要加上双引号，一个是return
        self.dbQueue?.inTransaction({ (db, rollback) -> Void in
            for sql in sqls {
                if !db.executeUpdate("\(sql)", withArgumentsInArray: []) {
//                    println("create failure: \(db.lastErrorMessage())")
                    rollback.initialize(true)
                    return
                }
            }
        })
        
    }
    
    /**
    同步执行db操作
    
    :param: operationBlock operationBlock description
    */
    func doOperationInDatabaseSync(operationBlock:((FMDatabase) -> Void)) {
        weak var weakSelf = self
        weakSelf?.dbQueue?.inDatabase({ (db:FMDatabase!) -> Void in
            operationBlock(db)
        })
    }
    
    /**
    异步执行db操作
    
    :param: operationBlock operationBlock description
    */
    func doOperationInDatabaseAsync(operationBlock:((FMDatabase) ->Void)) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            weak var weakSelf = self
            weakSelf?.dbQueue?.inDatabase({ (db:FMDatabase!) -> Void in
                operationBlock(db)
            })
        })
    }
    
    /**
    同步执行db事务操作
    
    :param: operationBlock operationBlock description
    */
    func doOperationInTransactionSync(operationBlock:((FMDatabase)->Void)) {
        weak var weakSelf = self
        weakSelf?.dbQueue?.inTransaction({ (db, rollback) -> Void in
            operationBlock(db)
        })
    }
    
    /**
    异步执行db事务操作
    
    :param: operationBlock operationBlock description
    */
    func doOperationInTransactionAsync(operationBlock:((FMDatabase)->Void)) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            weak var weakSelf = self
            weakSelf?.dbQueue?.inTransaction({ (db, rollback) -> Void in
                operationBlock(db)
            })
        })
    }
    
    
    
}
