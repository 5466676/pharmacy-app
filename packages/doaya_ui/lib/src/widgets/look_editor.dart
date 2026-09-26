import 'package:flutter/material.dart';

import '../theme/doaya_appearance.dart';
import '../theme/doaya_look.dart';
import '../tokens/colors.dart';
import '../tokens/dimensions.dart';
import '../tokens/icons.dart';
import '../tokens/typography.dart';
import 'buttons.dart';
import 'glass_surface.dart';
import 'status.dart';

/// The words of «المظهر», from each app's ARB file.
class DoayaLookLabels {
  const DoayaLookLabels({
    required this.style,
    required this.styles,
    required this.styleNotes,
    required this.mode,
    required this.modes,
    required this.colors,
    required this.palettes,
    required this.custom,
    required this.mainColor,
    required this.background,
    required this.hue,
    required this.lightness,
    required this.details,
    required this.corners,
    required this.blur,
    required this.textSize,
    required this.textSizes,
    required this.spacing,
    required this.spacings,
    required this.headingFont,
    required this.headingFonts,
    required this.readability,
    required this.readable,
    required this.adjusted,
    required this.sample,
    required this.sampleButton,
    required this.sampleWarning,
    required this.sampleDanger,
    required this.reset,
  });

  final String style;

  /// By [DoayaStyle] order: glass, flat, soft, outline, contrast.
  final List<String> styles;
  final List<String> styleNotes;
  final String mode;

  /// By [DoayaMode] order: dark, light, black, auto.
  final List<String> modes;
  final String colors;

  /// By [DoayaPaletteSpec.all] order.
  final List<String> palettes;
  final String custom;
  final String mainColor;
  final String background;
  final String hue;
  final String lightness;
  final String details;
  final String corners;
  final String blur;
  final String textSize;

  /// By [DoayaLook.textScales] order.
  final List<String> textSizes;
  final String spacing;

  /// By [DoayaLook.densities] order.
  final List<String> spacings;
  final String headingFont;

  /// By [DoayaHeadingFont] order.
  final List<String> headingFonts;
  final String readability;
  final String readable;
  final String adjusted;
  final String sample;
  final String sampleButton;
  final String sampleWarning;
  final String sampleDanger;
  final String reset;
}

/// «المظهر»: every choice applies at once to the whole app (the screen
/// itself is the preview). [onChanged] saves it.
class DoayaLookEditor extends StatelessWidget {
  const DoayaLookEditor({
    super.key,
    required this.look,
    required this.onChanged,
    required this.labels,
    this.blurAvailable = true,
  });

  final DoayaLook look;
  final ValueChanged<DoayaLook> onChanged;
  final DoayaLookLabels labels;

  /// False on the pharmacy desktop (it never blurs): the blur slider hides.
  final bool blurAvailable;

