//
//  RCRadioRoomViewController+Users.swift
//  RCE
//
//  Created by shaoshuai on 2021/8/11.
//

import SVProgressHUD
import RCSceneService
import RCSceneMessage
import RCSceneFoundation
import RCSceneGift

struct managersWrapper: Codable {
    let code: Int
    let data: [VoiceRoomUser]?
}

extension RCRadioRoomViewController {
    @_dynamicReplacement(for: m_viewWillAppear(_:))
    private func users_viewWillAppear(_ animated: Bool) {
        m_viewWillDisappear(animated)
        fetchmanagers()
    }
    
    @_dynamicReplacement(for: handleReceivedMessage(_:))
    private func users_handleReceivedMessage(_ message: RCMessage) {
        handleReceivedMessage(message)
        if message.content.isKind(of: RCChatroomAdmin.self) {
            return fetchmanagers()
        }
        if message.content.isKind(of: RCChatroomKickOut.self) {
            let content = message.content as! RCChatroomKickOut
            if content.targetId == Environment.currentUserId {
                on(content.userId, kickOut: content.targetId)
            }
        }
    }
    
    func fetchmanagers() {
        radioRoomService.roomManagers(roomId: roomInfo.roomId) { [weak self] result in
            switch result.map(managersWrapper.self) {
            case let .success(wrapper):
                guard let self = self else { return }
                self.managers = wrapper.data ?? []
                SceneRoomManager.shared.managers = self.managers.map { $0.userId }
                if wrapper.code == 30001 {
                    self.didCloseRoom()
                }
            case let.failure(error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func on(_ userId: String, kickOut targetId: String) {
        guard targetId == Environment.currentUserId else { return }
        if managers.contains(where: { $0.userId == userId }) {
            UserInfoDownloaded.shared.fetchUserInfo(userId: userId) { user in
                SVProgressHUD.showInfo(withStatus: "您被管理员\(user.userName)踢出房间")
            }
        } else {
            SVProgressHUD.showInfo(withStatus: "您被踢出房间")
        }
        radioLeaveRoom { _ in }
    }
}

// MARK: - Owner Click User Seat Pop view Deleagte
extension RCRadioRoomViewController: UserOperationProtocol {
    /// 踢出房间
    func kickoutRoom(userId: String) {
        let ids = [Environment.currentUserId, userId]
        UserInfoDownloaded.shared.fetch(ids) { users in
            let event = RCChatroomKickOut()
            event.userId = users[0].userId
            event.userName = users[0].userName
            event.targetId = users[1].userId
            event.targetName = users[1].userName
            ChatroomSendMessage(event, messageView: self.messageView)
        }
    }
    
    func didSetManager(userId: String, isManager: Bool) {
        fetchmanagers()
        UserInfoDownloaded.shared.fetchUserInfo(userId: userId) { user in
            let event = RCChatroomAdmin()
            event.userId = user.userId
            event.userName = user.userName
            event.isAdmin = isManager
            ChatroomSendMessage(event, messageView: self.messageView)
        }
        if isManager {
            SVProgressHUD.showSuccess(withStatus: "已设为管理员")
        } else {
            SVProgressHUD.showSuccess(withStatus: "已撤回管理员")
        }
    }
    
    func didClickedPrivateChat(userId: String) {
        if let presentedViewController = presentedViewController {
            presentedViewController.dismiss(animated: false) { [weak self] in
                guard let self = self else { return }
                self.didClickedPrivateChat(userId: userId)
            }
            return
        }
        radioRouter.trigger(.privateChat(userId: userId))
    }
    
    func didClickedSendGift(userId: String) {
        if let presentedViewController = presentedViewController {
            presentedViewController.dismiss(animated: false) { [weak self] in
                guard let self = self else { return }
                self.didClickedSendGift(userId: userId)
            }
            return
        }
        let dependency = VoiceRoomGiftDependency(room: roomInfo,
                                                 seats: [],
                                                 userIds: [userId])
        radioRouter.trigger(.gift(dependency: dependency, delegate: self))
    }
    
    func didFollow(userId: String, isFollow: Bool) {
        UserInfoDownloaded.shared.refreshUserInfo(userId: userId) { followUser in
            guard isFollow else { return }
            UserInfoDownloaded.shared.fetchUserInfo(userId: Environment.currentUserId) { [weak self] user in
                let message = RCChatroomFollow()
                message.userInfo = user.rcUser
                message.targetUserInfo = followUser.rcUser
                ChatroomSendMessage(message)
                self?.messageView.addMessage(message)
            }
        }
    }
}