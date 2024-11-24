import AVFoundation
import Combine

class AudioSessionManager: ObservableObject {
    @Published var isAirPodsConnected: Bool = false
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
        isAirPodsConnected = audioSession.currentRoute.outputs.contains { output in
            output.portType == .bluetoothA2DP ||
            output.portType == .bluetoothLE ||
            output.portType == .bluetoothHFP &&
            output.portName.contains("AirPods")
        }
    }
}
