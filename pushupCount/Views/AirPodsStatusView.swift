import SwiftUI

//TOBE Deprecated
struct AirPodsStatusView: View {
    @Binding var isAirPodsConnected: Bool
    @Binding var airPodsModelName: String
    @Binding var animateOpacity: Bool

    var body: some View {
        VStack {
            if isAirPodsConnected {
                connectedView
            } else {
                disconnectedView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var connectedView: some View {
        VStack(spacing: 10) {
            Text("Connected")
                .font(.largeTitle)
                .foregroundColor(.green)
                .transition(.opacity.animation(.easeInOut(duration: 2.0)))

            connectedModelView
                .offset(y: 10)
                .transition(.opacity.animation(.easeInOut(duration: 2.0)))
        }
        .padding()
    }

    private var connectedModelView: some View {
        AirPodsImageView(modelName: airPodsModelName)
            .frame(maxHeight: UIScreen.main.bounds.height * 0.4)
            .clipped()
    }

    private var disconnectedView: some View {
        VStack(spacing: 20) {
            Spacer()
            ZStack {
                Image("Airpods/airpodspro2")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                    .opacity(animateOpacity ? 0.5 : 1.0)
                    .scaleEffect(animateOpacity ? 1.1 : 0.9)
                    .padding()
            }

            Text("AirPods를 연결해 주세요.")
                .font(.title)
                .foregroundColor(.gray)
                .opacity(animateOpacity ? 1.0 : 0.7)
                .animation(.easeIn(duration: 1.0).repeatForever(autoreverses: true), value: animateOpacity)

            Text("AirPods 연결을 기다리는 중입니다...")
                .font(.headline)
                .foregroundColor(.blue)
                .opacity(animateOpacity ? 1.0 : 0.5)
                .animation(.easeInOut(duration: 1.0).delay(0.5).repeatForever(autoreverses: true), value: animateOpacity)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGray6))
    }
}
