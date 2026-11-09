import CoreGraphics

/// The controls a shell asks the Space switcher to carry alongside its
/// Spaces.
///
/// Only an arrangement with room either side of its picker can carry any, so
/// each one is optional and the scrolling track ignores both.
struct BrowserSpaceSwitcherAccessories {
    var commonLists: BrowserSpaceSwitcherCommonLists?
    var creation: BrowserSpaceSwitcherCreation?
}

/// The switcher's accessory on the page side: what the plus button makes.
struct BrowserSpaceSwitcherCreation {
    let openNewTab: () -> Void

    /// Absent where the window may not add a Space, as in private browsing.
    let createSpace: (() -> Void)?
}

/// The switcher's accessory at the window's edge: the archive, history, and
/// downloads lists, and the badge that says how many finished downloads have
/// not been looked at yet.
struct BrowserSpaceSwitcherCommonLists {
    let isExpanded: Bool

    /// The list the button opens and wears the symbol of in the shown Space.
    let surface: BrowserUtilitySurface
    let toggle: () -> Void

    /// Makes another list the one the button opens in the shown Space.
    let choose: (BrowserUtilitySurface) -> Void

    /// Reports where the trigger ended up, so the lists can fan out from it.
    let recordTriggerFrame: (CGRect) -> Void
}
