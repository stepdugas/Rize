//
//  AlarmAudioManager.swift
//  Rize
//
//  Created by Stephanie Dugas on 3/8/26.
//

import AVFoundation
import UIKit

class AlarmAudioManager {
    static let shared = AlarmAudioManager()
    
    private var audioPlayer: AVAudioPlayer?
    private var isPlaying = false
    
    func startAlarmSound() {
        do {
            // This is the key line — overrides silent mode
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: []
            )
            try AVAudioSession.sharedInstance().setActive(true)
            
            // Use a system sound as fallback alarm
            playBuiltInAlarm()
            
        } catch {
            print("Audio session error: \(error)")
        }
    }
    
    private func playBuiltInAlarm() {
        // Generate a simple repeating beep tone
        let duration = 30.0 // plays for 30 seconds max
        
        AudioServicesPlaySystemSound(1005) // system alarm sound
        
        // Repeat every 2 seconds for 30 seconds
        var count = 0
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { timer in
            if !self.isPlaying || count > 15 {
                timer.invalidate()
                return
            }
            AudioServicesPlaySystemSound(1005)
            count += 1
        }
        
        isPlaying = true
    }
    
    func stopAlarmSound() {
        isPlaying = false
        audioPlayer?.stop()
        try? AVAudioSession.sharedInstance().setActive(false)
    }
}
