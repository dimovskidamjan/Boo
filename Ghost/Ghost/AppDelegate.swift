//
//  AppDelegate.swift
//  Ghost
//
//  Created by Damjan Dimovski on 10/13/17.
//  Copyright © 2017 Damjan Dimovski. All rights reserved.
//

import Cocoa
import ServiceManagement

let launcherAppId = "com.dimovskiapps.GhostHelper"

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var isShowingHiddenFiles: Bool {
        let task = Process()
        task.launchPath = "/usr/bin/defaults"
        task.arguments = ["read", "com.apple.finder", "AppleShowAllFiles"]
        let outpipe = Pipe()
        task.standardOutput = outpipe
        let errpipe = Pipe()
        task.standardError = errpipe
        
        task.launch()
        
        let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: outdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            return (string == "TRUE" || string == "YES" || string == "true" || string == "yes")
        }
        
        let errdata = errpipe.fileHandleForReading.readDataToEndOfFile()
        if var _ = String(data: errdata, encoding: .utf8) {
            return true
        }
        
        task.waitUntilExit()
        
        return false
    }

    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name(isShowingHiddenFiles ? "ghost" : "ghostOutline"))
        }
        constructMenu()
    }
    
    func constructMenu() {
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: isShowingHiddenFiles ? "Hide" : "Show", action: #selector(AppDelegate.toggleHideFiles(_:)), keyEquivalent: ""))
        let launchItem = NSMenuItem(title: "Launch on start", action: #selector(AppDelegate.toggleLaunchOnStart(_:)), keyEquivalent: "")
        launchItem.state = UserDefaults.standard.bool(forKey: "loginItemEnabled") ? .on : .off
        menu.addItem(launchItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Ghost", action: #selector(NSApplication.terminate(_:)), keyEquivalent: ""))
        
        statusItem.menu = menu
    }
    
    @objc func toggleHideFiles(_ sender: NSMenuItem) {
        var flag = "TRUE"
        if isShowingHiddenFiles {
            flag = "FALSE"
        }
        
        let task = Process()
        task.launchPath = "/usr/bin/defaults"
        task.arguments = ["write", "com.apple.finder", "AppleShowAllFiles", flag]
        let outpipe = Pipe()
        task.standardOutput = outpipe
        let errpipe = Pipe()
        task.standardError = errpipe
        task.launch()
        
        let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
        if var _ = String(data: outdata, encoding: .utf8) {
            sender.title = isShowingHiddenFiles ? "Hide" : "Show"
            if let button = statusItem.button {
                button.image = NSImage(named:NSImage.Name(isShowingHiddenFiles ? "ghost" : "ghostOutline"))
            }
        }
        
        let errdata = errpipe.fileHandleForReading.readDataToEndOfFile()
        if let msg = String(data: errdata, encoding: .utf8) {
            NSLog(msg)
        }
        
        task.waitUntilExit()
        
        let command = NSAppleScript(source: "tell application \"Finder\" to quit")
        command?.executeAndReturnError(nil)
        
        let command1 = NSAppleScript(source: "tell application \"Finder\" to activate")
        command1?.executeAndReturnError(nil)
    }
    
    @objc func toggleLaunchOnStart(_ sender: NSMenuItem) {
        if sender.state == .off {
            // Turn on launch at login
            if (!SMLoginItemSetEnabled(launcherAppId as CFString, true)) {
                let alert = NSAlert()
                alert.messageText = "Login item toggle - error."
                alert.informativeText = "Application couldn't be added as Login item."
                alert.alertStyle = .warning
                alert.addButton(withTitle: "OK")
                alert.runModal()
            }
            sender.state = .on
        } else {
            // Turn off launch at login
            if (!SMLoginItemSetEnabled(launcherAppId as CFString, false)) {
                let alert = NSAlert()
                alert.messageText = "Login item toggle - error."
                alert.informativeText = "Application couldn't be removed from Login items."
                alert.alertStyle = .warning
                alert.addButton(withTitle: "OK")
                alert.runModal()
            }
            sender.state = .off
        }
        
        UserDefaults.standard.set(sender.state == .on, forKey: "loginItemEnabled")
    }
}

