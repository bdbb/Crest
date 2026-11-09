import SwiftUI

/// A stacked group's own identity and action strip.
///
/// It earns its place twice over where members are stacked tab rows. It is
/// the only thing that says "these rows are one split" before you notice the
/// container behind them — full-height rows otherwise read as neighbours that
/// happen to share a tint. And every member row carries a context menu of its
/// own, together covering all but a thin frame of the container, so without a
/// strip that belongs to the group there would be nowhere left to press for
/// "Separate All Tabs".
///
/// A group whose members share one row has no header: the row itself lifts as
/// the group, and each member's menu ends with the group's.
struct BrowserSidebarSplitGroupHeader: View {
    let configuration: BrowserSidebarSplitGroupRowConfiguration
    let interaction: BrowserSidebarSplitGroupRowInteractionContext
    let metrics: BrowserSidebarSplitGroupRowMetrics.Header

    @Environment(\.sidebarRowContentIndent) private var folderIndent

    var body: some View {
        HStack(spacing: metrics.spacing) {
            BrowserSidebarSplitGroupIcon(configuration: configuration, glyphSize: metrics.glyphSize)
                .browserIconCustomizationPopover(configuration.iconCustomization(interaction))

            if interaction.isRenaming {
                BrowserSidebarSplitGroupRenameField(interaction: interaction)
            } else {
                Button(action: interaction.activate) {
                    Text(configuration.shownTitle)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .modifier(
                    BrowserPlatformRowAuxiliaryClickModifier(
                        perform: configuration.canClose ? interaction.closeSplit : nil
                    )
                )
                .accessibilityLabel(configuration.shownTitle)
                .accessibilityValue(
                    "Split View with \(configuration.members.count) tabs"
                )
                .accessibilityAddTraits(
                    configuration.isPresented ? .isSelected : []
                )
            }

            Spacer(minLength: 0)

            Menu {
                BrowserSidebarSplitGroupContextMenu(
                    configuration: configuration,
                    interaction: interaction
                )
            } label: {
                Image(systemName: "ellipsis")
                    .frame(width: metrics.height, height: metrics.height)
                    .contentShape(.rect)
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .crestMenuActionLabelStyle()
            .tint(.primary)
            .accessibilityLabel("Split View actions")
            .disabled(!configuration.isAvailableForDisplay)
        }
        .frame(height: metrics.height)
        .padding(.leading, configuration.headerLeadingInset + folderIndent)
        .padding(.trailing, configuration.headerLeadingInset)
        .contentShape(.rect)
        .browserSplitGroupDraggable(
            item: configuration.dragItem,
            members: configuration.members,
            favicons: configuration.context.favicons,
            placement: configuration.placement,
            folderID: configuration.folderID,
            reorder: configuration.reorderContext,
            isEnabled: configuration.isAvailableForDisplay && configuration.capabilities.supportsOrganization
                && !interaction.isRenaming,
            requiresSelectedSpace: true
        )
        .contextMenu {
            if configuration.capabilities.supportsOrganization {
                BrowserSidebarSplitGroupContextMenu(configuration: configuration, interaction: interaction)
                    .tint(.primary)
                    .onAppear {
                        configuration.sidebarInteraction.sidebarReorderState.yieldToCompetingInteraction()
                    }
            }
        }
    }
}

/// The group's name while it is being edited, in place of whatever names it
/// at rest. Return commits, as does leaving the field, and Escape abandons
/// the edit.
struct BrowserSidebarSplitGroupRenameField: View {
    let interaction: BrowserSidebarSplitGroupRowInteractionContext

    var body: some View {
        TextField("Split View Name", text: interaction.draftTitle)
            .textFieldStyle(.plain)
            .focused(interaction.isTitleFocused)
            .submitLabel(.done)
            .onSubmit(interaction.commitTitle)
            .onKeyPress(.escape) {
                interaction.cancelTitleEditing()
                return .handled
            }
            .accessibilityIdentifier("split-group-rename-field")
            .onChange(of: interaction.isTitleFocused.wrappedValue) { _, focused in
                if !focused, interaction.isRenaming {
                    interaction.commitTitle()
                }
            }
    }
}

private struct BrowserSidebarSplitGroupIcon: View {
    let configuration: BrowserSidebarSplitGroupRowConfiguration
    let glyphSize: CGFloat

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Group {
            if let emoji = configuration.emojiIcon {
                Text(emoji)
                    .font(.system(size: glyphSize))
            } else {
                faviconStack
            }
        }
        .frame(width: glyphSize * 1.45, height: glyphSize)
        .accessibilityHidden(true)
    }

    private var faviconStack: some View {
        ZStack(alignment: .leading) {
            ForEach(
                Array(deckMembers.enumerated()),
                id: \.element.id
            ) { index, member in
                let isFocused = member.id == configuration.focusedMemberID
                let shouldAnimateLift = !reduceMotion

                TabStateFaviconView(
                    tab: member,
                    favicons: configuration.context.favicons,
                    profileID: configuration.profileID,
                    size: glyphSize * 0.78
                )
                .padding(1)
                .background { CrestSurfaceLayer(shape: Circle()) }
                .overlay {
                    Circle()
                        .strokeBorder(
                            Color.primary.opacity(CrestOpacity.border),
                            lineWidth: CrestLayout.hairline
                        )
                }
                .scaleEffect(deckScale(at: index))
                .rotationEffect(
                    .degrees(deckRotation(at: index)),
                    anchor: .bottom
                )
                .offset(
                    x: deckHorizontalOffset(at: index),
                    y: deckVerticalOffset(at: index)
                )
                .zIndex(Double(index))
                .transition(.scale(scale: 0.82).combined(with: .opacity))
                .animation(deckAnimation, value: configuration.focusedMemberID)
                .keyframeAnimator(
                    initialValue: CGFloat.zero,
                    trigger: configuration.focusedMemberID
                ) { content, lift in
                    content.offset(
                        y: isFocused && shouldAnimateLift ? lift : 0
                    )
                } keyframes: { _ in
                    CubicKeyframe(
                        -glyphSize * 0.18,
                        duration: CrestMotion.collectionTransition / 2
                    )
                    CubicKeyframe(
                        0,
                        duration: CrestMotion.collectionTransition / 2
                    )
                }
            }
        }
    }

    private var deckMembers: [TabStateModel] {
        BrowserSidebarSplitGroupIconDeck.orderedMembers(
            configuration.members,
            focusedMemberID: configuration.focusedMemberID
        )
    }

    private var frontIndex: Int {
        max(deckMembers.count - 1, 0)
    }

    private func deckScale(at index: Int) -> CGFloat {
        1 - CGFloat(frontIndex - index) * 0.055
    }

    private func deckRotation(at index: Int) -> Double {
        Double(index - frontIndex) * 3.5
    }

    private func deckHorizontalOffset(at index: Int) -> CGFloat {
        CGFloat(index) * glyphSize * 0.28
    }

    private func deckVerticalOffset(at index: Int) -> CGFloat {
        CGFloat(frontIndex - index) * glyphSize * 0.045
    }

    private var deckAnimation: Animation? {
        CrestMotion.collection.unlessReducingMotion(reduceMotion)
    }
}

/// A split may contain more members than the compact header can draw. The
/// focused member is always admitted to the visible deck and placed last so it
/// renders above the other cards; stable tab identity then lets SwiftUI move
/// each favicon through the deck instead of replacing the whole stack.
enum BrowserSidebarSplitGroupIconDeck {
    static let visibleLimit = 3

    static func orderedMembers<Member: Identifiable>(
        _ members: [Member],
        focusedMemberID: UUID?,
        limit: Int = visibleLimit
    ) -> [Member] where Member.ID == UUID {
        guard limit > 0 else { return [] }

        var visible = Array(members.prefix(limit))
        guard let focused = members.first(where: { $0.id == focusedMemberID })
        else { return visible }

        if !visible.contains(where: { $0.id == focused.id }) {
            if visible.isEmpty {
                visible.append(focused)
            } else {
                visible[visible.index(before: visible.endIndex)] = focused
            }
        }

        visible.removeAll { $0.id == focused.id }
        visible.append(focused)
        return visible
    }
}
