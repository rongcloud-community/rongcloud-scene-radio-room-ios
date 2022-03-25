//
//  SystemMessageHandler.swift
//  RCE
//
//  Created by xuefeng on 2022/1/24.
//

import Foundation
import SVProgressHUD
import RCSceneMessage

class ShuMeiMessageHandler: RoomMessageHandlerProtocol {
    static func handleMessage(message: RCMessage, object: AnyObject?) {
        guard message.objectName == ShuMeiMessageHandlerName,
              let shumeiMessage = message.content as? RCShuMeiMessage,
              let content = shumeiMessage.content else {
            print("System Message Data invalid <ShuMei>")
            return
        }
        
        if (content.status == 2) {
            UserDefaults.standard.clearLoginStatus()
            RCCoreClient.shared().disconnect(true)
            DispatchQueue.main.async {
                NotificationNameShuMeiKickOut.post()
            }
        }
        
        if (content.message != nil) {
            let time = DispatchTime.now() + 1.5
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                SVProgressHUD.setMinimumDismissTimeInterval(5)
                SVProgressHUD.setMaximumDismissTimeInterval(5)
                SVProgressHUD.showError(withStatus: content.message)
            })
            let reset = DispatchTime.now() + 6.5
            DispatchQueue.main.asyncAfter(deadline: reset, execute: {
                SVProgressHUD.setMinimumDismissTimeInterval(2)
                SVProgressHUD.setMaximumDismissTimeInterval(2)
            })
        }
    }
}
