import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../services/consent_log_service.dart';
import '../services/consent_service.dart';
import '../theme/app_theme_colors.dart';

/// 첫 실행 게이트. 이름 입력 + 동의 체크 2개 만족해야 통과.
///
/// 동의 시점에 [ConsentLogService] 가 Google Form 으로 이름·일자를 익명 POST 한다
/// (fire-and-forget). 로컬에는 sub/email 없이 name·grantedAt·version 만 저장.
class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key, required this.onGranted});

  final ValueChanged<ConsentRecord> onGranted;

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _collectionAgreed = false;
  bool _thirdPartyAgreed = false;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleAgree() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_collectionAgreed || !_thirdPartyAgreed) return;

    setState(() => _submitting = true);
    final name = _nameController.text.trim();
    final record = ConsentRecord(
      name: name,
      grantedAt: DateTime.now().toUtc(),
      version: ConsentService.currentVersion,
    );

    // 로컬 저장이 우선 — 네트워크 실패해도 동의 자체는 저장.
    await ConsentService.save(record);
    // Google Form 전송은 fire-and-forget. 실패해도 게이트는 통과.
    // ignore: discarded_futures
    ConsentLogService.submitConsent(
      name: name,
      grantedAtUtc: record.grantedAt,
    );

    if (!mounted) return;
    widget.onGranted(record);
  }

  Future<void> _handleDecline() async {
    final l10n = AppLocalizations.of(context);
    final exit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.consentExitDialogTitle),
        content: Text(l10n.consentExitDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.consentExitCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.consentExitConfirm),
          ),
        ],
      ),
    );
    if (exit == true) {
      await SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    final canSubmit = _collectionAgreed &&
        _thirdPartyAgreed &&
        _nameController.text.trim().isNotEmpty &&
        !_submitting;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.consentTitle,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _PrivacyTableSection(
                    title: l10n.consentCollectionTitle,
                    rows: l10n.consentCollectionRows,
                  ),
                  const SizedBox(height: 16),
                  _PrivacyTableSection(
                    title: l10n.consentThirdPartyTitle,
                    rows: l10n.consentThirdPartyRows,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.consentRightToRefuse,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    enabled: !_submitting,
                    maxLength: 30,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: l10n.consentNameLabel,
                      hintText: l10n.consentNameHint,
                      filled: true,
                      fillColor: colors.surfaceWhite,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colors.borderLight),
                      ),
                    ),
                    validator: (value) {
                      final v = value?.trim() ?? '';
                      if (v.isEmpty) return l10n.consentNameRequired;
                      if (v.length > 30) return l10n.consentNameTooLong;
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    value: _collectionAgreed,
                    onChanged: _submitting
                        ? null
                        : (v) =>
                            setState(() => _collectionAgreed = v ?? false),
                    title: Text(
                      l10n.consentCollectionAgreeCheckbox,
                      style: TextStyle(color: colors.textPrimary),
                    ),
                    activeColor: colors.primary,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  CheckboxListTile(
                    value: _thirdPartyAgreed,
                    onChanged: _submitting
                        ? null
                        : (v) =>
                            setState(() => _thirdPartyAgreed = v ?? false),
                    title: Text(
                      l10n.consentThirdPartyAgreeCheckbox,
                      style: TextStyle(color: colors.textPrimary),
                    ),
                    activeColor: colors.primary,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: canSubmit ? _handleAgree : null,
                    child: _submitting
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.onPrimary,
                            ),
                          )
                        : Text(
                            l10n.consentAgreeButton,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _submitting ? null : _handleDecline,
                    child: Text(
                      l10n.consentDeclineButton,
                      style: TextStyle(color: colors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PrivacyTableSection extends StatelessWidget {
  const _PrivacyTableSection({required this.title, required this.rows});

  final String title;
  final List<({String label, String value})> rows;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: colors.borderLight),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Table(
              columnWidths: const {
                0: IntrinsicColumnWidth(),
                1: FlexColumnWidth(),
              },
              border: TableBorder.symmetric(
                inside: BorderSide(color: colors.borderLight, width: 0.5),
              ),
              children: [
                for (final row in rows)
                  TableRow(
                    children: [
                      Container(
                        color: colors.chipBg,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        child: Text(
                          row.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        color: colors.surfaceWhite,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        child: Text(
                          row.value,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
