//
//  RCRadioRoomViewController+Setting.swift
//  RCE
//
//  Created by shaoshuai on 2021/8/12.
//

import SVProgressHUD
import RCSceneRoom

extension RCRadioRoomViewController {
    @_dynamicReplacement(for: m_viewDidLoad)
    private func setting_viewDidLoad() {
        m_viewDidLoad()
    }
    
    @objc func handleSettingClick() {
        let notice = roomKVState.notice.count == 0
        ? "欢迎来到\(roomKVState.roomName)"
        : roomKVState.notice
        var items: [Item] {
            return [
                .roomLock(roomInfo.isPrivate == 0),
                .roomName(roomInfo.roomName),
                .roomNotice(notice),
                .roomBackground,
                .forbidden([]),
                .music,
                .roomSuspend(!roomKVState.suspend)
            ]
        }
        let controller = RCSRSettingViewController(items: items, delegate: self)
        controller.modalTransitionStyle = .crossDissolve
        controller.modalPresentationStyle = .overFullScreen
        present(controller, animated: true)
    }
}

extension RCRadioRoomViewController: RCSceneRoomSettingProtocol {
    func eventWillTrigger(_ item: Item) -> Bool {
        RCSensorAction.settingClick(roomInfo, item: item).trigger()
        switch item {
        case .forbidden:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.forbiddenDidClick()
            }
            return true
        default: return false
        }
    }
    
    func eventDidTrigger(_ item: Item, extra: String?) {
        switch item {
        case .roomLock(let lock):
            setRoomType(isPrivate: lock, password: extra)
        case .roomName(let name):
            roomUpdate(name: name)
        case .roomNotice(let notice):
            noticeDidModified(notice: notice)
        case .roomBackground:
            modifyRoomBackgroundDidClick()
        case .music:
            musicDidClick()
        case .roomSuspend:
            suspend()
        default: ()
        }
    }
}

//MARK: - Voice Room Setting Delegate
extension RCRadioRoomViewController {
    /// 房间密码
    private func setRoomType(isPrivate: Bool, password: String?) {
        let title = isPrivate ? "设置房间密码" : "解锁"
        func onSuccess() {
            SVProgressHUD.showSuccess(withStatus: "已\(title)")
            roomInfo.isPrivate = isPrivate ? 1 : 0
        }
        func onError() {
            SVProgressHUD.showError(withStatus: title + "失败")
        }
        radioRoomService.setRoomType(roomId: roomInfo.roomId, isPrivate: isPrivate, password: password) { result in
            switch result.map(RCSceneResponse.self) {
            case let .success(response):
                if response.validate() {
                    onSuccess()
                } else {
                    onError()
                }
            case .failure: onError()
            }
        }
    }
    /// 房间名称
    func roomUpdate(name: String) {
        radioRoomService.setRoomName(roomId: roomInfo.roomId, name: name) { result in
            switch result.map(RCSceneResponse.self) {
            case let .success(response):
                if response.validate() {
                    SVProgressHUD.showSuccess(withStatus: "更新房间名称成功")
                    self.roomKVState.update(roomName: name)
                } else {
                    SVProgressHUD.showError(withStatus: response.msg ?? "更新房间名称失败")
                }
            case .failure:
                SVProgressHUD.showError(withStatus: "更新房间名称失败")
            }
        }
    }
    /// 房间背景
    func modifyRoomBackgroundDidClick() {
        radioRouter.trigger(.changeBackground(imageList: SceneRoomManager.shared.backgrounds, delegate: self))
    }
    /// 音乐
    func musicDidClick() {
        RCMusicEngine.shareInstance().show(in: self, completion: nil)
    }
    /// 屏蔽词
    func forbiddenDidClick() {
        radioRouter.trigger(.forbiddenList(roomId: roomInfo.roomId))
    }
}

extension RCRadioRoomViewController: ChangeBackgroundImageProtocol {
    func didConfirmImage(urlSuffix: String) {
        roomKVState.update(roomBGName: urlSuffix)
        NotificationNameRoomBackgroundUpdated.post((roomInfo.roomId, urlSuffix))
        radioRoomService.updateRoomBackground(roomId: roomInfo.roomId, backgroundUrl: urlSuffix) { result in
            switch result.map(RCSceneResponse.self) {
            case let .success(response):
                if response.validate() {
                    SVProgressHUD.showSuccess(withStatus: "更新房间背景成功")
                } else {
                    SVProgressHUD.showError(withStatus: "更新房间背景失败")
                }
            case .failure:
                SVProgressHUD.showError(withStatus: "更新房间背景失败")
            }
        }
    }
}
