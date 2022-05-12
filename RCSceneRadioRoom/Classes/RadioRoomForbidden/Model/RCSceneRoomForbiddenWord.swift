//
//  VoiceRoomForbiddenWord.swift
//  RCE
//
//  Created by 叶孤城 on 2021/8/3.
//

import Foundation

struct RCSceneRoomForbiddenWord: Codable, Identifiable {
    let id: Int
    let name: String
    let createDt: TimeInterval
    init(id: Int, name: String, createDt: TimeInterval) {
        self.id = id
        self.name = name
        self.createDt = createDt
    }
}
