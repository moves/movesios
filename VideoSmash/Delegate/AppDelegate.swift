//  AppDelegate.swift
//  VideoSmash
//
//  Created by Eclipse on 08/06/2024.
//

import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseMessaging
import GoogleMaps
import GooglePlaces
import GoogleSignIn
import UIKit
import UserNotifications
import AVFoundation

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        #if DEBUG
        Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/iOSInjection.bundle")?.load()
        #endif
        
        // Configure Firebase
        FirebaseApp.configure()
        
        // Configure Firebase Messaging Delegate
        Messaging.messaging().delegate = self
        Messaging.messaging().isAutoInitEnabled = true
        
        // Configure Google Maps and Places
        GMSServices.provideAPIKey(GeocodingService.shared.googleMapsAPIKey)
        GMSPlacesClient.provideAPIKey(GeocodingService.shared.googleMapsAPIKey)
        
        // Set up Notification Permissions
        requestNotificationAuthorization(application)
        
        // Configure AVAudioSession
        configureAudioSession()
        
        return true
    }
    
    private func requestNotificationAuthorization(_ application: UIApplication) {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
            if granted {
                print("Notification authorization granted")
            } else {
                print("Notification authorization denied: \(String(describing: error))")
            }
        }
        application.registerForRemoteNotifications()
    }
    
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
        } catch {
            print("Failed to set AVAudioSession category: \(error)")
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching Firebase Messaging token: \(error.localizedDescription)")
            } else if let token = token {
                print("Firebase Messaging token: \(token)")
                UserDefaultsManager.shared.device_token = token
            }
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }

    func application(_ application: UIApplication,
                     didReceiveRemoteNotification notification: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if Auth.auth().canHandleNotification(notification) {
            completionHandler(.noData)
            return
        }
        // Handle other remote notifications
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        resetBadgeCount()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        resetBadgeCount()
    }
    
    private func resetBadgeCount() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
    
    func presentLogin() {
        let myViewController = SignUpViewController(nibName: "SignUpViewController", bundle: nil)
        let navController = UINavigationController(rootViewController: myViewController)
        navController.navigationBar.isHidden = true
        navController.modalPresentationStyle = .overFullScreen
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) else { return }
        
        keyWindow.rootViewController?.present(navController, animated: false, completion: nil)
    }
    
    func gotoHomeController() {
        let story = UIStoryboard(name: "Main", bundle: nil)
        let vc = story.instantiateViewController(withIdentifier: "TabbarViewController") as! TabbarViewController
        let nav = UINavigationController(rootViewController: vc)
        nav.navigationBar.isHidden = true
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController = nav
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
    }
}

//
//  AppDelegate.swift
// //
//
//  Created by Eclipse on 08/06/2024.
//
//
//import FirebaseAuth
//import FirebaseCore
//import FirebaseFirestore
//import FirebaseMessaging
//import GoogleMaps
//import GooglePlaces
//import GoogleSignIn
//import UIKit
//import UserNotifications
//
//@main
//class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
//   
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        #if DEBUG
//        Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/iOSInjection.bundle")?.load()
//        #endif
//        FirebaseApp.configure()
//        Messaging.messaging().delegate = self
//        GMSServices.provideAPIKey(GeocodingService.shared.googleMapsAPIKey)
//        GMSPlacesClient.provideAPIKey(GeocodingService.shared.googleMapsAPIKey)
//
//        do {
//            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
//        } catch {
//            print("AVAudioSessionCategoryPlayback not work")
//        }
//
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
//            if granted {
//                print("Notification authorization granted")
//            } else {
//                print("Notification authorization denied")
//            }
//        }
//        self.notificationConfig(application)
//        return true
//    }
//    
//    func notificationConfig(_ application: UIApplication) {
//        UIApplication.shared.isStatusBarHidden = false
//        UIApplication.shared.statusBarStyle = .darkContent
//        
//        if #available(iOS 10.0, *) {
//            // For iOS 10 display notification (sent via APNS)
//            UNUserNotificationCenter.current().delegate = self // as? UNUserNotificationCenterDelegate
//            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
//            UNUserNotificationCenter.current().requestAuthorization(
//                options: authOptions,
//                completionHandler: { _, _ in })
//        } else {
//            let settings =
//                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
//            application.registerUserNotificationSettings(settings)
//        }
//       
//        Messaging.messaging().delegate = self
//        Messaging.messaging().isAutoInitEnabled = true
//        Messaging.messaging().subscribe(toTopic: "topicEventSlotUpdated")
//        Messaging.messaging().token { token, error in
//            if let error = error {
//                print("Error fetching remote instance ID: \(error.localizedDescription)")
//            } else if let token = token {
//                print("Token is \(token)")
//                UserDefaultsManager.shared.device_token = token
//            }
//        }
//        
//        application.registerForRemoteNotifications()
//    }
//    
//    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        Messaging.messaging().apnsToken = deviceToken as Data
//        Messaging.messaging().apnsToken = deviceToken
//        Messaging.messaging().token { token, error in
//            if let error = error {
//                print("Error fetching remote instance ID: \(error.localizedDescription)")
//            } else if let token = token {
//                print("Token is \(token)")
//                UserDefaultsManager.shared.device_token = token
//            }
//        }
//    }
//
//    // MARK: UISceneSession Lifecycle
//
//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        // Called when a new scene session is being created.
//        // Use this method to select a configuration to create the new scene with.
//        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
//    }
//
//    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
//        // Called when the user discards a scene session.
//        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
//        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
//    }
//    
//    func applicationWillEnterForeground(_ application: UIApplication) {
//        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
//        UIApplication.shared.applicationIconBadgeNumber = 0
//        // self.SignInApi()
//    }
//    
//    func applicationDidBecomeActive(_ application: UIApplication) {
//        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//        UIApplication.shared.applicationIconBadgeNumber = 0
//    }
//    
//    func application(_ app: UIApplication,
//                     open url: URL,
//                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool
//    {
//        return GIDSignIn.sharedInstance.handle(url)
//    }
//    
//    func application(_ application: UIApplication,
//                     didReceiveRemoteNotification notification: [AnyHashable: Any],
//                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
//    {
//        if Auth.auth().canHandleNotification(notification) {
//            completionHandler(.noData)
//            return
//        }
//        // This notification is not auth related; it should be handled separately.
//    }
//    
//    func presentLogin() {
//        let myViewController = SignUpViewController(nibName: "SignUpViewController", bundle: nil)
//
//        let navController = UINavigationController(rootViewController: myViewController)
//        navController.navigationBar.isHidden = true
//        navController.modalPresentationStyle = .overFullScreen
//        
//        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//              let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow })
//        else {
//            return
//        }
//        keyWindow.rootViewController?.present(navController, animated: false, completion: nil)
//    }
//    
//    func gotoHomeController() {
//        let story = UIStoryboard(name: "Main", bundle: nil)
//        let vc = story.instantiateViewController(withIdentifier: "TabbarViewController") as! TabbarViewController
//        let nav = UINavigationController(rootViewController: vc)
//        nav.navigationBar.isHidden = true
//        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
//            sceneDelegate.window?.rootViewController = nav
//        }
//    }
//    
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        completionHandler([.alert, .sound, .badge]) // Present as banner, sound, etc. while in foreground
//    }
//}