  @override
  Widget build(BuildContext context) {
    final l = labels;
    final p = DoayaAppearance.palette;
    final isCustom = look.palette == DoayaLook.custom;
    final platform = MediaQuery.platformBrightnessOf(context);
    final mode = look.resolvedMode(platform);
    Widget gap() => SizedBox(height: DoayaSpacing.xl);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Sample(labels: l),
        gap(),
        _Section(
          title: l.style,
          child: Wrap(
            spacing: DoayaSpacing.sm,
            runSpacing: DoayaSpacing.sm,
            children: [
              for (final s in DoayaStyle.values)
                _StyleCard(
                  style: s,
                  name: l.styles[s.index],
                  note: l.styleNotes[s.index],
                  selected: look.style == s,
                  onTap: () => onChanged(look.copyWith(style: s)),
                ),
            ],
          ),
        ),
        gap(),
        _Section(
          title: l.mode,
          child: _Choices<DoayaMode>(
            values: DoayaMode.values,
            names: l.modes,
            selected: look.mode,
            onSelect: (m) => onChanged(look.copyWith(mode: m)),
          ),
        ),
        gap(),
        _Section(
          title: l.colors,
          trailing: isCustom
              ? l.custom
              : l.palettes[DoayaPaletteSpec.all.indexOf(DoayaPaletteSpec.byId(look.palette))],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: DoayaSpacing.sm,
                runSpacing: DoayaSpacing.sm,
                children: [
                  for (final (i, spec) in DoayaPaletteSpec.all.indexed)
                    _Swatch(
                      back: mode == DoayaMode.light ? spec.light : spec.dark,
                      main: spec.main,
                      tooltip: l.palettes[i],
                      selected: look.palette == spec.id,
                      onTap: () => onChanged(look.copyWith(palette: spec.id)),
                    ),
                  _Swatch(
                    back: mode == DoayaMode.light ? look.customLight : look.customDark,
                    main: look.customMain,
                    tooltip: l.custom,
                    selected: isCustom,
                    custom: true,
                    onTap: () => onChanged(look.copyWith(palette: DoayaLook.custom)),
                  ),
                ],
              ),
              if (isCustom) ...[
                SizedBox(height: DoayaSpacing.l),
                _ColorPicker(
                  label: l.mainColor,
                  hueLabel: l.hue,
                  lightnessLabel: l.lightness,
                  color: look.customMain,
                  onChanged: (c) => onChanged(look.copyWith(customMain: c)),
                ),
                if (mode != DoayaMode.black) ...[
                  SizedBox(height: DoayaSpacing.ml),
                  _ColorPicker(
                    label: l.background,
                    hueLabel: l.hue,
                    lightnessLabel: l.lightness,
                    color: mode == DoayaMode.light ? look.customLight : look.customDark,
                    onChanged: (c) => onChanged(
                      mode == DoayaMode.light
                          ? look.copyWith(customLight: c)
                          : look.copyWith(customDark: c),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
        gap(),
        _Section(
          title: l.details,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Slider(
                label: l.corners,
                value: look.radius,
                min: 0,
                max: 2,
                divisions: 8,
                onChanged: (v) => onChanged(look.copyWith(radius: v)),
              ),
              if (blurAvailable && look.style == DoayaStyle.glass)
                _Slider(
                  label: l.blur,
                  value: look.blur,
                  min: 0,
                  max: 30,
                  divisions: 15,
                  onChanged: (v) => onChanged(look.copyWith(blur: v)),
                ),
              SizedBox(height: DoayaSpacing.sm),
              Text(l.textSize, style: DoayaTypography.bodySmall),
              SizedBox(height: DoayaSpacing.xs),
              _Choices<double>(
                values: DoayaLook.textScales,
                names: l.textSizes,
                selected: look.textScale,
                onSelect: (v) => onChanged(look.copyWith(textScale: v)),
              ),
              SizedBox(height: DoayaSpacing.ml),
              Text(l.spacing, style: DoayaTypography.bodySmall),
              SizedBox(height: DoayaSpacing.xs),
              _Choices<double>(
                values: DoayaLook.densities,
                names: l.spacings,
                selected: look.density,
                onSelect: (v) => onChanged(look.copyWith(density: v)),
              ),
              SizedBox(height: DoayaSpacing.ml),
              Text(l.headingFont, style: DoayaTypography.bodySmall),
              SizedBox(height: DoayaSpacing.xs),
              _Choices<DoayaHeadingFont>(
                values: DoayaHeadingFont.values,
                names: l.headingFonts,
                selected: look.headingFont,
                onSelect: (v) => onChanged(look.copyWith(headingFont: v)),
              ),
            ],
          ),
        ),
        gap(),
        _Section(
          title: l.readability,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Ratio(label: l.sample, ratio: contrastRatio(p.textPrimary, p.bgMid)),
              _Ratio(
                label: l.mainColor,
                ratio: contrastRatio(p.accent, p.bgMid),
                note: p.accentAdjusted ? l.adjusted : null,
              ),
              _Ratio(label: l.sampleButton, ratio: contrastRatio(p.onSage, p.sageBottom)),
              SizedBox(height: DoayaSpacing.sm),
              Text(
                l.readable,
                style: DoayaTypography.caption.copyWith(color: DoayaColors.textSecondary),
              ),
            ],
          ),
        ),
        gap(),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: GlassPillButton(
            label: l.reset,
            size: PillSize.small,
            onPressed: look == const DoayaLook() ? null : () => onChanged(const DoayaLook()),
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.trailing});

