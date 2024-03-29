//
//  RCRadioRoomViewController+Chatroom.swift
//  RCE
//
//  Created by shaoshuai on 2022/1/26.
//

import SVProgressHUD
import RCSceneChatroomKit

extension RCRadioRoomViewController {
    @_dynamicReplacement(for: m_viewDidLoad)
    private func toolBar_viewDidLoad() {
        m_viewDidLoad()
        giftButton.addTarget(self, action: #selector(handleGiftButtonClick), for: .touchUpInside)
        messageButton.addTarget(self, action: #selector(handleMessageButtonClick), for: .touchUpInside)
        settingButton.addTarget(self, action: #selector(handleSettingClick), for: .touchUpInside)
        setupToolBarView()
    }
    
    func setupToolBarView() {
        let config = RCChatroomSceneToolBarConfig.default()
        if roomInfo.isOwner {
            config.actions = [giftButton, messageButton, settingButton]
        } else {
            config.actions = [giftButton, messageButton]
        }
        config.recordButtonEnable = !roomInfo.isOwner
        chatroomView.toolBar.setConfig(config)
        chatroomView.toolBar.delegate = self
    }
    
    @objc func handleMessageButtonClick() {
        radioRouter.trigger(.messageList)
        RCSensorAction.textClick(roomInfo).trigger()
    }
}

extension RCRadioRoomViewController: RCChatroomSceneToolBarDelegate {
    func textInputViewSendText(_ text: String) {
        let roomId = roomInfo.roomId
        radioRoomService.forbiddenList(roomId: roomId) { result in
            switch result {
            case .success(let response):
                let data = response.data
                let responseModel = try? JSONDecoder().decode(RCSceneWrapper<[RCSceneRoomForbiddenWord]>.self, from: data)
                let wordlist = responseModel?.data ?? []
                let forbiddenWords = wordlist.map(\.name)
                let isCivilized = forbiddenWords.first { text.contains($0) } == nil
                
                RCSceneUserManager.shared.fetchUserInfo(userId: Environment.currentUserId) { [weak self] user in
                    let event = RCChatroomBarrage()
                    event.userId = user.userId
                    event.userName = user.userName
                    event.content = text
                    self?.chatroomView.messageView.addMessage(event)
                    if isCivilized {
                        RCChatroomMessageCenter.sendChatMessage(roomId,
                                                                content: event,
                                                                result: { _, _ in })
                    }
                }
                
            case let .failure(error):
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
        }
    }
    
    func audioRecordShouldBegin() -> Bool {
        if RCCoreClient.shared().isAudioHolding() {
            SVProgressHUD.showError(withStatus: "声音通道被占用，请下麦后使用")
            return false
        }
        return true
    }
    
    func audioRecordDidEnd(_ data: Data?, time: TimeInterval) {
        guard let data = data, time > 1 else { return SVProgressHUD.showError(withStatus: "录音时间太短") }
        radioRoomService.uploadAudio(data: data, extensions: "wav") { [weak self] result in
            switch result.map(RCSceneWrapper<String>.self) {
            case let .success(response):
                guard let path = response.data else {
                    return SVProgressHUD.showError(withStatus: "文件上传失败")
                }
                let urlString = Environment.url.absoluteString + "/file/show?path=" + path
                self?.sendMessage(urlString, time: Int(time) + 1)
            case let .failure(error):
                print(error)
            }
        }
    }
    
    private func sendMessage(_ URLString: String, time: Int) {
        RCSceneUserManager.shared.fetchUserInfo(userId: Environment.currentUserId) { user in
            let message = RCVRVoiceMessage()
            message.userId = user.userId
            message.userName = user.userName
            message.path = URLString
            message.duration = UInt(time)
            ChatroomSendMessage(message, messageView: self.messageView)
        }
    }
    
}

