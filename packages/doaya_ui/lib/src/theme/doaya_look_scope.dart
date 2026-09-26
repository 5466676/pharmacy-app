import 'package:flutter/widgets.dart';

import 'doaya_appearance.dart';
import 'doaya_look.dart';

/// Puts [look] in force for everything below (and above: `DoayaColors`
/// are global), and rebuilds the whole app, state kept, when it changes or
/// when «تلقائي» follows the device from day to night. Put it above the
/// `MaterialApp`, and wrap the app's content with [textScaled].
class DoayaLookScope extends StatefulWidget {
  const DoayaLookScope({super.key, required this.look, required this.child});

  final DoayaLook look;
  final Widget child;

  /// The user's text size on top of the device's own.
  static Widget textScaled(BuildContext context, Widget child) {
    final mq = MediaQuery.of(context);
    final scale = DoayaAppearance.look.textScale;
    if (scale == 1) return child;
    return MediaQuery(
      data: mq.copyWith(textScaler: _Scaled(mq.textScaler, scale)),
      child: child,
    );
  }

  @override
  State<DoayaLookScope> createState() => _DoayaLookScopeState();
}

class _DoayaLookScopeState extends State<DoayaLookScope> with WidgetsBindingObserver {
  Brightness get _platform => WidgetsBinding.instance.platformDispatcher.platformBrightness;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    DoayaAppearance.apply(widget.look, platform: _platform);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didUpdateWidget(DoayaLookScope old) {
    super.didUpdateWidget(old);
    if (DoayaAppearance.apply(widget.look, platform: _platform)) _rebuildAll();
  }

  @override
  void didChangePlatformBrightness() {
    if (widget.look.mode == DoayaMode.auto &&
        DoayaAppearance.apply(widget.look, platform: _platform)) {
      _rebuildAll();
    }
  }

  /// Colours are read in build methods: rebuild every element (as hot
  /// reload does), keeping all state.
  void _rebuildAll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      void mark(Element e) {
        e.markNeedsBuild();
        e.visitChildren(mark);
      }

      if (mounted) (context as Element).visitChildren(mark);
    });
    WidgetsBinding.instance.scheduleFrame();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _Scaled extends TextScaler {
  const _Scaled(this.base, this.factor);

  final TextScaler base;
  final double factor;

  @override
  double scale(double fontSize) => base.scale(fontSize) * factor;

  @override
  // ignore: deprecated_member_use
  double get textScaleFactor => base.textScaleFactor * factor;

  @override
  bool operator ==(Object other) =>
      other is _Scaled && other.base == base && other.factor == factor;

  @override
  int get hashCode => Object.hash(base, factor);
}
