// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
//  Generated file. Do not edit.
//

import PackageDescription

let package = Package(
    name: "FlutterGeneratedPluginSwiftPackage",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "FlutterGeneratedPluginSwiftPackage", type: .static, targets: ["FlutterGeneratedPluginSwiftPackage"])
    ],
    dependencies: [
        .package(name: "camera_avfoundation", path: "/Users/hemming/.pub-cache/hosted/pub.flutter-io.cn/camera_avfoundation-0.9.20+1/ios/camera_avfoundation"),
        .package(name: "image_picker_ios", path: "/Users/hemming/.pub-cache/hosted/pub.flutter-io.cn/image_picker_ios-0.8.12+2/ios/image_picker_ios"),
        .package(name: "in_app_purchase_storekit", path: "/Users/hemming/.pub-cache/hosted/pub.flutter-io.cn/in_app_purchase_storekit-0.4.2/darwin/in_app_purchase_storekit"),
        .package(name: "path_provider_foundation", path: "/Users/hemming/.pub-cache/hosted/pub.flutter-io.cn/path_provider_foundation-2.4.1/darwin/path_provider_foundation"),
        .package(name: "shared_preferences_foundation", path: "/Users/hemming/.pub-cache/hosted/pub.flutter-io.cn/shared_preferences_foundation-2.5.4/darwin/shared_preferences_foundation")
    ],
    targets: [
        .target(
            name: "FlutterGeneratedPluginSwiftPackage",
            dependencies: [
                .product(name: "camera-avfoundation", package: "camera_avfoundation"),
                .product(name: "image-picker-ios", package: "image_picker_ios"),
                .product(name: "in-app-purchase-storekit", package: "in_app_purchase_storekit"),
                .product(name: "path-provider-foundation", package: "path_provider_foundation"),
                .product(name: "shared-preferences-foundation", package: "shared_preferences_foundation")
            ]
        )
    ]
)
