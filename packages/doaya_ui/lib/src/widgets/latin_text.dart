import 'package:flutter/widgets.dart';

/// Left-to-right isolate marks. Wrap a Latin run (e.g. a drug name) that sits
/// *inside* an Arabic sentence so punctuation and digits stay in place.
const _lri = '\u2066';
const _pdi = '\u2069';

/// Returns [text] wrapped in LTR isolate marks, for embedding Latin script in
/// an RTL string: `'${l10n.alternativeFor} ${ltrIsolate(name)}'`.
String ltrIsolate(String text) => '$_lri$text$_pdi';

/// A standalone Latin-script label (drug names, barcodes, keyboard keys).
///
/// Renders left-to-right, but aligns to the *start* of the surrounding layout
/// (right side in RTL), which is what the mockups do.
class LatinText extends StatelessWidget {
  const LatinText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
    this.textAlign,
  });

  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow overflow;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final ambient = Directionality.maybeOf(context) ?? TextDirection.rtl;
    return Text(
      text,
      style: style,
      maxLines: maxLines,
      overflow: overflow,
      textDirection: TextDirection.ltr,
      textAlign: textAlign ?? (ambient == TextDirection.rtl ? TextAlign.right : TextAlign.left),
    );
  }
}
