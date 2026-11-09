import SwiftUI

/// Measures the split as one insertion slot and draws the surface its members
/// share. A stacked group's header owns the group drag; a group whose members
/// share one row lifts from anywhere on it.
struct BrowserSidebarSplitGroupRowSurface: ViewModifier {
    let configuration: BrowserSidebarSplitGroupRowConfiguration
    let interaction: BrowserSidebarSplitGroupRowInteractionContext

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.sidebarLayerDepth) private var depth
    private var tabScale: Double { BrowserDeviceAppearanceStore.shared.tabScale }

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .contentShape(.rect)
            .background {
                CrestSurfaceLayer(
                    shape: containerShape,
                    hoverTint: configuration.isPresented ? CrestColor.hover : nil
                )
                .overlay { if isMultiSelected { containerShape.fill(CrestColor.hover) } }
                .overlay {
                    if let tint = configuration.tint {
                        containerShape.fill(
                            tint.color.opacity(
                                configuration.isPresented ? 0.16 : 0.10
                            )
                        )
                    }
                }
                .padding(.vertical, memberSeparation)
            }
            .animation(surfaceAnimation, value: configuration.isPresented)
            .animation(surfaceAnimation, value: isMultiSelected)
            // In the same column as every other layer, with the space it keeps
            // from its neighbours inside the row, so drag geometry includes the
            // resting separation.
            .padding(.horizontal, BrowserSidebarMetrics.layerInset)
            .padding(.vertical, containerSpacing)
            .contentShape(.rect)
            .modifier(
                BrowserTabSelectionTarget(
                    tabID: configuration.members.first?.id, browser: configuration.browser,
                    assignment: configuration.assignment,
                    isEnabled: configuration.isAvailableForDisplay && !interaction.isRenaming)
            )
            .browserSplitGroupDraggable(
                item: configuration.dragItem,
                members: configuration.members,
                favicons: configuration.context.favicons,
                placement: configuration.placement,
                folderID: configuration.folderID,
                reorder: configuration.reorderContext,
                isEnabled: configuration.metrics.sharesOneRow && configuration.isAvailableForDisplay
                    && configuration.capabilities.supportsOrganization && !interaction.isRenaming,
                requiresSelectedSpace: true
            )
            .browserSidebarReorderContainer(
                item: .splitGroup(configuration.dragItem),
                section: .tabs(placement: configuration.placement, folderID: configuration.folderID),
                reorder: configuration.reorderContext,
                isEnabled: configuration.isAvailableForDisplay && configuration.capabilities.supportsOrganization
            )
            .crestCollectionItemTransition()
            .accessibilityElement(children: .contain)
            .accessibilityLabel(
                "Split View with \(configuration.members.count) tabs"
            )
    }

    private var isMultiSelected: Bool {
        configuration.members.contains {
            BrowserSidebarSelection.showsSelected(.tab($0.id), in: configuration.context)
        }
    }

    private var containerShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: BrowserSidebarMetrics.layerCornerRadius(depth: depth), style: .continuous)
    }

    /// The space the group keeps above and below itself. Halves of one row
    /// already keep a tab row's own separation, which makes the group exactly
    /// as tall as the tab rows beside it.
    private var containerSpacing: CGFloat {
        configuration.metrics.sharesOneRow ? 0 : BrowserSidebarMetrics.containerSpacing
    }

    /// How far the shared surface stops short of the content's top and bottom:
    /// the half of a row's separation each half of one row keeps around its
    /// own surface, so the two surfaces coincide. A stacked group's surface
    /// holds its rows whole.
    private var memberSeparation: CGFloat {
        guard configuration.metrics.sharesOneRow else { return 0 }
        let separation = BrowserSidebarDensity(tabScale).rowSeparation(
            hasBorders: BrowserDeviceAppearanceStore.shared.tabs.borders == .all)
        return CGFloat(separation) / 2
    }

    private var surfaceAnimation: Animation? {
        CrestMotion.surface.unlessReducingMotion(reduceMotion)
    }
}
