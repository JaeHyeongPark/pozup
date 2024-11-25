import AVFoundation
import Combine
import CoreMotion
import Foundation

class PushUpCountViewModel: ObservableObject {
    @Published var isAirPodsConnected: Bool = false
    @Published var airPodsModelName: String? // AirPods 모델명을 저장하는 변수 추가
    @Published var motionData: CMDeviceMotion?
    @Published var pushUpCount: Int = 0

    private var audioSessionManager = AudioSessionManager()
    private var motionManager = HeadphoneMotionManager()
    private var audioPlayer: AVPlayer?

    init() {
        audioSessionManager.$isAirPodsConnected
            .receive(on: RunLoop.main)
            .assign(to: &$isAirPodsConnected)
        
        audioSessionManager.$airPodsModelName
            .receive(on: RunLoop.main)
            .assign(to: &$airPodsModelName) // 모델명 전달

        motionManager.$motionData
            .receive(on: RunLoop.main)
            .assign(to: &$motionData)

        motionManager.setPushUpHandler { [weak self] movingUp, _, _ in
            if movingUp {
                self?.pushUpCount += 1
            }
        }
    }

    func startSession() {
        audioSessionManager.startObserving()
        motionManager.startMotionUpdates()
    }

    func stopSession() {
        audioSessionManager.stopObserving()
        motionManager.stopMotionUpdates()
    }

    //TODO: 더미오디오 재생으로 airpods 이동(mac->iphone) 유도
    // AVAudioSessionClient_Common.mm:574   Failed to set properties, error: -50 에러메세지 printout
    func startPlaybackToPromptAirPodsConnection() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [.allowBluetoothA2DP, .mixWithOthers])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch let error as NSError {
            print("오디오 세션 설정 오류: \(error.localizedDescription), Error Code: \(error.code)")
            return
        }

        guard let audioURL = Bundle.main.url(forResource: "dummyAudio2", withExtension: "mp3") else {
            print("오디오 파일을 찾을 수 없습니다.")
            return
        }
        
        audioPlayer = AVPlayer(url: audioURL)
        audioPlayer?.play()
    }


}
