import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseMessaging
import GoogleMaps
import GooglePlaces
import GoogleSignIn
import UIKit
import UserNotifications
import FacebookCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    var window: UIWindow?
    
    // MARK: - Application Lifecycle
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Firebase Initialization
        FirebaseApp.configure()
        
        // Firebase Messaging Delegate
        Messaging.messaging().delegate = self
        Messaging.messaging().isAutoInitEnabled = true
        
        // Google Maps and Places API Initialization
        GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
        GMSPlacesClient.provideAPIKey("YOUR_GOOGLE_PLACES_API_KEY")
        
        // Facebook SDK Initialization
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Request Notification Authorization
        requestNotificationAuthorization(application)
        
        // Set Initial ViewController
        setInitialViewController()
        
        return true
    }
    
    // MARK: - Set Initial ViewController
    private func setInitialViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
            let navController = UINavigationController(rootViewController: loginVC)
            navController.navigationBar.isHidden = true
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.rootViewController = navController
            window?.makeKeyAndVisible()
        } else {
            print("Error: Unable to load LoginViewController")
        }
    }
    
    // MARK: - Navigation to HomeController
    func gotoHomeController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController {
            let navController = UINavigationController(rootViewController: homeVC)
            navController.navigationBar.isHidden = false
            window?.rootViewController = navController
            window?.makeKeyAndVisible()
        } else {
            print("Error: Unable to load HomeViewController")
        }
    }
    
    // MARK: - Push Notification Configuration
    private func requestNotificationAuthorization(_ application: UIApplication) {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self
        notificationCenter.requestAuthorization(options: authOptions) { granted, error in
            if granted {
                print("Notification authorization granted")
            } else if let error = error {
                print("Notification authorization denied: \(error.localizedDescription)")
            }
        }
        application.registerForRemoteNotifications()
    }
    
    // MARK: - Firebase Messaging
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
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let token = fcmToken {
            print("Firebase Messaging Registration Token: \(token)")
            UserDefaultsManager.shared.device_token = token
        }
    }
    
    // MARK: - Facebook Login Handling
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        // Handle Facebook Login
        if ApplicationDelegate.shared.application(app, open: url, sourceApplication: options[.sourceApplication] as? String, annotation: options[.annotation]) {
            return true
        }
        
        // Handle Google Sign-In
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    // MARK: - Notification Handling
    func application(_ application: UIApplication, didReceiveRemoteNotification notification: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if Auth.auth().canHandleNotification(notification) {
            completionHandler(.noData)
        } else {
            // Handle other notifications
            completionHandler(.newData)
        }
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
    
    // MARK: - UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Handle any resources specific to discarded scenes if needed
    }
}

//import FirebaseAuth
//import FirebaseCore
//import FirebaseFirestore
//import FirebaseMessaging
//import GoogleMaps
//import GooglePlaces
//import GoogleSignIn
//import UIKit
//import UserNotifications
//import AVFoundation
//import FacebookCore
//
//@main
//class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
//    
//    var window: UIWindow?
//    
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        #if DEBUG
//        Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/iOSInjection.bundle")?.load()
//        #endif
//        
//        // Configure Firebase
//        FirebaseApp.configure()
//        
//        // Configure Firebase Messaging Delegate
//        Messaging.messaging().delegate = self
//        Messaging.messaging().isAutoInitEnabled = true
//        
//        // Configure Google Maps and Places
//        GMSServices.provideAPIKey(GeocodingService.shared.googleMapsAPIKey)
//        GMSPlacesClient.provideAPIKey(GeocodingService.shared.googleMapsAPIKey)
//        
//        // Configure Facebook SDK
//        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
//        
//        // Set up Notification Permissions
//        requestNotificationAuthorization(application)
//        
//        // Configure AVAudioSession
//        configureAudioSession()
//        
//        return true
//    }
//    
//    private func requestNotificationAuthorization(_ application: UIApplication) {
//        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
//        UNUserNotificationCenter.current().delegate = self
//        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
//            if granted {
//                print("Notification authorization granted")
//            } else {
//                print("Notification authorization denied: \(String(describing: error))")
//            }
//        }
//        application.registerForRemoteNotifications()
//    }
//    
//    private func configureAudioSession() {
//        do {
//            try AVAudioSession.sharedInstance().setCategory(.playback)
//        } catch {
//            print("Failed to set AVAudioSession category: \(error)")
//        }
//    }
//    
//    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        Messaging.messaging().apnsToken = deviceToken
//        Messaging.messaging().token { token, error in
//            if let error = error {
//                print("Error fetching Firebase Messaging token: \(error.localizedDescription)")
//            } else if let token = token {
//                print("Firebase Messaging token: \(token)")
//                UserDefaultsManager.shared.device_token = token
//            }
//        }
//    }
//    
//    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
//        // Handle Facebook Login
//        if ApplicationDelegate.shared.application(app, open: url, sourceApplication: options[.sourceApplication] as? String, annotation: options[.annotation]) {
//            return true
//        }
//        
//        // Handle Google Sign-In
//        return GIDSignIn.sharedInstance.handle(url)
//    }
//
//    func presentLogin() {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let loginVC = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
//        let navController = UINavigationController(rootViewController: loginVC)
//        navController.navigationBar.isHidden = true
//        navController.modalPresentationStyle = .fullScreen
//        
//        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//              let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) else { return }
//        
//        keyWindow.rootViewController = navController
//        keyWindow.makeKeyAndVisible()
//    }
//
//    func application(_ application: UIApplication,
//                     didReceiveRemoteNotification notification: [AnyHashable: Any],
//                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        if Auth.auth().canHandleNotification(notification) {
//            completionHandler(.noData)
//            return
//        }
//        // Handle other remote notifications
//    }
//    
//    func applicationWillEnterForeground(_ application: UIApplication) {
//        resetBadgeCount()
//    }
//    
//    func applicationDidBecomeActive(_ application: UIApplication) {
//        resetBadgeCount()
//    }
//    
//    private func resetBadgeCount() {
//        UIApplication.shared.applicationIconBadgeNumber = 0
//    }
//    
//    // MARK: UISceneSession Lifecycle
//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
//    }
//    
//    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
//}
