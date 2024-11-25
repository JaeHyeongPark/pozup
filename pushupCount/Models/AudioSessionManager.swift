import AVFoundation
import Combine

class AudioSessionManager: ObservableObject {
    @Published var isAirPodsConnected: Bool = false
    @Published var airPodsModelName: String?

    private var audioSession = AVAudioSession.sharedInstance()
    
    init() {
        checkAirPodsConnection()
    }

    func startObserving() {
        NotificationCenter.default.addObserver(self, selector: #selector(audioRouteChanged), name: AVAudioSession.routeChangeNotification, object: nil)
    }

    func stopObserving() {
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.routeChangeNotification, object: nil)
    }

    @objc private func audioRouteChanged(notification: Notification) {
        checkAirPodsConnection()
    }

    private func checkAirPodsConnection() {
        if let output = audioSession.currentRoute.outputs.first(where: { 
            $0.portType == .bluetoothA2DP ||
            $0.portType == .bluetoothLE ||
            $0.portType == .bluetoothHFP &&
            $0.portName.contains("AirPods")
        }) {
            isAirPodsConnected = true
            airPodsModelName = output.portName // AirPods 모델명을 저장
        } else {
            isAirPodsConnected = false
            airPodsModelName = nil
        }
    }
}
