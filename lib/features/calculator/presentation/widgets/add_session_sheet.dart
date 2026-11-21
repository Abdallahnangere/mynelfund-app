import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../../core/formatters/currency_formatter.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/theme/nelfund_colors.dart';
import '../../../../core/theme/nelfund_typography.dart';
import '../../domain/repayment_model.dart';
import '../providers/repayment_provider.dart';

/// Opens the Cupertino modal bottom sheet allowing students to add or edit an
/// [AcademicSessionLoan] (institutional fee + optional 12-month upkeep).
Future<void> showAddOrEditLoanDialog(
  BuildContext context,
  RepaymentProvider provider, {
  AcademicSessionLoan? existingLoan,
}) {
  return showCupertinoModalPopup<void>(
    context: context,
    builder: (_) =>
        _AddOrEditSessionSheet(provider: provider, existingLoan: existingLoan),
  );
}

class _AddOrEditSessionSheet extends StatefulWidget {
  const _AddOrEditSessionSheet({required this.provider, this.existingLoan});

  final RepaymentProvider provider;
  final AcademicSessionLoan? existingLoan;

  @override
  State<_AddOrEditSessionSheet> createState() => _AddOrEditSessionSheetState();
}

class _AddOrEditSessionSheetState extends State<_AddOrEditSessionSheet> {
  static const List<String> _monthLabelsEn = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
  ];

  static const List<String> _monthLabelsHa = [
    'Jan',
    'Fab',
    'Mar',
    'Afi',
    'May',
    'Yun',
    'Yul',
    'Agu',
    'Sat',
    'Okt',
    'Nuw',
    'Dis',
  ];

  late int _selectedLevel;
  late double _tuition;
  late bool _includeUpkeep;
  late final Set<int> _upkeepMonths;
  late final TextEditingController _tuitionCtrl;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingLoan;
    if (existing != null) {
      _selectedLevel = existing.level;
    } else {
      var candidate = 100;
      final existingLevels = widget.provider.sessionLoans
          .map((s) => s.level)
          .toSet();
      for (final lvl in const [100, 200, 300, 400, 500, 600]) {
        if (!existingLevels.contains(lvl)) {
          candidate = lvl;
          break;
        }
      }
      _selectedLevel = candidate;
    }

    _tuition = existing?.tuitionFee ?? 120000.0;
    _includeUpkeep = existing?.includeUpkeep ?? false;
    _upkeepMonths = _resolveInitialMonths(existing);
    _tuitionCtrl = TextEditingController(
      text: CurrencyFormatter.formatGrouped(_tuition),
    );
  }

  Set<int> _resolveInitialMonths(AcademicSessionLoan? existing) {
    if (existing == null) {
      return <int>{};
    }
    if (existing.upkeepMonths.isNotEmpty) {
      return existing.upkeepMonths.toSet();
    }
    if (existing.upkeepAmount > 0) {
      final count = (existing.upkeepAmount / 20000.0).round().clamp(0, 12);
      return List.generate(count, (i) => i + 1).toSet();
    }
    return <int>{};
  }

  @override
  void dispose() {
    _tuitionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppTranslations.of(context);
    final currentUpkeep = _includeUpkeep
        ? (_upkeepMonths.length * 20000.0)
        : 0.0;
    final currentTotal = _tuition + currentUpkeep;
    final totalFormatted = CurrencyFormatter.formatNaira(currentTotal);

    return Container(
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.88,
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(
          CupertinoColors.systemBackground,
          context,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey4,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.existingLoan != null
                        ? tr.editLoanYearTitle
                        : tr.addLoanYearTitle,
                    style: NelfundTypography.headline.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Icon(
                      CupertinoIcons.xmark_circle_fill,
                      color: CupertinoColors.systemGrey3,
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(tr.selectLevelLabel, style: NelfundTypography.captionBold),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: CupertinoSlidingSegmentedControl<int>(
                  groupValue: _selectedLevel,
                  children: const {
                    100: Text('100L'),
                    200: Text('200L'),
                    300: Text('300L'),
                    400: Text('400L'),
                    500: Text('500L'),
                    600: Text('600L'),
                  },
                  onValueChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedLevel = val);
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text(
                tr.institutionalFeeLabel,
                style: NelfundTypography.captionBold,
              ),
              const SizedBox(height: 3),
              Text(
                tr.enterFeeDesc,
                style: NelfundTypography.caption.copyWith(
                  color: CupertinoColors.systemGrey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              CupertinoTextField(
                controller: _tuitionCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  const ThousandsSeparatorInputFormatter(),
                ],
                prefix: const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    '₦ ',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: NelfundColors.emerald,
                    ),
                  ),
                ),
                placeholder: 'e.g. 150,000',
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: CupertinoDynamicColor.resolve(
                    CupertinoColors.systemGrey6,
                    context,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: CupertinoColors.systemGrey4,
                    width: 0.6,
                  ),
                ),
                onChanged: (val) {
                  setState(() {
                    _tuition = CurrencyFormatter.parseAmount(val);
                  });
                },
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: CupertinoDynamicColor.resolve(
                    CupertinoColors.systemGrey6,
                    context,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tr.includeUpkeepLabel,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tr.upkeepAutoCalculated,
                            style: NelfundTypography.caption.copyWith(
                              color: NelfundColors.emerald,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CupertinoSwitch(
                      value: _includeUpkeep,
                      activeTrackColor: NelfundColors.emerald,
                      onChanged: (val) => setState(() => _includeUpkeep = val),
                    ),
                  ],
                ),
              ),
              if (_includeUpkeep) ...[
                const SizedBox(height: 10),
                _buildUpkeepMonthSelector(context, tr, currentUpkeep),
              ],
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: NelfundColors.emerald.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tr.sessionLoanTotalLabel(_selectedLevel),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      totalFormatted,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: NelfundColors.emerald,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  color: NelfundColors.emerald,
                  borderRadius: BorderRadius.circular(12),
                  onPressed: () {
                    widget.provider.addOrUpdateSessionLoan(
                      AcademicSessionLoan(
                        level: _selectedLevel,
                        tuitionFee: _tuition,
                        includeUpkeep:
                            _includeUpkeep && _upkeepMonths.isNotEmpty,
                        upkeepMonths: _includeUpkeep
                            ? (_upkeepMonths.toList()..sort())
                            : const [],
                        upkeepAmount: currentUpkeep,
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    widget.existingLoan != null
                        ? tr.buttonUpdateLoan
                        : tr.buttonAddToWallet,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpkeepMonthSelector(
    BuildContext context,
    AppTranslations tr,
    double currentUpkeep,
  ) {
    final labels = tr.isHausa ? _monthLabelsHa : _monthLabelsEn;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(
          const CupertinoDynamicColor.withBrightness(
            color: Color(0x0C008751),
            darkColor: Color(0x1F008751),
          ),
          context,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: NelfundColors.emerald.withValues(alpha: 0.28),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    CupertinoIcons.calendar,
                    size: 15,
                    color: NelfundColors.emerald,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    tr.selectUpkeepMonthsTitle,
                    style: NelfundTypography.captionBold.copyWith(
                      color: NelfundColors.emerald,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
              Text(
                '${_upkeepMonths.length}/12',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: NelfundColors.emerald,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            tr.selectUpkeepMonthsDesc,
            style: NelfundTypography.caption.copyWith(
              color: CupertinoDynamicColor.resolve(
                NelfundColors.secondaryLabel,
                context,
              ),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _QuickMonthButton(
                  label: tr.quickSelectAll12,
                  isSelected: _upkeepMonths.length == 12,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _upkeepMonths.addAll(List.generate(12, (i) => i + 1));
                    });
                  },
                ),
                const SizedBox(width: 6),
                _QuickMonthButton(
                  label: tr.quickSelectSem1,
                  isSelected:
                      _upkeepMonths.containsAll(const [1, 2, 3, 4, 5, 6]) &&
                      _upkeepMonths.length == 6,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _upkeepMonths
                        ..clear()
                        ..addAll(const [1, 2, 3, 4, 5, 6]);
                    });
                  },
                ),
                const SizedBox(width: 6),
                _QuickMonthButton(
                  label: tr.quickSelectSem2,
                  isSelected:
                      _upkeepMonths.containsAll(const [7, 8, 9, 10, 11, 12]) &&
                      _upkeepMonths.length == 6,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _upkeepMonths
                        ..clear()
                        ..addAll(const [7, 8, 9, 10, 11, 12]);
                    });
                  },
                ),
                const SizedBox(width: 6),
                _QuickMonthButton(
                  label: tr.quickClear,
                  isSelected: _upkeepMonths.isEmpty,
                  isClear: true,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(_upkeepMonths.clear);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          for (var row = 0; row < 3; row++) ...[
            if (row > 0) const SizedBox(height: 6),
            Row(
              children: [
                for (var col = 0; col < 4; col++) ...[
                  if (col > 0) const SizedBox(width: 6),
                  Expanded(
                    child: _MonthTile(
                      monthLabel: labels[row * 4 + col],
                      isSelected: _upkeepMonths.contains(row * 4 + col + 1),
                      onTap: () {
                        final monthNum = row * 4 + col + 1;
                        HapticFeedback.selectionClick();
                        setState(() {
                          if (!_upkeepMonths.remove(monthNum)) {
                            _upkeepMonths.add(monthNum);
                          }
                        });
                      },
                    ),
                  ),
                ],
              ],
            ),
          ],
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: _upkeepMonths.isNotEmpty
                  ? NelfundColors.emerald.withValues(alpha: 0.12)
                  : CupertinoColors.systemOrange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  _upkeepMonths.isNotEmpty
                      ? CupertinoIcons.checkmark_seal_fill
                      : CupertinoIcons.exclamationmark_circle_fill,
                  size: 14,
                  color: _upkeepMonths.isNotEmpty
                      ? NelfundColors.emerald
                      : CupertinoColors.systemOrange,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _upkeepMonths.isNotEmpty
                        ? tr.upkeepSelectedSummary(
                            _upkeepMonths.length,
                            CurrencyFormatter.formatNaira(currentUpkeep),
                          )
                        : tr.noMonthsSelected,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: _upkeepMonths.isNotEmpty
                          ? NelfundColors.emerald
                          : CupertinoColors.systemOrange,
                    ),
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

