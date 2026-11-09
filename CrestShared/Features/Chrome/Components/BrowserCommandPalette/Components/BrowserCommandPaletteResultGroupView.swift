import SwiftUI

struct BrowserCommandPaletteResultGroupView: View {
    let model: BrowserCommandPaletteModel
    let group: BrowserCommandPaletteGroup
    var listsUpward = false

    /// The group's rows under its header, where it has one, one row spacing
    /// apart whether or not it has.
    var body: some View {
        VStack(
            alignment: .leading,
            spacing: BrowserCommandPaletteMetrics.resultRowSpacing
        ) {
            if let header = group.section.title {
                Text(header)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(
                        .horizontal,
                        BrowserCommandPaletteMetrics.resultHeaderHorizontalPadding
                    )
            }
            BrowserCommandPaletteResultRows(model: model, group: group, listsUpward: listsUpward)
        }
    }
}
