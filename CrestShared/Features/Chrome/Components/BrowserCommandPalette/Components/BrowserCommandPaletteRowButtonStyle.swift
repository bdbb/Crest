import SwiftUI

/// A palette row: no surface at rest, and the accent color under the selected
/// row or one being pressed.
struct BrowserCommandPaletteRowButtonStyle: ButtonStyle {
    // MARK: - Variables

    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, BrowserCommandPaletteMetrics.rowHorizontalPadding)
            .frame(minHeight: BrowserCommandPaletteMetrics.resultRowHeight)
            .contentShape(.rect)
            .modifier(BrowserCommandPaletteRowSurface(isSelected: isSelected, isPressed: configuration.isPressed))
    }
}

/// The accent color under a selected or pressed row, whose label takes
/// whichever of black and white reads over that accent.
private struct BrowserCommandPaletteRowSurface: ViewModifier {
    // MARK: - Variables

    let isSelected: Bool
    let isPressed: Bool

    @Environment(\.self) private var environment

    func body(content: Content) -> some View {
        content
            .foregroundStyle(
                isSelected || isPressed
                    ? AnyShapeStyle(Color.accentColor.readableForeground(environment: environment))
                    : AnyShapeStyle(.primary)
            )
            .modifier(
                CrestInteractiveSurfaceModifier(
                    isSelected: isSelected, isHovering: false,
                    cornerRadius: BrowserCommandPaletteMetrics.rowCornerRadius, isPressed: isPressed,
                    showsRestingSurface: false, selectedBorderColor: CrestColor.selectedBorder,
                    selectedBorderWidth: CrestInteractiveSurfaceMetrics.defaultSelectedBorderWidth,
                    customSelectedFill: Color.accentColor)
            )
    }
}
