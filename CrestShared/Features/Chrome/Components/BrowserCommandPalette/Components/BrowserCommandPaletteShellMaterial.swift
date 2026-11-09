import SwiftUI

/// The palette card's surface: Crest's solid dark flyout surface in `shape`,
/// edged with a hairline.
struct BrowserCommandPaletteShellMaterial: ViewModifier {
    // MARK: - Variables

    let shape: RoundedRectangle

    func body(content: Content) -> some View {
        content
            .overlay {
                shape
                    .strokeBorder(CrestColor.subtleBorder, lineWidth: CrestLayout.hairline)
                    .allowsHitTesting(false)
            }
            .crestFlyoutStyle(in: shape)
    }
}
