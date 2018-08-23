//
//  AppDelegate.swift
//  Bresenham-Line
//
//  Created by Cirno MainasuK on 2017-3-17.
//  Copyright © 2017年 Cirno MainasuK. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application

    }


}

public typealias Screen = NSScreen

extension NSScreen {
    static var retinaScale: CGFloat {
       return NSScreen.main()!.backingScaleFactor
       }
}

