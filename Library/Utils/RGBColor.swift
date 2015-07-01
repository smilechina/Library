//
//  RGBColor.swift
//  Clothes
//
//  Created by zhaoxiaolu on 15/3/23.
//  Copyright (c) 2015年 zhaoxiaolu. All rights reserved.
//

import UIKit

func UIColorFromRGB(rgbValue: UInt) -> UIColor {
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

//eg:UIColorFromRGB(0x00b377)