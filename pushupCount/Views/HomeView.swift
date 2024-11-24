import SwiftUI
import CoreMotion

struct HomeView: View {
    @StateObject private var viewModel = PushUpCountViewModel()
    @State private var airPodsModelName: String = "AirPods Pro (Mock)"
    @State private var animateOpacity: Bool = false
    @State private var homeState: HomeViewState = .notConnected

    enum HomeViewState {
        case notConnected      // AirPods가 연결되지 않은 상태
        case connected         // AirPods가 연결된 상태, 애니메이션 중
        case readyForCount     // Push-Up 카운트를 위한 상태
    }

    var body: some View {
        VStack {
            switch homeState {
            case .notConnected:
                notConnectedView
            case .connected:
                connectedView
                    .onAppear {
                        withAnimation(Animation.easeIn(duration: 2.0)) {
                            // 일정 시간 후에 readyForCount 상태로 전환
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                homeState = .readyForCount
                            }
                        }
                    }
            case .readyForCount:
                readyForCountView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            viewModel.startSession()
        }
        .onDisappear {
            viewModel.stopSession()
        }
    }
}

extension HomeView {
    // AirPods가 연결되지 않았을 때 보여주는 뷰
    private var notConnectedView: some View {
        VStack {
            Text("AirPods가 연결되지 않았습니다.")
                .font(.title)
                .foregroundColor(.red)
                .padding()
            Image(systemName: "airpodspro")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150, height: 150)
                .opacity(animateOpacity ? 1.0 : 0.5)
                .onAppear {
                    withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                        animateOpacity = true
                    }
                }
            
            // AirPods 탐색 버튼 추가
            Button(action: {
                checkAirPodsConnection()
            }) {
                Text("AirPods 탐색하기")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
    }

    // AirPods가 연결된 후 보여주는 뷰 (애니메이션 혹은 모델명)
    private var connectedView: some View {
        VStack {
            Text("AirPods가 연결되었습니다: \(airPodsModelName)")
                .font(.title)
                .foregroundColor(.green)
                .padding()

            // AirPods 이미지 보여주기 (예: 모델의 3D 이미지나 실감나는 이미지)
            Image("airpods_4_large_2x") // 이미지 이름 수정
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
                .padding()
                .opacity(animateOpacity ? 1.0 : 0.0)
                .onAppear {
                    withAnimation(.easeIn(duration: 1.0)) {
                        animateOpacity = true
                    }
                }
        }
    }

    // Push-Up 카운트가 가능한 상태에서 보여주는 뷰
    private var readyForCountView: some View {
        VStack {
            if let motionData = viewModel.motionData {
                PushUpCountView(pushUpCount: viewModel.pushUpCount, motionData: motionData)
            } else {
                Text("모션 데이터를 가져오는 중...")
                    .font(.subheadline)
                    .padding()
            }
        }
    }

    // AirPods 연결 여부 확인 및 상태 업데이트
    private func checkAirPodsConnection() {
        if viewModel.isAirPodsConnected {
            homeState = .connected
        } else {
            homeState = .notConnected
        }
    }
}
