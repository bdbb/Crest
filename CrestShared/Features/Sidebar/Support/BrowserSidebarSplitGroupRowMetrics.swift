import CoreGraphics

/// The drawn geometry of a split-group row, resolved once per shell rather
/// than spelled out by each row.
///
/// None of this describes a member. A group holds the *same* rows the tab list
/// draws everywhere else — full height, full favicon, full trailing control —
/// so a member's own geometry comes from `BrowserSidebarTabRowMetrics`. What
/// is left is how the members are arranged: side by side as the halves of one
/// row, or stacked under a slim strip that names the group.
///
/// The container's insets are deliberately absent here because they are not
/// the container's to choose. Its inset from the sidebar edge, the padding a
/// stacked group holds its rows in by, the space it keeps from its neighbours
/// and its corners are the ones a folder uses too, from
/// `BrowserSidebarMetrics`, so a group lines up in the same column as the tabs
/// above and below it. A header's leading inset is the tab row's
/// `contentLeadingInset`, so its glyph sits in the same column as the member
/// favicons.
struct BrowserSidebarSplitGroupRowMetrics: Equatable, Sendable {
    // MARK: - Static Variables

    /// A pointer shell: the members flush beside one another as equal halves
    /// of one row, which is as tall as any other tab row and has no header.
    static let pointer = BrowserSidebarSplitGroupRowMetrics(memberSpacing: 0, header: nil)

    /// A touch shell: the members stacked and held apart under a header that
    /// is a full native hit target, read at arm's length rather than at a
    /// desk.
    static let touch = BrowserSidebarSplitGroupRowMetrics(
        memberSpacing: CrestSpacing.extraExtraSmall,
        header: Header(height: 44, glyphSize: 20, spacing: 8)
    )

    // MARK: - Types

    /// The strip above a stacked group's members, which names the group and
    /// owns its actions, its ellipsis menu and its drag.
    struct Header: Equatable, Sendable {
        let height: CGFloat
        let glyphSize: CGFloat
        let spacing: CGFloat
    }

    // MARK: - Variables

    /// The gap between members, and between a header and the first of them.
    ///
    /// Halves of one row sit flush, told apart by the divider between them.
    /// A touch shell separates its stacked rows, because a finger aiming at
    /// one row in a stack of four wants to see where each one ends.
    let memberSpacing: CGFloat

    /// The header a stacked group carries. A group without one lays its
    /// members out side by side in a single row instead.
    let header: Header?

    /// Whether the members are the halves of one row, which then lifts as the
    /// group and carries the group's actions on each member's own menu.
    var sharesOneRow: Bool { header == nil }
}
