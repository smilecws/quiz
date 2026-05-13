import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

// 슬라이드별 색상 팔레트 — sample_eco/eco_driving_rich_v2.html 충실 재현.
// 1회용 인트로 전용이라 전역 AppThemeColors 를 오염시키지 않고 여기에 격리.
const _kS1Bg = Color(0xFFEAF3DE);
const _kS1Accent = Color(0xFF639922);
const _kS1Title = Color(0xFF173404);
const _kS1Body = Color(0xFF27500A);
const _kS1Soft = Color(0xFF3B6D11);

const _kS2Bg = Color(0xFFE1F5EE);
const _kS2Accent = Color(0xFF1D9E75);
const _kS2Title = Color(0xFF04342C);
const _kS2Body = Color(0xFF04342C);
const _kS2Soft = Color(0xFF0F6E56);
const _kS2KpiBody = Color(0xFF085041);
const _kS2OnAccent = Color(0xFFC0E8DA);

const _kS3Bg = Color(0xFFE6F1FB);
const _kS3Accent = Color(0xFF378ADD);
const _kS3Title = Color(0xFF042C53);
const _kS3Soft = Color(0xFF185FA5);
const _kS3OnAccent = Color(0xFFB5D4F4);

const _kSlideBgs = [_kS1Bg, _kS2Bg, _kS3Bg];
const _kSlideAccents = [_kS1Accent, _kS2Accent, _kS3Accent];
const _kPageCount = 3;

/// 동의 완료 후 1회 노출되는 친환경 운전 교육 인트로.
/// 3개 슬라이드(정의 / 효과 / 실천 10계명)를 PageView 로 가로 스와이프.
/// 마지막 슬라이드의 "시작하기" 버튼이 [onDone] 을 호출한다.
class EcoIntroScreen extends StatefulWidget {
  const EcoIntroScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<EcoIntroScreen> createState() => _EcoIntroScreenState();
}

