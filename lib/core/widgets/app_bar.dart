import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wasteful/core/extensions/responsive_font.dart';
import 'package:wasteful/core/extensions/responsive_padding.dart';
import 'package:wasteful/core/theme/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onBack;
  final String title;
  final Widget? actionWidget;
  final bool showBack;
  final bool? centerTitle;

  const CustomAppBar({
    super.key,
    this.onBack,
    required this.title,
    this.actionWidget,
    this.showBack = true,
    this.centerTitle = true
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final height = MediaQuery.of(context).size.height * 0.3;

    return AppBar(
      toolbarHeight: height,
      automaticallyImplyLeading: true,
      backgroundColor: colors.background,
      foregroundColor: colors.inverseBackground,
      //elevation: 4,
      centerTitle: centerTitle,
      actionsPadding: EdgeInsets.symmetric(
        horizontal: context.padding(PaddingSize.small).horizontal,
        //vertical: context.padding(PaddingSize.medium).vertical,
      ),
      iconTheme: IconThemeData(
        color: colors.inverseBackground,
        size: 26,
      ),
      leading: showBack
        ? IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: onBack ?? () => Navigator.of(context).maybePop(),
          )
        : null,
      title: Text(
        title,
        style: TextStyle(
          fontFamily: GoogleFonts.lilitaOne().fontFamily,
          letterSpacing: 2,
          fontSize: context.fontSize(FontSize.large),
          color: colors.accent,
        ),
      ),
      actions: [
        if (actionWidget != null) actionWidget!,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}