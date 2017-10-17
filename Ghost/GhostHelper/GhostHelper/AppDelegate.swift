//
//  AppDelegate.swift
//  GhostHelper
//
//  Created by Damjan Dimovski on 10/14/17.
//  Copyright © 2017 Damjan Dimovski. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if NSRunningApplication.runningApplications(withBundleIdentifier: "com.dimovskiapps.Ghost").isEmpty {
            NSWorkspace.shared.launchApplication(withBundleIdentifier: "com.dimovskiapps.Ghost",
                                                 options: .default,
                                                 additionalEventParamDescriptor: nil,
                                                 launchIdentifier: nil)
        }
        NSApp.terminate(nil)
    }
}

