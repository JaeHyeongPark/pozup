import SwiftUI

struct DataRowView: View {
    var label: String
    var value: Double

    var body: some View {
        HStack(spacing: 5) {
            Text("\(label):")
                .font(.headline)
                .frame(minWidth: 50, alignment: .leading)
            Text(Utilities.formattedValue(value))
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.horizontal, 5)
    }
}
