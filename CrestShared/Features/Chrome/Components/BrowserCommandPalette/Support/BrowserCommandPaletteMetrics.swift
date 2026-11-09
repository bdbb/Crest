import CoreGraphics

enum BrowserCommandPaletteMetrics {
    // MARK: - Static Variables

    static let maximumResultAreaHeight: CGFloat = 390
    static let resultRowHeight: CGFloat = 44
    /// The room between a group's rows, and between its header and them.
    static let resultRowSpacing: CGFloat = 4
    static let resultHeaderHeight: CGFloat = 17

    static let overlayCardPadding: CGFloat = 24
    static var overlayReservedHeight: CGFloat {
        (overlayCardPadding * 2)
            + searchFieldMinimumHeight
            + CrestLayout.hairline
    }
    /// One row and the padding around it.
    static let minimumOverlayResultHeight: CGFloat = resultContentPadding * 2 + resultRowHeight
    /// The room a palette grown out of an address field keeps from the edges
    /// of the space it lies in.
    static let fieldRegionMargin: CGFloat = 8
    /// The least room a palette rising to the top of the screen keeps there,
    /// where the safe area leaves less, as a Peek does.
    static let fieldRegionTopMargin: CGFloat = 10
    static let maximumCardWidth: CGFloat = 720
    static let cardCornerRadius: CGFloat = CrestRadius.control
    /// How far below full size the card's contents start while the card grows
    /// out of the address field, and end while it shrinks back.
    static let morphContentScale: CGFloat = 0.97

    static let searchFieldSpacing: CGFloat = 12
    static let searchFieldHorizontalPadding: CGFloat = 20
    static let searchFieldMinimumHeight: CGFloat = 56

    /// The padding around the results, which with a row's own puts its icon
    /// under the field's search glyph.
    static let resultContentPadding: CGFloat = 8
    /// The least height of the row of search provider chips beside the field,
    /// which a larger text size makes taller.
    static let providerChipRowHeight: CGFloat = 44
    /// A provider's logo in a chip, and the neutral plate it sits on so it
    /// reads on any brand tint.
    static let chipIconSize: CGFloat = 14
    static let chipIconPlateSize: CGFloat = 20
    static let resultGroupSpacing: CGFloat = 16
    static let resultHeaderHorizontalPadding: CGFloat = 4

    static let rowSpacing: CGFloat = 12
    /// The room between a row's title and the detail after it on its line.
    static let rowTextSpacing: CGFloat = 8
    static let rowHorizontalPadding: CGFloat = 12
    static let rowCornerRadius: CGFloat = CrestRadius.compact

    static let rowIconContainerSize: CGFloat = 28
    static let rowFaviconSize: CGFloat = 20
    static let rowSymbolPointSize: CGFloat = 14
    static let intentSymbolPointSize: CGFloat = 16
    static let rowIconCornerRadius: CGFloat = 6
    static let rowIconBackgroundOpacity = 0.08

    static let shortcutHorizontalPadding: CGFloat = 6
    static let shortcutMinimumHeight: CGFloat = 20
    static let shortcutCornerRadius: CGFloat = 5
    static let shortcutBackgroundOpacity = 0.07

    static let scrimOpacity = 0.18
}
