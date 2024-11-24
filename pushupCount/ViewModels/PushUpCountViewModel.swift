import Combine
import CoreMotion
import Foundation

class PushUpCountViewModel: ObservableObject {
    @Published var isAirPodsConnected: Bool = false
    @Published var motionData: CMDeviceMotion?
    @Published var pushUpCount: Int = 0

    private var audioSessionManager = AudioSessionManager()
    private var motionManager = HeadphoneMotionManager()

    init() {
        audioSessionManager.$isAirPodsConnected
            .receive(on: RunLoop.main)
            .assign(to: &$isAirPodsConnected)
        
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
}
