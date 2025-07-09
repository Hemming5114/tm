import Flutter
import UIKit
import Photos

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
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
      
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
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
