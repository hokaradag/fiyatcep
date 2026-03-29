import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/price_point.dart';

enum TimeRange { week, month, threeMonths, year }

class ProductPriceHistorySection extends StatefulWidget {
  final List<PricePoint> priceHistory;
  const ProductPriceHistorySection({super.key, required this.priceHistory});

  @override
  State<ProductPriceHistorySection> createState() =>
      _ProductPriceHistorySectionState();
}

class _ProductPriceHistorySectionState
    extends State<ProductPriceHistorySection> {
  TimeRange _selectedRange = TimeRange.month; // D-11: default 1A

  List<PricePoint> _filter(TimeRange range) {
    final cutoff = switch (range) {
      TimeRange.week => DateTime.now().subtract(const Duration(days: 7)),
      TimeRange.month => DateTime.now().subtract(const Duration(days: 30)),
      TimeRange.threeMonths => DateTime.now().subtract(const Duration(days: 90)),
      TimeRange.year => DateTime.now().subtract(const Duration(days: 365)),
    };
    return widget.priceHistory.where((p) => p.date.isAfter(cutoff)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  bool _isTabEnabled(TimeRange range) {
    return _filter(range).length >= 2;
  }

  List<FlSpot> _buildSpots(List<PricePoint> points) {
    return List.generate(
      points.length,
      (i) => FlSpot(i.toDouble(), points[i].price),
    );
  }

  @override
  Widget build(BuildContext context) {
    // D-10: empty state
    if (widget.priceHistory.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fiyat Geçmişi',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'Fiyat geçmişi henüz mevcut değil',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      );
    }

    final filteredPoints = _filter(_selectedRange);
    final spots = _buildSpots(filteredPoints);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fiyat Geçmişi',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildTimeRangeSelector(),
        const SizedBox(height: 16),
        if (filteredPoints.length >= 2)
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    color: Colors.green,
                    barWidth: 2,
                    isCurved: false,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) =>
                          FlDotCirclePainter(
                        radius: 4,
                        color: Colors.green,
                        strokeWidth: 0,
                      ),
                    ),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => Colors.white,
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final point = filteredPoints[spot.spotIndex];
                        return LineTooltipItem(
                          '${spot.y.toStringAsFixed(2)} ₺\n',
                          const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: point.displayDate,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        );
                      }).toList();
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Colors.grey.shade200,
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 48,
                      getTitlesWidget: (value, meta) {
                        if (value != meta.min && value != meta.max) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          '${value.toStringAsFixed(0)}₺',
                          style: const TextStyle(fontSize: 11),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= filteredPoints.length) {
                          return const SizedBox.shrink();
                        }
                        if (idx != 0 && idx != filteredPoints.length - 1) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          filteredPoints[idx].displayDate,
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
              ),
            ),
          )
        else
          Text(
            'Seçilen aralıkta yeterli veri yok',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
      ],
    );
  }

  Widget _buildTimeRangeSelector() {
    const labels = {
      TimeRange.week: '1H',
      TimeRange.month: '1A',
      TimeRange.threeMonths: '3A',
      TimeRange.year: '1Y',
    };

    return Row(
      children: TimeRange.values.map((range) {
        final isSelected = range == _selectedRange;
        final isEnabled = _isTabEnabled(range);

        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: isEnabled && !isSelected
                ? () => setState(() => _selectedRange = range)
                : null,
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.green
                    : isEnabled
                        ? Colors.grey.shade100
                        : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                labels[range]!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  color: isSelected
                      ? Colors.white
                      : isEnabled
                          ? Colors.black87
                          : Colors.grey.shade400,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
