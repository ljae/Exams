import 'package:flutter/material.dart';
import 'package:world_math/models/models.dart';
import '../theme.dart';
import '../services/firestore_service.dart';
import 'app_logo.dart';

class WorldMathAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final bool showUserProfile;

  const WorldMathAppBar({
    super.key,
    required this.title,
    this.titleWidget,
    this.actions,
    this.showUserProfile = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppTheme.paperColor,
            AppTheme.primaryColor.withAlpha((255 * 0.05).toInt()),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.05).toInt()),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Calculate available width for logo
              // Reserve space for Title/Nav (Calendar=72 + Arrows + Spacing ~150) + Profile (~100) + Spacing
              final availableWidth = constraints.maxWidth;
              final reservedWidth = 260.0; 
              final maxLogoWidth = (availableWidth - reservedWidth).clamp(0.0, 250.0);

              return Row(
                children: [
                  // Logo Area - Scaled
                  if (maxLogoWidth > 0)
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxLogoWidth),
                      child: const AspectRatio(
                        aspectRatio: 1.0,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          alignment: Alignment.centerLeft,
                          child: AppLogo(size: 250),
                        ),
                      ),
                    ),
                  if (maxLogoWidth > 0)
                    const SizedBox(width: 4),

                  // Title Area
                  Expanded(
                    child: titleWidget ?? Text(
                      title,
                      style: Theme.of(context).appBarTheme.titleTextStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Actions / User Profile
                  if (showUserProfile) ...[
                    const SizedBox(width: 4),
                    _buildUserProfile(context),
                  ],
                  if (actions != null) ...actions!,
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context) {
    // For now, we'll use a mock user ID.
    final userId = 'mock_user_id';
    
    return FutureBuilder<User?>(
      future: FirestoreService().getUser(userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(width: 100);
        }
        final user = snapshot.data!;
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primaryColor.withAlpha((255 * 0.3).toInt()),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 16,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  user.nickname,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppTheme.textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              user.schoolName,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100);
}
