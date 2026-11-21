import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../app/app.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/theme/nelfund_colors.dart';
import '../../../../shared/widgets/liquid_glass_header.dart';
import '../../domain/notification_model.dart';
import '../providers/notification_provider.dart';
import '../widgets/notification_card.dart';
import '../widgets/notification_empty_state.dart';

/// Official Bulletins & Alerts center displaying locally cached and Firestore
/// synchronized announcements with instant search Filtering.
class NotificationsView extends StatelessWidget {
  /// Creates a [NotificationsView].
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProv = AppProviders.maybeRead<LocaleProvider>(context);
    final notifProv = AppProviders.maybeRead<NotificationProvider>(context);

    if (localeProv == null || notifProv == null) {
      return MultiProvider(
        providers: [
          if (localeProv == null)
            ChangeNotifierProvider<LocaleProvider>(
              create: (_) => LocaleProvider(),
            ),
          if (notifProv == null)
            ChangeNotifierProvider<NotificationProvider>(
              create: (_) => NotificationProvider(),
            ),
        ],
        child: const _NotificationsViewContent(),
      );
    }

    return const _NotificationsViewContent();
  }
}

class _NotificationsViewContent extends StatefulWidget {
  const _NotificationsViewContent();

  @override
  State<_NotificationsViewContent> createState() =>
      _NotificationsViewContentState();
}

class _NotificationsViewContentState extends State<_NotificationsViewContent> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<NotificationItem> _filterItems(
    List<NotificationItem> source,
    bool isHausa,
  ) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return source;
    }
    return source.where((item) {
      final title = item.getLocalizedTitle(isHausa).toLowerCase();
      final body = item.getLocalizedBody(isHausa).toLowerCase();
      final badge = item.badge.toLowerCase();
      return title.contains(query) ||
          body.contains(query) ||
          badge.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppTranslations.of(context);
    final notifProv = context.watch<NotificationProvider>();
    final items = _filterItems(notifProv.notifications, tr.isHausa);

    return CupertinoPageScaffold(
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            LiquidGlassHeader(
              title: tr.notificationsViewTitle,
              subtitle: tr.notificationsSubtitle,
              showBackButton: true,
              trailing: notifProv.hasUnread
                  ? CupertinoButton(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      minimumSize: Size.zero,
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        notifProv.markAllAsRead();
                      },
                      child: Text(
                        tr.markAllReadLabel,
                        style: const TextStyle(
                          color: NelfundColors.emerald,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : CupertinoButton(
                      padding: const EdgeInsets.all(6),
                      minimumSize: const Size(34, 34),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        notifProv.refresh();
                      },
                      child: const Icon(
                        CupertinoIcons.arrow_clockwise,
                        color: NelfundColors.emerald,
                        size: 20,
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: CupertinoSearchTextField(
                controller: _searchController,
                placeholder: tr.searchNotificationsPlaceholder,
                onChanged: (value) => setState(() => _searchQuery = value),
                backgroundColor: CupertinoDynamicColor.resolve(
                  const CupertinoDynamicColor.withBrightness(
                    color: Color(0xFFE9F0EC),
                    darkColor: Color(0xFF1D2420),
                  ),
                  context,
                ),
                borderRadius: BorderRadius.circular(14),
                padding: const EdgeInsetsDirectional.fromSTEB(4, 11, 10, 11),
              ),
            ),
            Expanded(
              child: notifProv.isLoading && items.isEmpty
                  ? const Center(child: CupertinoActivityIndicator(radius: 13))
                  : items.isEmpty
                  ? SingleChildScrollView(
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      child: NotificationEmptyState(
                        title: tr.notificationsEmptyTitle,
                        description: tr.notificationsEmptyDesc,
                        isHausa: tr.isHausa,
                        onRefresh: notifProv.refresh,
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(0, 6, 0, 96),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return NotificationCard(
                          item: item,
                          isHausa: tr.isHausa,
                          openPortalLabel: tr.buttonOpenPortal,
                          onTap: () => notifProv.markAsRead(item.id),
                          onDelete: () =>
                              notifProv.deleteNotificationLocally(item.id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
