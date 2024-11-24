import SwiftUI
import CoreMotion

struct PushUpCountView: View {
    var pushUpCount: Int
    var motionData: CMDeviceMotion

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            DataRowView(label: "Roll", value: motionData.attitude.roll)
            DataRowView(label: "Pitch", value: motionData.attitude.pitch)
            DataRowView(label: "Yaw", value: motionData.attitude.yaw)

            Text("Push-Up Count: \(pushUpCount)")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding()
    }
}
