//
//  RoomSeatInfoExtra.swift
//  RCE
//
//  Created by hanxiaoqing on 2022/1/25.
//

import Foundation

struct RoomSeatInfoExtra: Codable {
    let disableRecording: Bool
    func toJsonString () -> String? {
        do {
            let jsonData = try JSONEncoder().encode(self)
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                return nil
            }
            return jsonString
        } catch {
            print(error)
            return nil
        }
    }
}
