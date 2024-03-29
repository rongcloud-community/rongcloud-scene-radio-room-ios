//
//  RCRadioRoomViewController+Broadcast.swift
//  RCE
//
//  Created by shaoshuai on 2021/8/20.
//

import UIKit

extension RCRadioRoomViewController {
    @_dynamicReplacement(for: m_viewDidLoad)
    private func broadcast_viewDidLoad() {
        m_viewDidLoad()
        RCBroadcastManager.shared.delegate = self
    }
    
    @_dynamicReplacement(for: handleReceivedMessage(_:))
    private func broadcast_handleReceivedMessage(_ message :RCMessage) {
        handleReceivedMessage(message)
        guard let content = message.content as? RCGiftBroadcastMessage else { return }
        RCBroadcastManager.shared.add(content)
    }
}

extension RCRadioRoomViewController: RCRTCBroadcastDelegate {
    func broadcastViewDidLoad(_ view: RCRTCGiftBroadcastView) {
        self.view.addSubview(view)
        view.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(roomInfoView.snp.bottom).offset(8)
            make.height.equalTo(30)
        }
    }
    
    func broadcastViewAccessible(_ room: RCSceneRoom) -> Bool {
        return room.roomId != roomInfo.roomId && roomInfo.userId != Environment.currentUserId
    }
    
    func broadcastViewDidClick(_ room: RCSceneRoom) {
        if room.roomId == roomInfo.roomId { return }
        if room.isPrivate == 1 {
            radioRouter.trigger(.inputPassword({ [weak self] password in
                guard password == room.password else { return }
                self?.roomContainerAction?.switchRoom(room)
            }))
        } else {
            roomContainerAction?.switchRoom(room)
        }
    }
}
