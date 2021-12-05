//
//  Notification+Extension.swift
//  SoundScape
//
//  Created by Astrid on 2021/12/5.
//

import Foundation

extension Notification.Name {
    static let playingAudioChange = Notification.Name("playingAudioChange")
    static let didItemPlayToEndTime = Notification.Name("didItemPlayToEndTime")
    static let didCurrentTimeChange = Notification.Name("didCurrentTimeChange")
    static let didStateChange = Notification.Name("didStateChange")
    static let remoteURLDidSelect = Notification.Name("remoteURLDidSelect")
    static let didItemDurationChange = Notification.Name("didItemDurationChange")
}
