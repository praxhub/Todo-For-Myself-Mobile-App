import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/analytics_controller.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsController>().refreshStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Analytics & Insights',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AnalyticsController>().refreshStats();
            },
          )
        ],
      ),
      body: Consumer<AnalyticsController>(
        builder: (context, controller, child) {
          final chartData = controller.tasksCompletedLast7Days;
          double maxY = chartData
              .reduce((curr, next) => curr > next ? curr : next)
              .toDouble();
          if (maxY == 0) maxY = 5; // Default scale if empty

          return RefreshIndicator(
            onRefresh: () async => controller.refreshStats(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Weekly Task Completion',
                  style: GoogleFonts.inter(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ).animate().fadeIn().slideX(),
                const SizedBox(height: 16),

                // Bar Chart
                Container(
                  height: 250,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxY + 2,
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const days = [
                                '6d',
                                '5d',
                                '4d',
                                '3d',
                                '2d',
                                '1d',
                                'Td'
                              ];
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  days[value.toInt() % 7],
                                  style: GoogleFonts.inter(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontSize: 12),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 1,
                        getDrawingHorizontalLine: (value) => FlLine(
                            color: theme.colorScheme.outlineVariant
                                .withValues(alpha: 0.3),
                            strokeWidth: 1),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(7, (index) {
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: chartData[index].toDouble(),
                              color: theme.colorScheme.primary,
                              width: 16,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

                const SizedBox(height: 32),
                Text(
                  'Today\'s Highlights',
                  style: GoogleFonts.inter(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ).animate().fadeIn(delay: 400.ms).slideX(),
                const SizedBox(height: 16),

                // Stat Cards
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Focus Mins',
                        value: '${controller.totalFocusMinutesToday}',
                        icon: Icons.timer,
                        color: Colors.orange,
                        delay: 500.ms,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        title: 'Habits Done',
                        value: '${controller.totalHabitsCompletedToday}',
                        icon: Icons.repeat_rounded,
                        color: Colors.green,
                        delay: 600.ms,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(
      {required this.title,
      required this.value,
      required this.icon,
      required this.color,
      required this.delay});

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.outfit(
                fontSize: 36, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay).scaleXY(begin: 0.9);
  }
}
