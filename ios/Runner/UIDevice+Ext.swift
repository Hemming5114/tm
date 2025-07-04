//
//  UIDevice.swift
//  Runner
//
//  Created by Hemming on 2025/6/30.
//

import Foundation
import AppTrackingTransparency
import AdSupport

extension UIDevice {
    static func getDeviceIdentifier ( block: @escaping (_ str: String) -> Void ) {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                if status == .authorized {
                    block(UIDevice.getDeviceRawAdvertisingId())
                } else {
                    block("")
                }
            })
        } else {
            
            if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
                block(UIDevice.getDeviceRawAdvertisingId())
            } else {
                block("")
            }
            
            // Fallback on earlier versions
        }
    }
    
    static func getDeviceRawAdvertisingId() -> String {
        let adIdentifier =  ASIdentifierManager.shared().advertisingIdentifier
        return adIdentifier.uuidString
    }
    
}
