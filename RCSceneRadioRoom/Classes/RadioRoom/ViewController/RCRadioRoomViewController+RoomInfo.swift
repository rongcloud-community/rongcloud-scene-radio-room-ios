//
//  RCRadioRoomViewController+RoomInfo.swift
//  RCE
//
//  Created by shaoshuai on 2021/8/11.
//

extension RCRadioRoomViewController {
    @_dynamicReplacement(for: m_viewDidLoad)
    private func roomInfo_viewDidLoad() {
        m_viewDidLoad()
        roomInfoView.delegate = self
        fetchRoomStatus()
    }
    
    @_dynamicReplacement(for: handleReceivedMessage(_:))
    private func roomInfo_handleReceivedMessage(_ message :RCMessage) {
        handleReceivedMessage(message)
        guard let content = message.content else { return }
        if content.isKind(of: RCChatroomEnter.self) || content.isKind(of: RCChatroomLeave.self) {
            roomInfoView.updateRoomUserNumber()
        }
    }
    
    func fetchRoomStatus() {
        radioRoomService.roomInfo(roomId: roomInfo.roomId) { [weak self] result in
            switch result.map(RCSceneWrapper<RCSceneRoom>.self) {
            case let .success(model):
                if model.data?.stop == true {
                    self?.roomDidSuspend()
                }
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }
}

extension RCRadioRoomViewController: RoomInfoViewClickProtocol {
    func roomInfoDidClick() {
        radioRouter.trigger(.userList(room: roomInfo, delegate: self))
    }
    
    func didFollowRoomUser(_ follow: Bool) {
        RCSceneUserManager.shared.refreshUserInfo(userId: roomInfo.userId) { followUser in
            guard follow else { return }
            RCSceneUserManager.shared.fetchUserInfo(userId: Environment.currentUserId) { [weak self] user in
                let message = RCChatroomFollow()
                message.userInfo = user.rcUser
                message.targetUserInfo = followUser.rcUser
                ChatroomSendMessage(message, messageView: self?.messageView)
            }
        }
    }
}