  final String title;
  final String? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          Expanded(child: Text(title, style: DoayaTypography.titleSmall)),
          if (trailing != null)
            Text(
              trailing!,
              style: DoayaTypography.caption.copyWith(color: DoayaColors.textSecondary),
            ),
        ],
      ),
      SizedBox(height: DoayaSpacing.sm),
      child,
    ],
  );
}

class _Choices<T> extends StatelessWidget {
  const _Choices({
    required this.values,
    required this.names,
    required this.selected,
    required this.onSelect,
  });

  final List<T> values;
  final List<String> names;
  final T selected;
  final ValueChanged<T> onSelect;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: DoayaSpacing.sm,
    runSpacing: DoayaSpacing.sm,
    children: [
      for (final (i, v) in values.indexed)
        GlassPillButton(
          label: names[i],
          size: PillSize.small,
          selected: v == selected,
          onPressed: () => onSelect(v),
        ),
    ],
  );
}

class _StyleCard extends StatelessWidget {
  const _StyleCard({
    required this.style,
    required this.name,
    required this.note,
    required this.selected,
    required this.onTap,
  });

  final DoayaStyle style;
  final String name;
  final String note;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = DoayaAppearance.palette;
    // A tiny picture of the style, in the current colours.
    final mini = switch (style) {
      DoayaStyle.glass => BoxDecoration(
        color: p.glassFillStrong,
        border: Border.all(color: p.glassBorderStrong),
        borderRadius: BorderRadius.circular(DoayaSpacing.sm),
      ),
      DoayaStyle.flat => BoxDecoration(
        color: p.accent.withValues(alpha: .45),
        borderRadius: BorderRadius.circular(DoayaRadii.key),
      ),
      DoayaStyle.soft => BoxDecoration(
        color: p.accent.withValues(alpha: .3),
        borderRadius: BorderRadius.circular(DoayaRadii.imageWell),
        boxShadow: [
          BoxShadow(
            color: p.shadowStrong,
            blurRadius: DoayaSpacing.m,
            offset: Offset(0, DoayaSpacing.xs),
          ),
        ],
      ),
      DoayaStyle.outline => BoxDecoration(
        border: Border.all(
          color: p.textPrimary.withValues(alpha: .7),
          width: DoayaSizes.focusWidth,
        ),
        borderRadius: BorderRadius.circular(DoayaRadii.hairline),
      ),
      DoayaStyle.contrast => BoxDecoration(
        color: p.brightness == Brightness.light
            ? DoayaPalette.transparent
            : const Color(0xFF000000),
        border: Border.all(color: p.textPrimary, width: DoayaSizes.focusWidth),
        borderRadius: BorderRadius.circular(DoayaRadii.key),
      ),
    };
    return SizedBox(
      width: DoayaSizes.lookCardWidth,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(DoayaRadii.tile),
          child: GlassSurface(
            tone: selected ? SurfaceTone.selected : SurfaceTone.normal,
            borderRadius: BorderRadius.circular(DoayaRadii.tile),
            padding: EdgeInsets.all(DoayaSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: DoayaSizes.lookMiniHeight,
                  child: Center(
                    child: SizedBox(
                      width: DoayaSizes.lookMiniWidth,
                      height: DoayaSizes.lookMiniBar,
                      child: DecoratedBox(decoration: mini),
                    ),
                  ),
                ),
                SizedBox(height: DoayaSpacing.xs),
                Text(name, style: DoayaTypography.label),
                Text(
                  note,
                  maxLines: 2,
                  style: DoayaTypography.micro.copyWith(color: DoayaColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.back,
    required this.main,
    required this.tooltip,
    required this.selected,
    required this.onTap,
    this.custom = false,
  });

  final Color back;
  final Color main;
  final String tooltip;
  final bool selected;
  final bool custom;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: Semantics(
      button: true,
      selected: selected,
      label: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: DoayaSizes.swatch,
          height: DoayaSizes.swatch,
          decoration: BoxDecoration(
            color: back,
            borderRadius: BorderRadius.circular(DoayaRadii.key * 1.5),
            border: Border.all(
              color: selected ? DoayaColors.textPrimary : DoayaColors.divider,
              width: selected ? DoayaSizes.focusWidth : DoayaSizes.borderWidth,
            ),
          ),
          alignment: AlignmentDirectional.bottomStart,
          padding: EdgeInsets.all(DoayaSpacing.s),
          child: custom
              ? Icon(DoayaIcons.edit, size: DoayaSizes.iconS, color: main)
              : Container(
                  width: DoayaSizes.swatchDot,
                  height: DoayaSizes.swatchDot,
                  decoration: BoxDecoration(color: main, shape: BoxShape.circle),
                ),
        ),
      ),
    ),
  );
}

