import 'package:flutter/material.dart';
import 'package:wasteful/core/extensions/responsive_font.dart';
import 'package:wasteful/core/extensions/responsive_padding.dart';
import 'package:wasteful/core/theme/app_colors.dart';


class SectionCard extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  final Widget? actionButton;

  final EdgeInsets? contentPadding;
  final EdgeInsets margin;

  final double radius;
  final double depth;

  final Color? backgroundColor;
  final Color? titleColor;

  const SectionCard({
    super.key,
    this.title,
    required this.children,
    this.actionButton,
    this.contentPadding,
    this.margin = const EdgeInsets.symmetric(vertical: 12),
    this.radius = 22,
    this.depth = 8,
    this.backgroundColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final contentPad = contentPadding ?? context.padding(PaddingSize.small);
    final colors = context.colors;

    return Container(
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ✅ Title strip
          Row( 
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              if (title != null) ... [
                Container(
                  padding: context.padding(PaddingSize.medium),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(radius),
                      topRight: Radius.circular(radius),
                    ),
                    border: Border.all(
                      color: colors.border,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    title!,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: context.fontSize(FontSize.large),
                      color: titleColor ?? colors.textPrimary, // theme-aware
                    ),
                  ),
                ),
              ],

              if (actionButton != null) actionButton!,
            ],

          ),
          

          // ✅ Body with 3D bottom
          Padding(
            padding: EdgeInsets.only(bottom: depth),
            child: Container(
              padding: contentPad,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(radius),
                  bottomRight: Radius.circular(radius),
                  topRight: Radius.circular(radius),
                ),
                border: Border.all(
                  color: colors.border,
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _withDividers(context, children),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _withDividers(BuildContext context, List<Widget> items) {
    final colors = context.colors;
    final list = <Widget>[];

    for (int i = 0; i < items.length; i++) {
      list.add(items[i]);
      if (i != items.length - 1) {
        list.add(
          Divider(
            height: 16,
            thickness: 1,
            color: colors.divider,
          ),
        );
      }
    }
    return list;
  }
}