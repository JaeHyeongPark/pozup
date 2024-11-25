import SwiftUI
import CoreMotion

struct HomeView: View {
    @StateObject private var viewModel = PushUpCountViewModel()
    @State private var animateOpacity: Bool = false
    @State private var homeState: HomeViewState = .notConnected

    enum HomeViewState {
        case notConnected      // AirPods가 연결되지 않은 상태
        case connected         // AirPods가 연결된 상태, 애니메이션 중
        case readyForCount     // Push-Up 카운트를 위한 상태
    }

    var body: some View {
        VStack {
            headerBox

            Spacer()

            mainContentView
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGray6)) // 배경색을 추가하여 전체적인 톤을 부드럽게 만듭니다.
        .onAppear {
            viewModel.startSession()
        }
        .onDisappear {
            viewModel.stopSession()
        }
    }
}

// MARK: - Subviews
extension HomeView {
    // 상단 헤더 박스를 구현하는 부분
    private var headerBox: some View {
        HStack {
            Text(viewModel.isAirPodsConnected ? (viewModel.airPodsModelName ?? "AirPods") : "AirPods 상태")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.leading)

            Spacer()

            // AirPods 탐색 버튼
            Button(action: {
                checkAirPodsConnection()
            }) {
                HStack {
                    Image(systemName: viewModel.isAirPodsConnected ? "checkmark.circle" : "antenna.radiowaves.left.and.right")
                    Text(viewModel.isAirPodsConnected ? "Connected" : "Connect")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(viewModel.isAirPodsConnected ? Color.green : Color.blue)
                .cornerRadius(25) // 둥근 모서리
                .shadow(color: .gray.opacity(0.4), radius: 4, x: 0, y: 2)
            }
            .padding()
        }
        .padding()
        .background(Color.white) // 헤더 박스를 하얀색 배경으로 설정
        .cornerRadius(20) // 모서리 라운드를 주어서 박스 형태로 만듦
        .shadow(radius: 5) // 그림자를 추가하여 깊이감을 부여
        .padding() // 전체 화면에 여백 추가
    }

    // 메인 콘텐츠 부분 - 상태에 따라 보여주는 콘텐츠가 달라집니다.
    private var mainContentView: some View {
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
        .padding(.top)
        .onReceive(viewModel.$isAirPodsConnected) { isConnected in
            homeState = isConnected ? .connected : .notConnected
        }
    }
}

// MARK: - States and Subviews for Different States
extension HomeView {
    // AirPods가 연결되지 않았을 때 보여주는 뷰
    private var notConnectedView: some View {
        VStack {
            Text("AirPods을 착용 후 운동해주세요.")
                .font(.title3)
                .foregroundColor(.gray)
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
        }
    }

    // AirPods가 연결된 후 보여주는 뷰
    private var connectedView: some View {
        VStack {
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
