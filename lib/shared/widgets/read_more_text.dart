import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

enum TrimMode {
  length,
  line,
}

class ReadMoreText extends StatefulWidget {
  final String data;
  final String showLessText;
  final String seeMoreText;
  final int maxCharsLength;
  final int maxLines;
  final TrimMode trimMode;
  final TextStyle textStyle;
  final TextDirection? textDirection;
  final TextStyle? linkStyle;
  final VoidCallback? onExpansionChanged;
  final bool useAnimation;
  final Duration animationDuration;
  final bool trimCollapsedText;

  const ReadMoreText(
    this.data, {
    super.key,
    this.showLessText = "show less",
    this.seeMoreText = "see more",
    this.maxCharsLength = 240,
    this.maxLines = 2,
    this.trimMode = TrimMode.length,
    required this.textStyle,
    this.textDirection,
    this.linkStyle,
    this.onExpansionChanged,
    this.useAnimation = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.trimCollapsedText = true,
  });

  @override
  ReadMoreTextState createState() => ReadMoreTextState();
}

const String _kEllipsis = '\u2026';
const String _kLineSeparator = '\u2028';

class ReadMoreTextState extends State<ReadMoreText>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapLink() {
    if (widget.data.isEmpty) return;

    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });

    widget.onExpansionChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    // Handle empty data
    if (widget.data.trim().isEmpty) {
      return Text(
        'No content available',
        style: widget.textStyle.copyWith(
          color: AppColors.textGrey,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);
    TextStyle effectiveTextStyle = widget.textStyle;
    if (widget.textStyle.inherit) {
      effectiveTextStyle = defaultTextStyle.style.merge(widget.textStyle);
    }

    const textAlign = TextAlign.justify;
    final textDirection = widget.textDirection ?? Directionality.of(context);
    final overflow = defaultTextStyle.overflow;

    // Default link style uses AppColors for consistency
    final linkStyle = widget.linkStyle ??
        TextStyle(
          color: AppColors.primaryBlue,
          fontSize: effectiveTextStyle.fontSize ?? 14,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.none,
        );

    TextSpan link = TextSpan(
      text: _isExpanded ? widget.showLessText : widget.seeMoreText,
      style: linkStyle,
      recognizer: TapGestureRecognizer()..onTap = _onTapLink,
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        assert(constraints.hasBoundedWidth);
        TextPainter textPainter = TextPainter(
          text: link,
          textAlign: textAlign,
          textDirection: textDirection,
          maxLines: widget.maxLines,
          ellipsis: overflow == TextOverflow.ellipsis ? _kEllipsis : null,
        );
        textPainter.layout(
            minWidth: constraints.minWidth, maxWidth: constraints.maxWidth);
        final linkSize = textPainter.size;
        textPainter.text =
            TextSpan(style: effectiveTextStyle, text: widget.data);
        textPainter.layout(
            minWidth: constraints.minWidth, maxWidth: constraints.maxWidth);
        final textSize = textPainter.size;
        bool linkLongerThanLine = false;
        int endIndex;
        if (linkSize.width < constraints.maxWidth) {
          final pos = textPainter.getPositionForOffset(Offset(
            textSize.width - linkSize.width,
            textSize.height,
          ));
          endIndex = textPainter.getOffsetBefore(pos.offset) ?? 0;
        } else {
          var pos = textPainter
              .getPositionForOffset(textSize.bottomLeft(Offset.zero));
          endIndex = pos.offset;
          linkLongerThanLine = true;
        }

        TextSpan textSpan;
        bool shouldShowLink = false;

        switch (widget.trimMode) {
          case TrimMode.length:
            if (widget.maxCharsLength < widget.data.length) {
              shouldShowLink = true;
              textSpan = TextSpan(
                style: effectiveTextStyle,
                text: _isExpanded
                    ? widget.data
                    : (widget.trimCollapsedText
                        ? widget.data.substring(0, widget.maxCharsLength) +
                            _kEllipsis
                        : widget.data),
                children: <TextSpan>[link],
              );
            } else {
              textSpan = TextSpan(style: effectiveTextStyle, text: widget.data);
            }
            break;
          case TrimMode.line:
            if (textPainter.didExceedMaxLines) {
              shouldShowLink = true;
              textSpan = TextSpan(
                style: effectiveTextStyle,
                text: _isExpanded
                    ? widget.data
                    : (widget.trimCollapsedText
                        ? widget.data.substring(0, endIndex) +
                            (linkLongerThanLine ? _kLineSeparator : '')
                        : widget.data),
                children: <TextSpan>[link],
              );
            } else {
              textSpan = TextSpan(style: effectiveTextStyle, text: widget.data);
            }
            break;
        }

        Widget richText = RichText(
          textAlign: textAlign,
          textDirection: textDirection,
          softWrap: true,
          overflow: TextOverflow.clip,
          text: textSpan,
        );

        // Wrap with animation if enabled
        if (widget.useAnimation && shouldShowLink) {
          richText = FadeTransition(
            opacity: _fadeAnimation,
            child: richText,
          );
        }

        return richText;
      },
    );
  }
}
