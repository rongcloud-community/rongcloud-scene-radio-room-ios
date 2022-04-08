//
//  RoomSettingView.swift
//  RCE
//
//  Created by 叶孤城 on 2021/5/6.
//

import UIKit



enum ConnectMicState {
    case request
    case waiting
    case connecting
    
    var image: UIImage? {
        switch self {
        case .request:
            return RCSCAsset.Images.connectMicStateNone.image
        case .waiting:
            return RCSCAsset.Images.connectMicStateWaiting.image
        case .connecting:
            return RCSCAsset.Images.connectMicStateConnecting.image
        }
    }
}

enum VoiceRoomPKRole {
    case inviter
    case invitee
    case audience
}

struct VoiceRoomPKInfo {
    let inviterId: String
    let inviteeId: String
    let inviterRoomId: String
    let inviteeRoomId: String
    
    func currentUserRole() -> VoiceRoomPKRole {
        if Environment.currentUserId == inviterId {
            return .inviter
        }
        if Environment.currentUserId == inviteeId {
            return .invitee
        }
        return .audience
    }
}

