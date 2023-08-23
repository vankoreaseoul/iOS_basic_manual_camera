//
//  Utils.swift
//  CameraTest
//
//  Created by Heawon Seo on 2023/08/17.
//

import UIKit

class UIScreenSize {
    static let width = UIScreen.main.bounds.size.width
    static let height = UIScreen.main.bounds.size.height
}

func Log<T>(_ object: T?, filename: String = #file, line: Int = #line, funcname: String = #function) {
#if DEBUG
    guard let object = object else {
        return
    }
    print("***** \(Date()) \(filename.components(separatedBy: "/").last ?? "") (line: \(line)) :: \(funcname) :: \(object)")
#endif
}

