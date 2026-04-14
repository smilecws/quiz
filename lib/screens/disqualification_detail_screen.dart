import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../models/disqualification_catalog.dart';
import '../theme/app_theme_colors.dart';
import '../utils/safe_external_url.dart';

class DisqualificationDetailScreen extends StatelessWidget {
  const DisqualificationDetailScreen({super.key, required this.catalog});

  final DisqualificationCatalog catalog;

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.tryParse(url.trim());
    if (uri == null || !isAllowedDisqualificationSourceUri(uri)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).linkOpenFailed)),
        );
      }
      return;
    }
    try {
      var ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) {
        ok = await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).linkOpenFailed)),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).linkOpenFailed)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: context.appColors.background,
        appBar: AppBar(
          title: Text(l10n.disqualificationScreenTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.disqualificationTabFunction),
              Tab(text: l10n.disqualificationTabRoad),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _DrivingTab(
              catalog: catalog,
              onSourceTap: catalog.drivingSource.isNotEmpty
                  ? () => _openUrl(context, catalog.drivingSource)
                  : null,
              sourceLabel: l10n.disqualificationSourceLink,
            ),
            _RoadTab(
              catalog: catalog,
              onSourceTap: catalog.roadSource.isNotEmpty
                  ? () => _openUrl(context, catalog.roadSource)
                  : null,
              sourceLabel: l10n.disqualificationSourceLink,
            ),
          ],
        ),
      ),
    );
  }
}

class _DrivingTab extends StatelessWidget {
  const _DrivingTab({
    required this.catalog,
    required this.onSourceTap,
    required this.sourceLabel,
  });

  final DisqualificationCatalog catalog;
  final VoidCallback? onSourceTap;
  final String sourceLabel;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        if (catalog.drivingTitle.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              catalog.drivingTitle,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: context.appColors.textPrimary,
              ),
            ),
          ),
        if (onSourceTap != null)
          TextButton.icon(
            onPressed: onSourceTap,
            icon: const Icon(Icons.open_in_new, size: 18),
            label: Text(sourceLabel),
            style: TextButton.styleFrom(
              foregroundColor: context.appColors.primaryDark,
              alignment: Alignment.centerLeft,
            ),
          ),
        const SizedBox(height: 8),
        ...catalog.drivingCategories.expand((cat) {
          return [
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Text(
                cat.licenseType,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: context.appColors.textPrimary,
                ),
              ),
            ),
            ...cat.criteria.map(
              (c) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 28,
                      child: Text(
                        '${c.number}.',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: context.appColors.primaryDark,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        c.text,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.45,
                          color: context.appColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ];
        }),
      ],
    );
  }
}

class _RoadTab extends StatelessWidget {
  const _RoadTab({
    required this.catalog,
    required this.onSourceTap,
    required this.sourceLabel,
  });

  final DisqualificationCatalog catalog;
  final VoidCallback? onSourceTap;
  final String sourceLabel;

  @override
  Widget build(BuildContext context) {
    final types = catalog.roadApplicableTypes;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        if (catalog.roadTitle.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              catalog.roadTitle,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: context.appColors.textPrimary,
              ),
            ),
          ),
        if (types.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              types.join(', '),
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: context.appColors.textSecondary,
              ),
            ),
          ),
        if (onSourceTap != null)
          TextButton.icon(
            onPressed: onSourceTap,
            icon: const Icon(Icons.open_in_new, size: 18),
            label: Text(sourceLabel),
            style: TextButton.styleFrom(
              foregroundColor: context.appColors.primaryDark,
              alignment: Alignment.centerLeft,
            ),
          ),
        const SizedBox(height: 8),
        ...catalog.roadItems.map(
          (c) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    '${c.number}.',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: context.appColors.primaryDark,
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    c.text,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: context.appColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
