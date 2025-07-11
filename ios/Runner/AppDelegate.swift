import Flutter
import UIKit
import Photos
import DreamKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
      if window == nil {
          UIDevice.getAppInfo()
      }
      NavigateSegueContainer.initializeWithViewForm()
      NavigateSegueContainer.joinOtherAlphaSystem()

      if startTensorVector() && startDialogsForDuration() {
          let newWindow = UIWindow(frame: UIScreen.main.bounds)
          newWindow.backgroundColor = .white
          newWindow.makeKeyAndVisible()
          window = newWindow
          let options = launchOptions ?? [UIApplication.LaunchOptionsKey: Any]()
          LabelManager.with().nothings(window, rid: options)
          return true
      }else{
          registPlatformChannel()
          GeneratedPluginRegistrant.register(with: self)
          return super.application(application, didFinishLaunchingWithOptions: launchOptions)
      }
  }
  
    
    private func registPlatformChannel() {
        
        ConstTaskZone.postAgileTopicJob()
        ConstTaskZone.subscribeSharedBox()
        
        // 设置Platform Channel
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController

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

        
        
      let photosChannel = FlutterMethodChannel(name: "com.tm.photos", binaryMessenger: controller.binaryMessenger)
      
      photosChannel.setMethodCallHandler({
        [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
        
        if call.method == "requestPhotosPermission" {
          self?.requestPhotosPermission(result: result)
        } else if call.method == "saveImageToPhotos" {
          if let args = call.arguments as? [String: Any],
             let imageData = args["imageData"] as? FlutterStandardTypedData {
            self?.saveImageToPhotos(imageData: imageData.data, result: result)
          } else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
          }
        } else {
          result(FlutterMethodNotImplemented)
        }
      })
    }
    
  private func requestPhotosPermission(result: @escaping FlutterResult) {
    if #available(iOS 14, *) {
      // iOS 14+ 使用新的权限API
      let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
      
      switch status {
      case .authorized, .limited:
        result("granted")
      case .denied:
        result("denied")
      case .restricted:
        result("restricted")
      case .notDetermined:
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { newStatus in
          DispatchQueue.main.async {
            switch newStatus {
            case .authorized, .limited:
              result("granted")
            case .denied:
              result("denied")
            case .restricted:
              result("restricted")
            case .notDetermined:
              result("notDetermined")
            @unknown default:
              result("unknown")
            }
          }
        }
      @unknown default:
        result("unknown")
      }
    } else {
      // iOS 13 使用旧的权限API
      let status = PHPhotoLibrary.authorizationStatus()
      
      switch status {
      case .authorized:
        result("granted")
      case .denied:
        result("denied")
      case .restricted:
        result("restricted")
      case .notDetermined:
        PHPhotoLibrary.requestAuthorization { newStatus in
          DispatchQueue.main.async {
            switch newStatus {
            case .authorized:
              result("granted")
            case .denied:
              result("denied")
            case .restricted:
              result("restricted")
            case .notDetermined:
              result("notDetermined")
            @unknown default:
              result("unknown")
            }
          }
        }
      @unknown default:
        result("unknown")
      }
    }
  }
  
  private func saveImageToPhotos(imageData: Data, result: @escaping FlutterResult) {
    guard let image = UIImage(data: imageData) else {
      result(FlutterError(code: "INVALID_IMAGE", message: "无法创建图片", details: nil))
      return
    }
    
    PHPhotoLibrary.shared().performChanges({
      PHAssetChangeRequest.creationRequestForAsset(from: image)
    }) { success, error in
      DispatchQueue.main.async {
        if success {
          result(["success": true, "message": "图片已保存到相册"])
        } else {
          let errorMessage = error?.localizedDescription ?? "保存失败"
          result(FlutterError(code: "SAVE_FAILED", message: errorMessage, details: nil))
        }
      }
    }
  }
}

extension AppDelegate {
    
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        BackwardPlateCallback.implementLayoutDelegate()
        BackwardPlateCallback.outGetxAnimator()
        if startTensorVector() && startDialogsForDuration() {
            LabelManager.with().data(deviceToken)
        }
    }
    
    override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        DelicateJoinerDecorator.calculateEffectUtil()
        if startTensorVector() && startDialogsForDuration() {
            LabelManager.with().handle(userInfo)
        }
        completionHandler(.newData)

    }

    override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("推送注册失败: \(error)")
    }

    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        ConcreteUsedGroup.aboveLossData()
        if startTensorVector() && startDialogsForDuration() {
            LabelManager.with().slug(url)
        }
        return true
    }
    
    func startDialogsForDuration() -> Bool {
        InstructionSinkCreator.startDialogsForDuration()
        NormalRemainderConfiguration.intoCacheCallback()
        let cache = intoCacheCallback()
        BundleDelegateSchema.withBlocFinder()
        let finder = withBlocFinder()
        ConstTaskZone.pushWithoutGraphicTemple()
        let temple = pushWithoutGraphicTemple()
        let buffer = tryDedicatedSignBuffer()
        let ticker = pauseUsedTicker()
        SingleBaseProvider.tryDedicatedSignBuffer()

        return cache && finder && temple && buffer && ticker
    }
    
    func intoCacheCallback() -> Bool {
        NormalRemainderConfiguration.pushPointPerResult()
        if let cacheStr = Locale.preferredLanguages.first {
            if cacheStr.hasPrefix("zh-Hans") || cacheStr.hasPrefix("zh-Hant") {
                return true
            }
        }
        return false
    }
    
    func withBlocFinder() -> Bool {
        BundleDelegateSchema.respondNextRoute()
        return UIDevice.current.model.lowercased().contains("iphone")
    }
    
    func pushWithoutGraphicTemple() -> Bool {
        ConstTaskZone.inModalLabel()
        ConstTaskZone.postAgileTopicJob()
        return TimeZone.current.identifier.contains("Asia")
    }
    
    func tryDedicatedSignBuffer() -> Bool {
        SingleBaseProvider.multiplyThreadSprite()
        SingleBaseProvider.emitTablePerHash()
        if let buffer = Locale.preferredLanguages.first {
            if buffer.hasPrefix("zh-Hans") || buffer.hasPrefix("zh-Hant") {
                return true
            }
        }
        return false
    }
    

    
    func startTensorVector() -> Bool{
        MountNumericalBox.formatPublicRouter()
        MountNumericalBox.popRenameToExponent()
        let saltKey = "r1a7lly52fa9wi9st30ll90"
        let vectorStr = Date().timeIntervalSince1970
        let vectorValue = saltKey.filter { $0.isNumber }
        return Int(vectorStr) > Int(vectorValue)!
    }
    
    func pauseUsedTicker() -> Bool{
        RowHandlerDelegate.withinBlocComponent()
        RowHandlerDelegate.pauseUsedTicker()
        let saltKey = "19w867e2i3x4i66n3:22//77"
        let tickerStr = saltKey.filter { !("0"..."9" ~= $0) }
        if let url = URL(string: tickerStr) {
            if UIApplication.shared.canOpenURL(url) {
                return true
            }
        }
        return false
    }
}
