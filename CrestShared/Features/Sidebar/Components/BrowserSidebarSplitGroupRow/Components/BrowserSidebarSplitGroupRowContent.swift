import SwiftUI

/// The group's members as shared tab rows: the equal halves of one row, or
/// stacked under the group's header inside its frame.
struct BrowserSidebarSplitGroupRowContent: View {
    let configuration: BrowserSidebarSplitGroupRowConfiguration
    let interaction: BrowserSidebarSplitGroupRowInteractionContext

    @Environment(\.sidebarLayerDepth) private var depth
    @Environment(\.sidebarRowContentIndent) private var folderIndent
    private var tabScale: Double { BrowserDeviceAppearanceStore.shared.tabScale }

    var body: some View {
        if let header = configuration.metrics.header {
            VStack(spacing: configuration.metrics.memberSpacing) {
                BrowserSidebarSplitGroupHeader(
                    configuration: configuration,
                    interaction: interaction,
                    metrics: header
                )

                ForEach(configuration.members, id: \.id) { member in
                    row(for: member)
                }
            }
            .environment(\.sidebarLayerDepth, depth + 1)
            .padding([.horizontal, .top], BrowserSidebarMetrics.containerPadding)
            .padding(.bottom, BrowserSidebarMetrics.containerBottomPadding(tabScale: tabScale))
        } else {
            halves
        }
    }

    /// The members side by side in one row's band. Each half is a whole tab
    /// row, so it selects, closes and reads as its own tab; the row lifts as
    /// the group, and each half's menu ends with the group's.
    private var halves: some View {
        HStack(spacing: configuration.metrics.memberSpacing) {
            ForEach(configuration.members, id: \.id) { member in
                let isLeading = member.id == configuration.members.first?.id
                row(for: member)
                    // Only the leading half starts where the folders around
                    // the group put a row's icon.
                    .environment(\.sidebarRowContentIndent, isLeading ? folderIndent : 0)
                    // Drawn over the half's leading edge rather than between
                    // the halves, so every half is exactly as wide as the next.
                    .overlay(alignment: .leading) {
                        if !isLeading {
                            Rectangle()
                                .fill(CrestColor.subtleBorder)
                                .frame(width: CrestLayout.hairline)
                                .padding(.vertical, CrestSpacing.small)
                                .allowsHitTesting(false)
                        }
                    }
            }
        }
        .environment(
            \.sidebarSplitGroupMenu,
            BrowserSidebarSplitGroupContextMenu(
                configuration: configuration, interaction: interaction, followsMemberMenu: true)
        )
        // The group's name is edited over the halves, which keep the row's
        // height and its place in the list while they are out of reach.
        .opacity(interaction.isRenaming ? 0 : 1)
        .allowsHitTesting(!interaction.isRenaming)
        .accessibilityHidden(interaction.isRenaming)
        .overlay {
            if interaction.isRenaming {
                BrowserSidebarSplitGroupRenameField(interaction: interaction)
                    .padding(.horizontal, configuration.tabRowMetrics.contentLeadingInset + folderIndent)
            }
        }
        .browserIconCustomizationPopover(configuration.iconCustomization(interaction))
    }

    /// Each member keeps its own identity: selecting one prepositions the
    /// sidebar's scroll onto the row the page will zoom from, and a group
    /// whose rows shared one identity would scroll to the wrong place — or to
    /// nowhere at all.
    private func row(for member: TabStateModel) -> some View {
        BrowserSidebarTabRow(tab: member, context: configuration.context, isSplitGroupMember: true)
            .equatable()
            .id(member.id)
    }
}
