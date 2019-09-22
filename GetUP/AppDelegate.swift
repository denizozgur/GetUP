//
//  AppDelegate.swift
//  GetUP
//
//  Created by Doe on 3/6/18.
//  Copyright © 2018 Doe. All rights reserved.
//
import AVFoundation
import UIKit
import UserNotifications
import CustomAlert

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate , AVAudioPlayerDelegate , UNUserNotificationCenterDelegate {
    var audioPlayer : AVAudioPlayer?
    var window: UIWindow?
    let alarmScheduler = AlarmScheduler()
    func applicationWillResignActive(_ application: UIApplication) {
        //        print("app will resing")
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        if let alarmsTVC = window?.rootViewController?.children[0].children.first as? AlarmsTableViewController {
            alarmScheduler.alarms = alarmsTVC.alarmArrayForAlarmTVC
            //            print(alarmScheduler.alarms)
            if alarmsTVC.alarmsToRemove.isEmpty == false {
                alarmScheduler.removeRequest(alarmsTVC.alarmsToRemove)
                alarmsTVC.alarmsToRemove.removeAll()
                //                print("alarm removal req been made and array set to nil")
            }
            //            print("alarms from tvc is set in scheduler --- resign")
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        //        print("app enter background")
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        //        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        //        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        alarmScheduler.synchAlarms()
    }
    
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        //        print("Application will enter foreground")
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        if let alarmsTVC = window?.rootViewController?.children[0].children.first as? AlarmsTableViewController {
            alarmsTVC.alarmArrayForAlarmTVC = alarmScheduler.alarms
            print("alarms set from sceduler to tvc")
            alarmsTVC.update()
        }
    }
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        //        print("app WILL finish launching")
        ///Assigning the scheduler delegate in AlarmsTableViewController
        if let alarmsTVC = window?.rootViewController?.children[0].children.first as? AlarmsTableViewController {
            alarmsTVC.alarmArrayForAlarmTVC = alarmScheduler.alarms
            alarmsTVC.scheduler = alarmScheduler
            //            print("alarms set from scheduler to TVC and also scheduler set")
        }
        return true
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        //        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: {print($0)})
        //        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //        print("app did finish launching")
        //create the notificationCenter
        let category = UNNotificationCategory(identifier: "GetUpAlarmApp", actions: [], intentIdentifiers: [], options: .customDismissAction)
        let center = UNUserNotificationCenter.current()
        center.setNotificationCategories([category])
        center.delegate = self
        // set the type as sound or badge
        center.requestAuthorization(options: [.sound,.alert]) { (granted, error) in
            if granted {
                print("Notification Enable Successfully")
            }else{
                print("Some Error Occure :  \(String(describing: error?.localizedDescription)) ")
            }
        }
        //        application.registerForRemoteNotifications()
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .defaultToSpeaker)
        } catch let error {
            print("problem with audio set session Error : \(error.localizedDescription)")
        }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error {
            print("problem with audio set active Error : \(error.localizedDescription)")
        }
        return true
    }
    //This is the two delegate method to get the notification in iOS 10..
    //First for foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (_ options:UNNotificationPresentationOptions) -> Void)
    {
        //        print("Handle push from foreground")
        //        // custom code to handle push while app is in the foreground
        //        print("\(notification.request.content)")
        let alarm = notification.request.getAlarmFromNotificationRequest()
        if let index = alarmScheduler.alarms.index(of: alarm) {
            alarmScheduler.alarms.remove(at: index)
            alarmScheduler.scheduledNotificationIDs.remove(at: alarmScheduler.scheduledNotificationIDs.index(of: alarm.id)!)
        }
        if let alarmVTC = window?.rootViewController?.children[0].children[0]as? AlarmsTableViewController {
            if let indexInVC = alarmVTC.alarmArrayForAlarmTVC.index(of: alarm){
                alarmVTC.alarmArrayForAlarmTVC.remove(at: indexInVC)
            }
        }
        let alert = CustomAlertView(frame: (window?.frame)!)
        ring("localRingtones")
        alert.delegate = audioPlayer
        window?.rootViewController?.view.addSubview(alert)
    }
    //Second for background and close
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response:UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void)
    {
        //Response object has information about the action user did for notification
        let alarm = response.notification.request.getAlarmFromNotificationRequest()
        if let index = alarmScheduler.alarms.index(of: alarm) {
            alarmScheduler.alarms.remove(at: index)
            alarmScheduler.scheduledNotificationIDs.remove(at: alarmScheduler.scheduledNotificationIDs.index(of: alarm.id)!)
        }
        if let alarmVTC = window?.rootViewController?.children[0].children[0] as? AlarmsTableViewController {
            if let indexInVC = alarmVTC.alarmArrayForAlarmTVC.index(of: alarm){
                alarmVTC.alarmArrayForAlarmTVC.remove(at: indexInVC)
            }
        }
        let alert = CustomAlertView(frame: (window?.frame)!)
        ring("localRingtones")
        alert.delegate = audioPlayer
        window?.rootViewController?.view.addSubview(alert)
    }
    
    //
    //        //get device token here
    //        func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken
    //            deviceToken: Data)
    //        {
    //            var token = ""
    //            for i in 0..<deviceToken.count {
    //                token = token + String(format: "%02.2hhx", arguments: [deviceToken[i]])
    //            }
    //            print("Registration succeeded!")
    //            print("Token: ", token)
    //
    //            //send tokens to backend server
    //            //        storeTokens(token)
    //        }
    //
    //        //get error here
    //        func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error:
    //            Error) {
    //            print("Registration failed!")
    //        }
    //
    func ring(_ named : String) {
        let asset = NSDataAsset(name: named)
        do {
            audioPlayer = try AVAudioPlayer(data: (asset?.data)!, fileTypeHint: "mp3")
        } catch let error {
            print("file - audio problem \(error.localizedDescription) ")
            exit(12)
        }
        audioPlayer?.delegate = self
        audioPlayer?.prepareToPlay()
        audioPlayer?.play()
    }
}