class _EcoIntroScreenState extends State<EcoIntroScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goPrev() {
    if (_page == 0) return;
    _controller.previousPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  void _goNext() {
    if (_page >= _kPageCount - 1) {
      widget.onDone();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  void _jumpTo(int i) {
    if (i == _page) return;
    _controller.animateToPage(
      i,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final accent = _kSlideAccents[_page];
    final bg = _kSlideBgs[_page];
    final isLast = _page == _kPageCount - 1;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              page: _page,
              accent: accent,
              onPrev: _goPrev,
              onNext: _goNext,
              onDotTap: _jumpTo,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: const [
                  _DefinitionSlide(),
                  _EffectSlide(),
                  _ActionSlide(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: _goNext,
                  child: Text(
                    isLast ? loc.ecoIntroBtnStart : loc.ecoIntroBtnNext,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.page,
    required this.accent,
    required this.onPrev,
    required this.onNext,
    required this.onDotTap,
  });

  final int page;
  final Color accent;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final void Function(int) onDotTap;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          _CircleIconButton(
            icon: Icons.chevron_left,
            tooltip: loc.ecoIntroBtnPrev,
            onTap: page == 0 ? null : onPrev,
          ),
          const Spacer(),
          for (int i = 0; i < _kPageCount; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: GestureDetector(
                onTap: () => onDotTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: i == page ? 24 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == page ? accent : Colors.black26,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          const Spacer(),
          _CircleIconButton(
            icon: Icons.chevron_right,
            tooltip: loc.ecoIntroBtnNext,
            onTap: page >= _kPageCount - 1 ? null : onNext,
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return SizedBox(
      width: 36,
      height: 36,
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(
          side: BorderSide(color: Color(0xFFE5E7EB), width: 0.5),
        ),
        child: Tooltip(
          message: tooltip,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Icon(
              icon,
              size: 20,
              color: enabled ? Colors.black87 : Colors.black26,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── 슬라이드 1: DEFINITION ────────────────────────────────────────────
class _DefinitionSlide extends StatelessWidget {
  const _DefinitionSlide();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Badge(text: loc.ecoIntroS1Badge, color: _kS1Accent),
              Text(
                loc.ecoIntroS1TopLabel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _kS1Soft,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Icon(Icons.eco, size: 36, color: _kS1Accent),
          const SizedBox(height: 10),
          Text(
            loc.ecoIntroS1Title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: _kS1Title,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            loc.ecoIntroS1Subtitle,
            style: const TextStyle(fontSize: 12, color: _kS1Soft),
          ),
          const SizedBox(height: 12),
          Text(
            loc.ecoIntroS1Body,
            style: const TextStyle(
              fontSize: 13,
              color: _kS1Body,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          _WhiteCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.ecoIntroS1PrincipleSectionTitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _kS1Soft,
                  ),
                ),
                const SizedBox(height: 8),
                _PrincipleRow(
                  label: loc.ecoIntroS1Principle1Label,
                  body: loc.ecoIntroS1Principle1Body,
                ),
                const SizedBox(height: 6),
                _PrincipleRow(
                  label: loc.ecoIntroS1Principle2Label,
                  body: loc.ecoIntroS1Principle2Body,
                ),
                const SizedBox(height: 6),
                _PrincipleRow(
                  label: loc.ecoIntroS1Principle3Label,
                  body: loc.ecoIntroS1Principle3Body,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _WhiteCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.ecoIntroS1WhyTitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _kS1Soft,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  loc.ecoIntroS1WhyBody,
                  style: const TextStyle(
                    fontSize: 12,
                    color: _kS1Body,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final tag in [
                loc.ecoIntroS1Tag1,
                loc.ecoIntroS1Tag2,
                loc.ecoIntroS1Tag3,
                loc.ecoIntroS1Tag4,
              ])
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(fontSize: 11, color: _kS1Body),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrincipleRow extends StatelessWidget {
  const _PrincipleRow({required this.label, required this.body});
  final String label;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 64,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _kS1Accent,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            body,
            style: const TextStyle(
              fontSize: 12,
              color: _kS1Body,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _WhiteCard extends StatelessWidget {
  const _WhiteCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─── 슬라이드 2: EFFECT ────────────────────────────────────────────────
class _EffectSlide extends StatelessWidget {
  const _EffectSlide();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Badge(text: loc.ecoIntroS2Badge, color: _kS2Accent),
              Text(
                loc.ecoIntroS2TopLabel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _kS2Soft,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Icon(Icons.show_chart, size: 36, color: _kS2Accent),
          const SizedBox(height: 10),
          Text(
            loc.ecoIntroS2Title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: _kS2Title,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            loc.ecoIntroS2Source,
            style: const TextStyle(fontSize: 12, color: _kS2Soft),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _kS2Accent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.ecoIntroS2CoreLabel,
                  style: const TextStyle(
                    color: _kS2OnAccent,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      loc.ecoIntroS2CoreValue,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      loc.ecoIntroS2CoreUnit,
                      style: const TextStyle(
                        color: _kS2OnAccent,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  loc.ecoIntroS2CoreBody,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _Kpi(
            icon: Icons.local_gas_station,
            label: loc.ecoIntroS2Kpi1Label,
            value: loc.ecoIntroS2Kpi1Value,
          ),
          const SizedBox(height: 6),
          _Kpi(
            icon: Icons.cloud,
            label: loc.ecoIntroS2Kpi2Label,
            value: loc.ecoIntroS2Kpi2Value,
          ),
          const SizedBox(height: 6),
          _Kpi(
            icon: Icons.air,
            label: loc.ecoIntroS2Kpi3Label,
            value: loc.ecoIntroS2Kpi3Value,
          ),
          const SizedBox(height: 6),
          _Kpi(
            icon: Icons.verified_user,
            label: loc.ecoIntroS2Kpi4Label,
            value: loc.ecoIntroS2Kpi4Value,
          ),
          const SizedBox(height: 6),
          _Kpi(
            icon: Icons.build,
            label: loc.ecoIntroS2Kpi5Label,
            value: loc.ecoIntroS2Kpi5Value,
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.ecoIntroS2TreeTitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _kS2Soft,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  loc.ecoIntroS2TreeBody,
                  style: const TextStyle(
                    fontSize: 12,
                    color: _kS2Body,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: _kS2Accent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: _kS2KpiBody),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _kS2Title,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 슬라이드 3: ACTION ────────────────────────────────────────────────
class _ActionSlide extends StatelessWidget {
  const _ActionSlide();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Badge(text: loc.ecoIntroS3Badge, color: _kS3Accent),
              Text(
                loc.ecoIntroS3TopLabel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _kS3Soft,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Icon(Icons.drive_eta, size: 36, color: _kS3Accent),
          const SizedBox(height: 10),
          Text(
            loc.ecoIntroS3Title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: _kS3Title,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            loc.ecoIntroS3Subtitle,
            style: const TextStyle(fontSize: 12, color: _kS3Soft),
          ),
          const SizedBox(height: 12),
          _GroupTitle(loc.ecoIntroS3Group1Title),
          _ActionItem(
            n: 1,
            label: loc.ecoIntroS3Item1Label,
            body: loc.ecoIntroS3Item1Body,
          ),
          _ActionItem(
            n: 2,
            label: loc.ecoIntroS3Item2Label,
            body: loc.ecoIntroS3Item2Body,
          ),
          _ActionItem(
            n: 3,
            label: loc.ecoIntroS3Item3Label,
            body: loc.ecoIntroS3Item3Body,
          ),
          _ActionItem(
            n: 4,
            label: loc.ecoIntroS3Item4Label,
            body: loc.ecoIntroS3Item4Body,
          ),
          _ActionItem(
            n: 5,
            label: loc.ecoIntroS3Item5Label,
            body: loc.ecoIntroS3Item5Body,
          ),
          const SizedBox(height: 8),
          _GroupTitle(loc.ecoIntroS3Group2Title),
          _ActionItem(
            n: 6,
            label: loc.ecoIntroS3Item6Label,
            body: loc.ecoIntroS3Item6Body,
          ),
          _ActionItem(
            n: 7,
            label: loc.ecoIntroS3Item7Label,
            body: loc.ecoIntroS3Item7Body,
          ),
          _ActionItem(
            n: 8,
            label: loc.ecoIntroS3Item8Label,
            body: loc.ecoIntroS3Item8Body,
          ),
          const SizedBox(height: 8),
          _GroupTitle(loc.ecoIntroS3Group3Title),
          _ActionItem(
            n: 9,
            label: loc.ecoIntroS3Item9Label,
            body: loc.ecoIntroS3Item9Body,
          ),
          _ActionItem(
            n: 10,
            label: loc.ecoIntroS3Item10Label,
            body: loc.ecoIntroS3Item10Body,
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _kS3Accent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  loc.ecoIntroS3SloganTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  loc.ecoIntroS3SloganBody,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _kS3OnAccent,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupTitle extends StatelessWidget {
  const _GroupTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _kS3Soft,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  const _ActionItem({
    required this.n,
    required this.label,
    required this.body,
  });

  final int n;
  final String label;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: _kS3Bg,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$n',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _kS3Soft,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _kS3Title,
                  ),
                ),
                Text(
                  body,
                  style: const TextStyle(fontSize: 11, color: _kS3Soft),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
