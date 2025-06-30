import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // 设置Platform Channel
    let controller = window?.rootViewController as! FlutterViewController
    let deviceChannel = FlutterMethodChannel(name: "com.example.tm/device", binaryMessenger: controller.binaryMessenger)
    
    deviceChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "getDeviceIdentifier" {
        UIDevice.getDeviceIdentifier { deviceId in
          DispatchQueue.main.async {
            result(deviceId)
          }
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

extension AppDelegate {
    
    override func applicationDidEnterBackground(_ application: UIApplication) {

    }
    
    override func applicationWillEnterForeground(_ application: UIApplication) {
        
    }
    
    override func applicationWillResignActive(_ application: UIApplication) {
        
    }
    
    override func applicationWillTerminate(_ application: UIApplication) {
        
    }
    
    override func applicationDidBecomeActive(_ application: UIApplication) {
        
    }
    
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        

    }
    
    override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        completionHandler(.newData)
    }
    
    override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("推送注册失败: \(error)")
    }
    
    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        return true
    }
}
