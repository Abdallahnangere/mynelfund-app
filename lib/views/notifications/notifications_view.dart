import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_translations.dart';
import '../../core/theme/nelfund_colors.dart';
import '../../core/theme/nelfund_typography.dart';
import '../../models/notification_model.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/apple_frosted_card.dart';
import '../../widgets/liquid_glass_header.dart';

/// Full-screen official bulletins and notification center for My NELFund.
///
/// Features real-time Firestore synchronization, local offline cache persistence,
/// unread status management, and instant search filtering.
class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<NotificationProvider>(context, listen: false).syncRemote();
      }
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<NotificationItem> _filterNotifications(List<NotificationItem> list) {
    if (_searchQuery.isEmpty) return list;
    return list.where((item) {
      return item.title.toLowerCase().contains(_searchQuery) ||
          item.body.toLowerCase().contains(_searchQuery) ||
          (item.titleHa?.toLowerCase().contains(_searchQuery) ?? false) ||
          (item.bodyHa?.toLowerCase().contains(_searchQuery) ?? false) ||
          item.badge.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppTranslations.of(context);
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final notifProv = Provider.of<NotificationProvider>(context);

    final allItems = notifProv.notifications;
    final filtered = _filterNotifications(allItems);
    final unreadCount = notifProv.unreadCount;

    return CupertinoPageScaffold(
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            LiquidGlassHeader(
              title: tr.notificationsViewTitle,
              subtitle: tr.notificationsSubtitle,
              leading: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: CupertinoDynamicColor.resolve(
                      const CupertinoDynamicColor.withBrightness(
                        color: Color(0xFFF0F4F1),
                        darkColor: Color(0xFF242C26),
                      ),
                      context,
                    ),
                    border: Border.all(
                      color: NelfundColors.emerald.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      CupertinoIcons.back,
                      size: 20,
                      color: NelfundColors.emerald,
                    ),
                  ),
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (unreadCount > 0) ...[
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        notifProv.markAllAsRead();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: NelfundColors.emerald.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: NelfundColors.emerald.withValues(alpha: 0.35),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              CupertinoIcons.checkmark_circle_fill,
                              size: 14,
                              color: NelfundColors.emerald,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              tr.markAllReadLabel,
                              style: NelfundTypography.captionBold.copyWith(
                                color: NelfundColors.emerald,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    onPressed: notifProv.isLoading
                        ? null
                        : () async {
                            HapticFeedback.mediumImpact();
                            await notifProv.refresh();
                          },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: NelfundColors.emerald.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: NelfundColors.emerald.withValues(alpha: 0.25),
                          width: 0.8,
                        ),
                      ),
                      child: Center(
                        child: notifProv.isLoading
                            ? const CupertinoActivityIndicator(radius: 7)
                            : const Icon(
                                CupertinoIcons.arrow_clockwise,
                                size: 15,
                                color: NelfundColors.emerald,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              bottom: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: CupertinoSearchTextField(
                  controller: _searchController,
                  placeholder: tr.searchNotificationsPlaceholder,
                  style: TextStyle(
                    color: CupertinoDynamicColor.resolve(
                      NelfundColors.label,
                      context,
                    ),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  CupertinoSliverRefreshControl(
                    onRefresh: () async {
                      HapticFeedback.lightImpact();
                      await notifProv.refresh();
                    },
                  ),
                  if (filtered.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmptyState(context, tr, isDark),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = filtered[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildNotificationCard(
                                context,
                                item: item,
                                isDark: isDark,
                                onTap: () {
                                  if (!item.isRead) {
                                    HapticFeedback.selectionClick();
                                    notifProv.markAsRead(item.id);
                                  }
                                },
                              ),
                            );
                          },
                          childCount: filtered.length,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    AppTranslations tr,
    bool isDark,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: NelfundColors.emerald.withValues(alpha: 0.10),
                border: Border.all(
                  color: NelfundColors.emerald.withValues(alpha: 0.25),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                CupertinoIcons.bell_slash,
                size: 34,
                color: NelfundColors.emerald,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              tr.notificationsEmptyTitle,
              textAlign: TextAlign.center,
              style: NelfundTypography.title3.copyWith(
                fontWeight: FontWeight.w600,
                color: CupertinoDynamicColor.resolve(
                  NelfundColors.label,
                  context,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              tr.notificationsEmptyDesc,
              textAlign: TextAlign.center,
              style: NelfundTypography.footnote.copyWith(
                color: CupertinoDynamicColor.resolve(
                  NelfundColors.secondaryLabel,
                  context,
                ),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context, {
    required NotificationItem item,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final tr = AppTranslations.of(context);
    final badgeColor = item.badgeColor;
    final displayTitle = item.getLocalizedTitle(tr.isHausa);
    final displayBody = item.getLocalizedBody(tr.isHausa);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AppleFrostedCard(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.all(16),
        borderColor: !item.isRead
            ? NelfundColors.emerald.withValues(alpha: 0.55)
            : NelfundColors.emerald.withValues(alpha: 0.15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.badge,
                        style: NelfundTypography.captionBold.copyWith(
                          color: badgeColor,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    if (!item.isRead) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: NelfundColors.emerald,
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  item.timestamp.isNotEmpty
                      ? item.timestamp
                      : '${item.createdAt.day}/${item.createdAt.month}/${item.createdAt.year}',
                  style: NelfundTypography.caption.copyWith(
                    color: CupertinoDynamicColor.resolve(
                      NelfundColors.secondaryLabel,
                      context,
                    ),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              displayTitle,
              style: NelfundTypography.headline.copyWith(
                fontWeight: !item.isRead ? FontWeight.w600 : FontWeight.w500,
                color: CupertinoDynamicColor.resolve(
                  NelfundColors.label,
                  context,
                ),
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              displayBody,
              style: NelfundTypography.subhead.copyWith(
                color: CupertinoDynamicColor.resolve(
                  NelfundColors.secondaryLabel,
                  context,
                ),
                height: 1.45,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
