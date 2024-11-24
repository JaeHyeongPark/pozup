import CoreMotion
import Combine

class HeadphoneMotionManager: ObservableObject {
    @Published var motionData: CMDeviceMotion?
    private var motionManager = CMHeadphoneMotionManager()
    private var pushUpHandler: ((Bool, Bool, Double) -> Void)?
    
    private var wasMovingDown = false
    private var lastAcceleration: Double = 0.0
    private var lastDotProduct: Double = 0.0
    private var lastStateChangeTime: Date?
    private var lastRotationUnstableTime: Date?

    // Push-Up 동작을 인식하기 위한 임계값들
    private let upwardThreshold: Double = -0.1
    private let downwardThreshold: Double = 0.1
    private let dotProductChangeRateThreshold: Double = 0.5 // Dot Product 변화율 임계값
    private let rotationStabilityTimeout: TimeInterval = 1.0 // 회전 불안정 이후 안정화 타임아웃 (1초)

    func startMotionUpdates() {
        guard motionManager.isDeviceMotionAvailable else {
            print("헤드폰 모션 데이터 사용 불가.")
            return
        }

        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (motion, error) in
            if let error = error {
                print("모션 업데이트 오류: \(error.localizedDescription)")
                return
            }
            if let motion = motion {
                DispatchQueue.main.async {
                    self?.motionData = motion
                    self?.detectPushUpMovement(motionData: motion)
                }
            }
        }
    }

    func stopMotionUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }

    func setPushUpHandler(_ handler: @escaping (Bool, Bool, Double) -> Void) {
        self.pushUpHandler = handler
    }

    private func detectPushUpMovement(motionData: CMDeviceMotion) {
        let gravity = motionData.gravity
        let userAcceleration = motionData.userAcceleration
        let rotationRate = motionData.rotationRate

        // 벡터 내적 계산을 통해 중력 방향 및 반대 방향으로의 움직임을 감지
        let dotProduct = (gravity.x * userAcceleration.x) +
                         (gravity.y * userAcceleration.y) +
                         (gravity.z * userAcceleration.z)

        // 현재 가속도 계산
        let currentAcceleration = sqrt(pow(userAcceleration.x, 2) + pow(userAcceleration.y, 2) + pow(userAcceleration.z, 2))
        
        // 개선: lastAcceleration 갱신을 직전 값과 비교 후 수행
        if abs(currentAcceleration - lastAcceleration) > 0.1 { // 일정 수준 이상의 변화가 있을 때만 갱신
            lastAcceleration = currentAcceleration
        }

        // dotProduct 변화 속도 확인
        let dotProductChangeRate = abs(dotProduct - lastDotProduct)
        lastDotProduct = dotProduct

        // 회전 안정성 확인 (빠른 머리 움직임 감지)
        let isRotationStable = abs(rotationRate.x) < 1.2 && abs(rotationRate.y) < 1.2 && abs(rotationRate.z) < 1.2

        if !isRotationStable {
            lastRotationUnstableTime = Date()
        }

        let isAfterRotationStabilityTimeout: Bool
        if let lastUnstableTime = lastRotationUnstableTime {
            isAfterRotationStabilityTimeout = Date().timeIntervalSince(lastUnstableTime) > rotationStabilityTimeout
        } else {
            isAfterRotationStabilityTimeout = true
        }

        let isAccelerationStable = currentAcceleration < 1.5

        let isDotProductChangeAcceptable = dotProductChangeRate < dotProductChangeRateThreshold

        if isDotProductChangeAcceptable && isRotationStable && isAccelerationStable && isAfterRotationStabilityTimeout {
            let movingDown = dotProduct > downwardThreshold
            let movingUp = dotProduct < upwardThreshold

            if movingDown && !wasMovingDown {
                if let lastChangeTime = lastStateChangeTime {
                    let elapsedTime = Date().timeIntervalSince(lastChangeTime)
                    if elapsedTime > 0.2 {
                        wasMovingDown = true
                        lastStateChangeTime = Date()
                    }
                } else {
                    lastStateChangeTime = Date()
                }
            } else if movingUp && wasMovingDown {
                if let lastChangeTime = lastStateChangeTime {
                    let elapsedTime = Date().timeIntervalSince(lastChangeTime)
                    if elapsedTime > 0.2 {
                        wasMovingDown = false
                        pushUpHandler?(true, false, dotProduct)
                        lastStateChangeTime = Date()
                    }
                } else {
                    lastStateChangeTime = Date()
                }
            } else {
                pushUpHandler?(false, movingDown, dotProduct)
            }
        } else {
            pushUpHandler?(false, false, dotProduct)
        }
    }
}
