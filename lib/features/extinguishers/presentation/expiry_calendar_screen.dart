import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/app_layout.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../domain/fire_extinguisher.dart';
import '../providers/extinguisher_providers.dart';

class ExpiryCalendarScreen extends ConsumerStatefulWidget {
  const ExpiryCalendarScreen({super.key});

  @override
  ConsumerState<ExpiryCalendarScreen> createState() => _ExpiryCalendarScreenState();
}

class _ExpiryCalendarScreenState extends ConsumerState<ExpiryCalendarScreen> {
  static const _nameColumnWidth = 118.0;
  static const _rowHeight = 52.0;
  static const _headerHeight = 54.0;
  static const _minPixelsPerDay = 0.42;
  static const _maxPixelsPerDay = 1.15;

  final _scrollController = ScrollController();
  String? _selectedId;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  DateTime _dateOnly(DateTime value) => DateTime(value.year, value.month, value.day);

  double _xForDate(DateTime date, DateTime rangeStart, double pixelsPerDay) =>
      _dateOnly(date).difference(rangeStart).inDays * pixelsPerDay;

  ({DateTime start, DateTime end}) _timelineRange(List<FireExtinguisher> items) {
    final today = _dateOnly(DateTime.now());
    if (items.isEmpty) {
      return (
        start: DateTime(today.year - 1, 1, 1),
        end: DateTime(today.year + 3, 12, 31),
      );
    }

    var minExpiry = _dateOnly(items.first.expiryDate);
    var maxExpiry = minExpiry;
    for (final item in items) {
      final expiry = _dateOnly(item.expiryDate);
      if (expiry.isBefore(minExpiry)) minExpiry = expiry;
      if (expiry.isAfter(maxExpiry)) maxExpiry = expiry;
    }

    final startYear = [today.year - 1, minExpiry.year].reduce((a, b) => a < b ? a : b);
    final endYear = [today.year + 3, maxExpiry.year + 1].reduce((a, b) => a > b ? a : b);

    return (
      start: DateTime(startYear, 1, 1),
      end: DateTime(endYear, 12, 31),
    );
  }

