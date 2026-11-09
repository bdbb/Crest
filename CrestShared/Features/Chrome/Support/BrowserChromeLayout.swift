import SwiftUI

enum BrowserChromeLayout {
    static let sidebarTitlebarHeight: CGFloat = 48
    static let sidebarNavigationControlHitTarget: CGFloat = 30
    static let sidebarNavigationSymbolPointSize: CGFloat = 15
    static let sidebarNavigationTrailingInset = CrestSpacing.medium
    /// The room the window's close, minimize and zoom buttons take at the
    /// sidebar's leading edge, which the sidebar toggle stands clear of.
    static let sidebarWindowControlsWidth: CGFloat = 80
    static let addressEditingRingWidth: CGFloat = 0.5
    static let addressHeight: CGFloat = 36
    static let addressCornerRadius = CrestRadius.compact
    static let sidebarMinimumWidth: CGFloat = 214
    static let sidebarIdealWidth: CGFloat = 289
    static let sidebarMaximumWidth: CGFloat = 380
    static let pageFrameInset = CrestSpacing.small
    /// A page's corner where there is no window corner to follow: full screen,
    /// iPhone and iPad.
    static let pageCornerRadius: CGFloat = 13
    static let pageBrandSeamWidth: CGFloat = 1.5

    static func clampedSidebarWidth(_ width: CGFloat) -> CGFloat {
        min(max(width, sidebarMinimumWidth), sidebarMaximumWidth)
    }
}
