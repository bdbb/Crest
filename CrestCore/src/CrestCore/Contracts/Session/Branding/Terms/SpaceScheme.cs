namespace CrestCore.Contracts;

/// A modern look a Space can start from: a plain sidebar, light or dark with
/// the device, under the Space's own icon, with no arms.
/// Choosing one copies its look into the Space, so a Space keeps the look it
/// was given when a scheme changes.
public sealed class SpaceScheme {
    #region Static Variables

    /// A neutral gray laid thinly over the window's own background, which
    /// settles it near #333 by night and #E5E5E5 by day, under a fine grain,
    /// with its icon in a mid gray. The values follow Arc's sidebar.
    public static readonly SpaceScheme Neutral = new("neutral", "Neutral", SchemeLook(
        [Tincture.NeutralSmoke], Tincture.NeutralGray, strength: 0.15, showsTexture: true));

    /// An accent's own color laid over the window's background the same way,
    /// strongly enough to tint it: the look a new Space of the accent wears.
    public static readonly SpaceScheme Indigo = new("indigo", "Indigo", WashLook(Tincture.Indigo));
    public static readonly SpaceScheme Ember = new("ember", "Ember", WashLook(Tincture.Ember));
    public static readonly SpaceScheme Teal = new("teal", "Teal", WashLook(Tincture.Teal));
    public static readonly SpaceScheme Rose = new("rose", "Rose", WashLook(Tincture.Rose));

    public static IReadOnlyList<SpaceScheme> All { get; } = [Neutral, Indigo, Ember, Teal, Rose];

    /// How strongly an accent's color is laid over the window's background.
    private const double WashStrength = 0.35;

    #endregion

    #region Variables

    public string Name { get; }

    /// The scheme's name in the template gallery.
    [Localized]
    public string Title { get; }

    /// The look a Space starting from the scheme wears.
    public SpaceBranding Look { get; }

    #endregion

    #region Constructors

    /// The scheme's look records the scheme as where it started, so a Space
    /// that leaves it for a house takes the house's strengths.
    private SpaceScheme(string name, string title, SpaceBranding look) {
        Name = name;
        Title = title;
        Look = look with { Crest = look.Crest with { StartingPresetId = name } };
    }

    #endregion

    #region Actions - Lookup

    public static SpaceScheme? Named(string? name) => All.FirstOrDefault(scheme => scheme.Name == name);

    #endregion

    #region Actions - Looks

    /// A scheme's look: its colors as a gradient at `strength` over the
    /// window's own background, with no readability fade, its text and
    /// controls following the device's appearance, and the Space's icon in
    /// place of a crest, drawn in `symbol`.
    private static SpaceBranding SchemeLook(Tincture[] colors, Tincture symbol, double strength, bool showsTexture) =>
        new(new([.. colors.Select(tincture => tincture.Color)]), SpaceBannerPattern.Diagonal, strength, ReadabilityFade: 0,
            KeepsControlsReadable: false, SpaceThemeMode.Gradient, GradientAngle: 0, showsTexture, SpaceIconStyle.SimpleSymbol,
            symbol.Color, SpaceBranding.Neutral.Crest, SpaceBranding.BaselineRenderingVersion, FolderColorIntensity: 0,
            SpaceTextColorMode.System, HasCustomAppearance: false);

    /// The look of a scheme that washes the sidebar in `color`.
    private static SpaceBranding WashLook(Tincture color) =>
        SchemeLook([color], Tincture.NeutralGray, WashStrength, showsTexture: true);

    #endregion
}
