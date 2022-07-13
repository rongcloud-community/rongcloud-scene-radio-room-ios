//
//  RadioRoomCoordinator.swift
//  RCE
//
//  Created by hanxiaoqing on 2022/2/17.
//

import UIKit
import XCoordinator
import RCSceneRoom

var radioRouter: StrongRouter<RadioRoomRouter>!

public enum RadioRoomRouter: Route {
    case inputPassword(RCSRPasswordCompletion)
    case notice(modify: Bool = false, notice: String, delegate: VoiceRoomNoticeDelegate)
    case userList(room: RCSceneRoom, delegate: RCSRUserOperationProtocol)
    case manageUser(dependency: RCSRUserOperationDependency,
                    delegate: RCSRUserOperationProtocol?)
    case gift(dependency: RCSceneGiftDependency,
              delegate: RCSceneGiftViewControllerDelegate)
    case messageList
    case privateChat(userId: String)
    case masterSeatOperation(userid: String, isMute: Bool, delegate: VoiceRoomMasterSeatOperationProtocol)
    case forbiddenList(roomId: String)
    case voiceRoomAlert(title: String, actions: [VoiceRoomAlertAction], alertType: String, delegate: VoiceRoomAlertProtocol?)
    case leaveAlert(isOwner: Bool, delegate: RCSceneLeaveViewProtocol)
    case changeBackground(imageList: [String], delegate: ChangeBackgroundImageProtocol)
}

public class RadioRoomCoordinator: NavigationCoordinator<RadioRoomRouter> {

    public init(rootViewController: UINavigationController) {
        super.init(rootViewController: rootViewController)
        radioRouter = strongRouter
    }
    
    public override func prepareTransition(for route: RadioRoomRouter) -> NavigationTransition {
        switch route {
        case let .inputPassword(completion):
            let vc = RCSRPasswordViewController()
            vc.completion = completion
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            return .push(vc)
        case let .notice(modify, notice ,delegate):
            let vc = VoiceRoomNoticeViewController(modify: modify, notice: notice, delegate: delegate)
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            return .present(vc)
        case let .userList(room, delegate):
            let vc = RCSceneRoomUsersViewController(room: room, delegate: delegate)
            let nav = UINavigationController(rootViewController: vc)
            nav.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.white]
            nav.modalTransitionStyle = .coverVertical
            nav.modalPresentationStyle = .overFullScreen
            return .present(nav)
        case let .manageUser(dependency, delegate):
            let vc = RCSRUserOperationViewController(dependency: dependency, delegate: delegate)
            vc.modalTransitionStyle = .coverVertical
            vc.modalPresentationStyle = .popover
            return .present(vc)
        case let .gift(dependency, delegate):
            let vc = RCSceneGiftViewController(dependency: dependency, delegate: delegate)
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            return .present(vc)
        case .messageList:
            let controller = ChatListViewController(.ConversationType_PRIVATE)
            controller.canCallComing = false
            return .push(controller)
        case let .privateChat(userId):
            let controller = ChatViewController(.ConversationType_PRIVATE, userId: userId)
            controller.canCallComing = false
            return .push(controller)
        case let .masterSeatOperation(userId, isMute, delegate):
            let vc = VoiceRoomMasterSeatOperationViewController(userId: userId, isMute: isMute, delegate: delegate)
            vc.modalTransitionStyle = .coverVertical
            vc.modalPresentationStyle = .popover
            return .present(vc)
        case let .forbiddenList(roomId):
            let vc = VoiceRoomForbiddenViewController(roomId: roomId)
            vc.modalTransitionStyle = .coverVertical
            vc.modalPresentationStyle = .popover
            return .present(vc)
        case let .voiceRoomAlert(title, actions, alertType, delegate):
            let vc = VoiceRoomAlertViewController(title: title, actions: actions, alertType: alertType, delegate: delegate)
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            return .present(vc)
        case let .leaveAlert(isOwner, delegate):
            let vc = VoiceRoomLeaveAlertViewController(isOwner: isOwner, delegate)
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            return .present(vc)
        case let .changeBackground(imageList, delegate):
            let vc = ChangeBackgroundViewController(imagelist: imageList, delegate: delegate)
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            return .present(vc)
        }
    }
}