  double _pixelsPerDayForViewport(double viewportWidth, int totalDays) {
    final trackWidth = viewportWidth - _nameColumnWidth - AppSpacing.sm;
    if (totalDays <= 0 || trackWidth <= 0) return _minPixelsPerDay;
    return (trackWidth / totalDays).clamp(_minPixelsPerDay, _maxPixelsPerDay);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final today = _dateOnly(DateTime.now());
    final extinguishers = ref
        .watch(extinguisherProvider)
        .where((e) => e.companyId == null)
        .toList()
      ..sort((a, b) => a.expiryDate.compareTo(b.expiryDate));

    final range = _timelineRange(extinguishers);
    final totalDays = range.end.difference(range.start).inDays + 1;

    FireExtinguisher? selected;
    if (_selectedId != null) {
      for (final item in extinguishers) {
        if (item.id == _selectedId) {
          selected = item;
          break;
        }
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('SKT çizelgesi')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.xs, AppSpacing.page, AppSpacing.md),
        children: [
          Text(
            'Her satır bir tüpü gösterir. Nokta son kullanma tarihini, çizgi bugünden o tarihe kalan süreyi temsil eder.',
            style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary, height: 1.45),
          ),
          const SizedBox(height: AppSpacing.sm),
          const _TimelineLegend(),
          const SizedBox(height: AppSpacing.sm),
          Container(
            decoration: AppDecorations.panel(),
            clipBehavior: Clip.antiAlias,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final pixelsPerDay = _pixelsPerDayForViewport(constraints.maxWidth, totalDays);
                final timelineWidth = totalDays * pixelsPerDay;
                final todayX = _xForDate(today, range.start, pixelsPerDay);
                final chartHeight = _headerHeight + extinguishers.length * _rowHeight;

                return SizedBox(
                  height: chartHeight.clamp(_headerHeight + _rowHeight, 360),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _NameColumn(
                        headerHeight: _headerHeight,
                        rowHeight: _rowHeight,
                        items: extinguishers,
                        selectedId: _selectedId,
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: timelineWidth + AppSpacing.md,
                            height: chartHeight.clamp(_headerHeight + _rowHeight, 360),
                            child: Stack(
                              children: [
                                ..._yearBands(range, pixelsPerDay, chartHeight),
                                Column(
                                  children: [
                                    _TimelineHeader(
                                      range: range,
                                      pixelsPerDay: pixelsPerDay,
                                      height: _headerHeight,
                                    ),
                                    ...extinguishers.map(
                                      (item) => _TimelineRow(
                                        item: item,
                                        rangeStart: range.start,
                                        today: today,
                                        pixelsPerDay: pixelsPerDay,
                                        todayX: todayX,
                                        height: _rowHeight,
                                        selected: item.id == _selectedId,
                                        onTap: () => setState(() => _selectedId = item.id),
                                      ),
                                    ),
                                  ],
                                ),
                                Positioned(
                                  left: todayX,
                                  top: 0,
                                  bottom: 0,
                                  child: _TodayMarker(height: chartHeight),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (extinguishers.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: AppDecorations.insetPanel(),
              child: Text(
                'Henüz kayıtlı tüp yok. SKT çizelgesi tüp ekledikçe dolacak.',
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            )
          else ...[
            SectionLabel('SKT özeti'),
            const SizedBox(height: AppSpacing.xs),
            ...extinguishers.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: _ExpiryListTile(
                  item: item,
                  selected: item.id == _selectedId,
                  onTap: () => setState(() => _selectedId = item.id),
                  onOpen: () => context.push('/extinguishers/${item.id}'),
                ),
              ),
            ),
          ],
          if (selected != null) ...[
            const SizedBox(height: AppSpacing.xs),
            PrimaryButton(
              label: '${selected.name} detayına git',
              onPressed: () => context.push('/extinguishers/${selected!.id}'),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _yearBands(({DateTime start, DateTime end}) range, double pixelsPerDay, double height) {
    final bands = <Widget>[];
    for (var year = range.start.year; year <= range.end.year; year++) {
      final yearStart = DateTime(year, 1, 1);
      if (yearStart.isBefore(range.start)) continue;
      final x = _xForDate(yearStart, range.start, pixelsPerDay);
      final nextYear = DateTime(year + 1, 1, 1);
      final end = nextYear.isAfter(range.end) ? range.end : nextYear;
      final width = _dateOnly(end).difference(yearStart).inDays * pixelsPerDay;
      final shaded = year.isEven;
      bands.add(
        Positioned(
          left: x,
          top: _headerHeight,
          width: width,
          height: height - _headerHeight,
          child: ColoredBox(
            color: shaded
                ? AppColors.surfaceMuted.withValues(alpha: 0.55)
                : Colors.transparent,
          ),
        ),
      );
    }
    return bands;
  }
}

class _NameColumn extends StatelessWidget {
  const _NameColumn({
    required this.headerHeight,
    required this.rowHeight,
    required this.items,
    required this.selectedId,
  });

  final double headerHeight;
  final double rowHeight;
  final List<FireExtinguisher> items;
  final String? selectedId;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      width: _ExpiryCalendarScreenState._nameColumnWidth,
      child: Column(
        children: [
          SizedBox(
            height: headerHeight,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: AppSpacing.sm, bottom: AppSpacing.xxs),
                child: Text(
                  'Tüp',
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          ...items.map(
            (item) => SizedBox(
              height: rowHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: item.id == selectedId ? AppColors.primarySoft : null,
                  border: Border(
                    bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.7)),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineHeader extends StatelessWidget {
  const _TimelineHeader({
    required this.range,
    required this.pixelsPerDay,
    required this.height,
  });

  final ({DateTime start, DateTime end}) range;
  final double pixelsPerDay;
  final double height;

  static const _quarters = ['Oca', 'Nis', 'Tem', 'Eki'];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ticks = <Widget>[];

    for (var year = range.start.year; year <= range.end.year; year++) {
      final yearStart = DateTime(year, 1, 1);
      if (yearStart.isBefore(range.start) && year < range.end.year) continue;
      final yearX = _dateOnly(yearStart).difference(range.start).inDays * pixelsPerDay;

      ticks.add(
        Positioned(
          left: yearX,
          top: 0,
          bottom: 0,
          child: Container(
            width: 1,
            color: AppColors.borderStrong,
          ),
        ),
      );

      ticks.add(
        Positioned(
          left: yearX + 4,
          top: 8,
          child: Text(
            '$year',
            style: textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      );

      for (var q = 0; q < 4; q++) {
        final month = q * 3 + 1;
        final quarterDate = DateTime(year, month, 1);
        if (quarterDate.isBefore(range.start) || quarterDate.isAfter(range.end)) continue;
        final x = _dateOnly(quarterDate).difference(range.start).inDays * pixelsPerDay;
        ticks.add(
          Positioned(
            left: x,
            bottom: 8,
            child: Text(
              _quarters[q],
              style: textTheme.labelSmall?.copyWith(
                color: AppColors.textTertiary,
                fontSize: 10,
              ),
            ),
          ),
        );
      }
    }

    return SizedBox(
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(height: 1, color: AppColors.borderStrong),
          ),
          ...ticks,
        ],
      ),
    );
  }

  DateTime _dateOnly(DateTime value) => DateTime(value.year, value.month, value.day);
}

class _TodayMarker extends StatelessWidget {
  const _TodayMarker({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      width: 2,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
          Positioned(
            left: -18,
            top: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppDecorations.radiusXs),
              ),
              child: Text(
                'Bugün',
                style: textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.item,
    required this.rangeStart,
    required this.today,
    required this.pixelsPerDay,
    required this.todayX,
    required this.height,
    required this.selected,
    required this.onTap,
  });

  final FireExtinguisher item;
  final DateTime rangeStart;
  final DateTime today;
  final double pixelsPerDay;
  final double todayX;
  final double height;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final expiryX = _dateOnly(item.expiryDate).difference(rangeStart).inDays * pixelsPerDay;
    final barLeft = todayX < expiryX ? todayX : expiryX;
    final barWidth = (todayX - expiryX).abs().clamp(4.0, double.infinity);
    final isExpired = item.expiryDate.isBefore(today);
    final barColor = item.status.color.withValues(alpha: isExpired ? 0.35 : 0.55);

    return Material(
      color: selected ? AppColors.primarySoft.withValues(alpha: 0.35) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: height / 2,
                child: Container(height: 1, color: AppColors.border.withValues(alpha: 0.8)),
              ),
              if (barWidth > 0)
                Positioned(
                  left: barLeft,
                  top: height / 2 - 3,
                  width: barWidth,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              Positioned(
                left: expiryX - 9,
                top: height / 2 - 9,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: item.status.color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected ? AppColors.ink : Colors.white,
                          width: selected ? 2.5 : 2,
                        ),
                        boxShadow: AppDecorations.shadowSm,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.expiryDate.formatted,
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  DateTime _dateOnly(DateTime value) => DateTime(value.year, value.month, value.day);
}

class _TimelineLegend extends StatelessWidget {
  const _TimelineLegend();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xxs,
      children: [
        _LegendDot(color: AppColors.statusOk, label: 'Uygun', textTheme: textTheme),
        _LegendDot(color: AppColors.statusWarning, label: 'Yaklaşan', textTheme: textTheme),
        _LegendDot(color: AppColors.statusExpired, label: 'Dolmuş', textTheme: textTheme),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 18, height: 4, color: AppColors.statusWarning.withValues(alpha: 0.55)),
            const SizedBox(width: 6),
            Text('Kalan süre', style: textTheme.labelSmall),
          ],
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
    required this.textTheme,
  });

  final Color color;
  final String label;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: textTheme.labelSmall),
      ],
    );
  }
}

class _ExpiryListTile extends StatelessWidget {
  const _ExpiryListTile({
    required this.item,
    required this.selected,
    required this.onTap,
    required this.onOpen,
  });

  final FireExtinguisher item;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final days = item.daysUntilExpiry;
    final daysLabel = days < 0
        ? '${days.abs()} gün önce doldu'
        : days == 0
            ? 'Bugün doluyor'
            : '$days gün kaldı';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onOpen,
        borderRadius: BorderRadius.circular(AppDecorations.radiusMd),
        child: Ink(
          decoration: AppDecorations.panel(
            color: selected ? AppColors.primarySoft : AppColors.surface,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: item.status.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: textTheme.titleMedium?.copyWith(fontSize: 15),
                      ),
                      Text(
                        'SKT: ${item.expiryDate.formatted} · $daysLabel',
                        style: textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onOpen,
                  icon: const Icon(Icons.chevron_right, size: 20),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
