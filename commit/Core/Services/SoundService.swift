import AVFoundation

/// Manages custom sound playback throughout the app
final class SoundService {
    static let shared = SoundService()
    
    private var audioPlayer: AVAudioPlayer?
    
    private init() {
        configureAudioSession()
    }
    
    // MARK: - Audio Session Configuration
    
    private func configureAudioSession() {
        do {
            // Configure audio session to play even in silent mode (optional)
            // Remove this if you want sounds to respect silent mode
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
    
    // MARK: - Play Custom Sound
    
    func playCompletionGong() {
        guard let url = Bundle.main.url(forResource: "smallgong", withExtension: "mp3") else {
            print("Could not find small gong.mp3 in bundle")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.volume = 0.4 // Adjust volume (0.0 to 1.0)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Failed to play sound: \(error)")
        }
    }
    
    // MARK: - Stop Sound
    
    func stopSound() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
}