class _MonthTile extends StatelessWidget {
  const _MonthTile({
    required this.monthLabel,
    required this.isSelected,
    required this.onTap,
  });

  final String monthLabel;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 38,
        decoration: BoxDecoration(
          color: isSelected
              ? NelfundColors.emerald
              : CupertinoDynamicColor.resolve(
                  CupertinoColors.systemBackground,
                  context,
                ),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: isSelected
                ? NelfundColors.emerald
                : CupertinoColors.systemGrey4,
            width: isSelected ? 1.4 : 0.6,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: NelfundColors.emerald.withValues(alpha: 0.28),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected) ...[
                const Icon(
                  CupertinoIcons.checkmark_alt,
                  size: 11,
                  color: CupertinoColors.white,
                ),
                const SizedBox(width: 2),
              ],
              Text(
                monthLabel,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? CupertinoColors.white
                      : CupertinoDynamicColor.resolve(
                          NelfundColors.label,
                          context,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickMonthButton extends StatelessWidget {
  const _QuickMonthButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isClear = false,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isClear;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected && !isClear
              ? NelfundColors.emerald.withValues(alpha: 0.16)
              : CupertinoDynamicColor.resolve(
                  CupertinoColors.systemBackground,
                  context,
                ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected && !isClear
                ? NelfundColors.emerald
                : CupertinoColors.systemGrey4,
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected && !isClear
                ? FontWeight.w600
                : FontWeight.w400,
            color: isSelected && !isClear
                ? NelfundColors.emerald
                : (isClear ? CupertinoColors.systemRed : null),
          ),
        ),
      ),
    );
  }
}
