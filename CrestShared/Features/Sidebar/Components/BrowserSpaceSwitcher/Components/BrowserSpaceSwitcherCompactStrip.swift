import SwiftUI

/// A centred, horizontally scrolling Space picker with the shell's accessories
/// held clear at either edge.
///
/// The picker gets an explicit viewport from the actual strip width and the
/// larger occupied utility side. Its segments keep their identity at the size
/// the person's icon sizing picks for that viewport, so overflow scrolls and
/// the active Space can always be revealed.
///
/// The lists keep to the window's edge and the plus button to the page side,
/// whichever side the sidebar is docked on.
struct BrowserSpaceSwitcherCompactStrip: View {
    // MARK: - Variables

    let spaces: [BrowserSpaceIdentity]
    let selectedSpaceID: UUID
    let reorderState: BrowserSidebarReorderState
    let metrics: BrowserSpacePickerMetrics
    let iconSizing: BrowserSpaceIconSizing
    let chosenIconScale: Double
    let selectSpace: (UUID) -> Void
    let accessories: BrowserSpaceSwitcherAccessories
    let downloads: BrowserSpaceSwitcherDownloads

    @Environment(\.layoutDirection) private var layoutDirection

    private var sidebarOnRight: Bool { BrowserDeviceAppearanceStore.shared.sidebarOnRight }

    /// The edge of the window the sidebar, and so this strip, stands against.
    private var sidebarEdge: HorizontalEdge {
        BrowserChromeAppearance.sidebarEdge(onRight: sidebarOnRight, in: layoutDirection)
    }

    var body: some View {
        GeometryReader { geometry in
            let scale = fittedScale(
                in: BrowserSpaceSwitcherLayout.compactPickerViewportWidth(
                    availableWidth: geometry.size.width,
                    leadingUtilityWidth: utilityWidth(at: .leading),
                    trailingUtilityWidth: utilityWidth(at: .trailing)
                )
            )
            let style = CrestSpaceIconPickerStyle.compact.scaled(by: scale)
            let allocation = BrowserSpaceSwitcherLayout.compactStripAllocation(
                availableWidth: geometry.size.width,
                spaceCount: spaces.count,
                leadingUtilityWidth: utilityWidth(at: .leading),
                trailingUtilityWidth: utilityWidth(at: .trailing),
                style: style
            )

            ZStack {
                HStack(spacing: BrowserSpaceSwitcherLayout.compactStripSpacing) {
                    accessory(at: .leading)
                        .accessibilitySortPriority(
                            BrowserSpaceSwitcherLayout.leadingUtilityAccessibilityPriority
                        )

                    Spacer()

                    accessory(at: .trailing)
                        .accessibilitySortPriority(
                            BrowserSpaceSwitcherLayout.trailingUtilityAccessibilityPriority
                        )
                }
                .padding(
                    .horizontal,
                    BrowserSpaceSwitcherLayout.compactStripHorizontalInset
                )

                BrowserSpaceSwitcherCompactPicker(
                    spaces: spaces,
                    selectedSpaceID: selectedSpaceID,
                    reorderState: reorderState,
                    metrics: metrics.scaled(by: scale),
                    selectSpace: selectSpace,
                    allocation: allocation,
                    style: style
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(
            height: BrowserSpaceSwitcherLayout.compactStripHeight(
                for: .compact.scaled(by: iconSizing.largestScale(chosen: chosenIconScale))
            )
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Spaces")
    }

    // MARK: - Actions - Sizing

    /// The scale these Spaces are drawn at in a picker `width` wide.
    private func fittedScale(in width: CGFloat) -> CGFloat {
        iconSizing.scale(chosen: chosenIconScale, spaceCount: spaces.count, style: .compact, width: width)
    }

    // MARK: - Actions - Accessories

    /// The lists on the sidebar's own edge, the plus button on the other.
    @ViewBuilder
    private func accessory(at edge: HorizontalEdge) -> some View {
        if edge == sidebarEdge {
            if let commonLists = accessories.commonLists {
                commonListsButton(commonLists)
            }
        } else if let creation = accessories.creation {
            creationMenu(creation)
        }
    }

    private func utilityWidth(at edge: HorizontalEdge) -> CGFloat {
        let isOccupied =
            edge == sidebarEdge
            ? accessories.commonLists != nil
            : accessories.creation != nil
        return isOccupied ? BrowserSpaceSwitcherLayout.utilityButtonSize : 0
    }

    private func creationMenu(
        _ creation: BrowserSpaceSwitcherCreation
    ) -> some View {
        Menu {
            Group {
                Button(ShortcutCommand.newTab, action: creation.openNewTab)
                if let createSpace = creation.createSpace {
                    Button("New Space", systemImage: "plus.square.on.square", action: createSpace)
                }
            }
            .crestMenuActionLabelStyle()
        } label: {
            Label("New", systemImage: "plus")
                .labelStyle(.iconOnly)
                .frame(
                    width: BrowserSpaceSwitcherLayout.utilityButtonSize,
                    height: BrowserSpaceSwitcherLayout.utilityButtonSize
                )
                .contentShape(.rect)
        }
        .menuStyle(.button)
        .menuIndicator(.hidden)
        .buttonStyle(.borderless)
        .accessibilityIdentifier("space-switcher-new")
        .help("New Tab or Space")
    }

    private func commonListsButton(
        _ commonLists: BrowserSpaceSwitcherCommonLists
    ) -> some View {
        BrowserSpaceSwitcherCommonListsButton(
            isExpanded: commonLists.isExpanded,
            surface: commonLists.surface,
            downloads: downloads.items,
            newDownloads: downloads.newItems,
            badgeColor: downloads.badgeColor,
            action: commonLists.toggle,
            choose: commonLists.choose,
            recordFrame: commonLists.recordTriggerFrame
        )
    }
}
