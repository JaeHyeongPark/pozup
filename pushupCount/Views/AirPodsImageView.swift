import SwiftUI

struct AirPodsImageView: View {
    var modelName: String

    var body: some View {
        let imageName: String

        switch modelName {
        case let name where name.contains("Max"):
            imageName = "Airpods/airpodsmax"
        case let name where name.contains("Pro 2"):
            imageName = "Airpods/airpodspro2"
        case let name where name.contains("4"):
            imageName = "Airpods/airpods4"
        default:
            imageName = "Airpods/default"
        }

        return Image(imageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 200, height: 200)
            .padding()
    }
}
