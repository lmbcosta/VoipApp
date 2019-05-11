//
//  Audio.swift
//  VoipApp
//
//  Created by Luis  Costa on 10/05/2019.
//  Copyright © 2019 Luis  Costa. All rights reserved.
//

import Foundation
import AVFoundation

func configureAudioSession() {
    print("Configuring audio session")
    let session = AVAudioSession.sharedInstance()
    do {
        try session.setCategory(.playAndRecord, mode: .voiceChat, options: [])
    } catch (let error) {
        print("Error while configuring audio session: \(error)")
    }
}

func startAudio() {
    print("Starting audio")
}

func stopAudio() {
    print("Stopping audio")
}

