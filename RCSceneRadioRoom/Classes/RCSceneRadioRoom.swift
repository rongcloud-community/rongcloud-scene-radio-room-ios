//
//  RCSceneRadioRoom.swift
//  RCSceneRadioRoom
//
//  Created by shaoshuai on 2022/2/27.
//

import UIKit
import XCoordinator
import RCSceneRoom

public func RCRadioRoomController(room: RCSceneRoom, creation: Bool = false, useThirdCdn: Bool = true) -> RCRoomCycleProtocol {
    RCSceneIMMessageRegistration()
    return RCRadioRoomViewController(room, isCreate: creation, useThirdCdn: useThirdCdn)
}

extension RCRadioRoomViewController: RCRoomCycleProtocol {
    func setRoomContainerAction(action: RCRoomContainerAction) {
        self.roomContainerAction = action
    }
    
    func setRoomFloatingAction(action: RCSceneRoomFloatingProtocol) {
        self.floatingManager = action
    }
    
    func joinRoom(_ completion: @escaping (Result<Void, RCSceneError>) -> Void) {
        self.radioJoinRoom(completion)
    }
    
    func leaveRoom(_ completion: @escaping (Result<Void, RCSceneError>) -> Void) {
        self.radioLeaveRoom(completion)
    }
    
    func descendantViews() -> [UIView] {
        return self.radioDescendantViews()
    }
}

fileprivate var isIMMessageRegister = false
fileprivate func RCSceneIMMessageRegistration() {
    if isIMMessageRegister { return }
    isIMMessageRegister = true
    RCChatroomMessageCenter.registerMessageTypes()
    RCIM.shared().registerMessageType(RCGiftBroadcastMessage.self)
    RCIM.shared().registerMessageType(RCPKGiftMessage.self)
    RCIM.shared().registerMessageType(RCPKStatusMessage.self)
}
