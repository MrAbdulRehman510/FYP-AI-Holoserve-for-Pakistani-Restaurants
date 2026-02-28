import 'package:flutter/material.dart';
import 'app_theme.dart';

class StandardToolbar {
  static PreferredSizeWidget build(
    BuildContext context,
    String title, {
    IconData? actionIcon,
    VoidCallback? onActionPressed,
  }) {
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 90,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.appBarGradient(context),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: AppTheme.primaryTextColor(context),
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryTextColor(context),
                  ),
                ),
                const Spacer(),
                if (actionIcon != null)
                  IconButton(
                    icon: Icon(actionIcon, color: AppTheme.accentColor(context)),
                    onPressed: onActionPressed ?? () {},
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}