/// Hue and lightness sliders (no picker package): enough for a main
/// colour or a background.
class _ColorPicker extends StatelessWidget {
  const _ColorPicker({
    required this.label,
    required this.hueLabel,
    required this.lightnessLabel,
    required this.color,
    required this.onChanged,
  });

  final String label;
  final String hueLabel;
  final String lightnessLabel;
  final Color color;
  final ValueChanged<Color> onChanged;

  @override
  Widget build(BuildContext context) {
    final hsl = HSLColor.fromColor(color);
    final saturation = hsl.saturation < 0.25 ? 0.25 : hsl.saturation;
    return GlassSurface(
      borderRadius: BorderRadius.circular(DoayaRadii.tile),
      padding: EdgeInsets.all(DoayaSpacing.ml),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: DoayaSizes.colorDot,
                height: DoayaSizes.colorDot,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: DoayaColors.divider),
                ),
              ),
              SizedBox(width: DoayaSpacing.sm),
              Text(label, style: DoayaTypography.label),
            ],
          ),
          _Slider(
            label: hueLabel,
            value: hsl.hue,
            min: 0,
            max: 359,
            onChanged: (h) => onChanged(hsl.withHue(h).withSaturation(saturation).toColor()),
          ),
          _Slider(
            label: lightnessLabel,
            value: hsl.lightness,
            min: 0.04,
            max: 0.96,
            onChanged: (v) => onChanged(hsl.withLightness(v).withSaturation(saturation).toColor()),
          ),
        ],
      ),
    );
  }
}

class _Slider extends StatelessWidget {
  const _Slider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.divisions,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      SizedBox(
        width: DoayaSizes.sliderLabelWidth,
        child: Text(label, style: DoayaTypography.bodySmall),
      ),
      Expanded(
        child: Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: divisions,
          activeColor: DoayaColors.accent,
          inactiveColor: DoayaColors.divider,
          thumbColor: DoayaColors.accent,
          label: label,
          onChanged: onChanged,
        ),
      ),
    ],
  );
}

class _Ratio extends StatelessWidget {
  const _Ratio({required this.label, required this.ratio, this.note});

  final String label;
  final double ratio;
  final String? note;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: DoayaSpacing.xxs),
    child: Row(
      children: [
        Expanded(child: Text(label, style: DoayaTypography.bodySmall)),
        if (note != null) ...[
          Text(note!, style: DoayaTypography.caption.copyWith(color: DoayaColors.warningText)),
          SizedBox(width: DoayaSpacing.sm),
        ],
        Text(
          '${ratio.toStringAsFixed(1)} : 1',
          textDirection: TextDirection.ltr,
          style: DoayaTypography.label,
        ),
      ],
    ),
  );
}

/// A small sample of the look: a card, a button, a warning, a danger note.
class _Sample extends StatelessWidget {
  const _Sample({required this.labels});

  final DoayaLookLabels labels;

  @override
  Widget build(BuildContext context) => GlassSurface(
    tone: SurfaceTone.strong,
    blur: true,
    borderRadius: BorderRadius.circular(DoayaRadii.hero),
    padding: EdgeInsets.all(DoayaSpacing.xl),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(labels.sample, style: DoayaTypography.title),
        SizedBox(height: DoayaSpacing.sm),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: SagePillButton(label: labels.sampleButton, size: PillSize.small, onPressed: () {}),
        ),
        SizedBox(height: DoayaSpacing.ml),
        NoticeBanner(message: labels.sampleWarning, icon: DoayaIcons.warning),
        SizedBox(height: DoayaSpacing.sm),
        NoticeBanner(
          message: labels.sampleDanger,
          tone: StatusTone.danger,
          icon: DoayaIcons.danger,
        ),
      ],
    ),
  );
}
