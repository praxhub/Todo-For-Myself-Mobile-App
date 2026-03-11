import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import '../services/mock_data_injector.dart';
import '../services/native_sms_reader.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mockDataInjectorProvider).injectMockDataIfEmpty();
    });
  }

  Future<void> _syncSms() async {
    setState(() => _isSyncing = true);
    await ref.read(nativeSmsReaderProvider).fetchAndProcessRecentSms();
    setState(() => _isSyncing = false);
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionsProvider);
    final totalSpent =
        ref.watch(transactionsProvider.notifier).totalSpentThisMonth;

    return Scaffold(
      appBar: AppBar(
        title: Text('FinPilot',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: _isSyncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.sync),
            onPressed: _isSyncing ? null : _syncSms,
            tooltip: 'Sync Local SMS',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryCard(context, totalSpent),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Recent Transactions',
                style: GoogleFonts.outfit(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: transactions.isEmpty
                ? Center(
                    child: Text('No transactions found.',
                        style: GoogleFonts.inter()))
                : ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final tx = transactions[index];
                      return _buildTransactionTile(context, tx);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: null,
    );
  }

  Widget _buildSummaryCard(BuildContext context, double totalSpent) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spent This Month',
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            currencyFormat.format(totalSpent),
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(BuildContext context, TransactionModel tx) {
    final isDebit = tx.type == 'Debit';
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isDebit ? Colors.red.shade100 : Colors.green.shade100,
        child: Icon(
          isDebit ? Icons.arrow_outward : Icons.arrow_downward,
          color: isDebit ? Colors.red : Colors.green,
        ),
      ),
      title: Text(tx.merchant,
          style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
      subtitle: Text(
          '${tx.category} • ${DateFormat('dd MMM yyyy, hh:mm a').format(tx.date)}',
          style: GoogleFonts.inter(fontSize: 12)),
      trailing: Text(
        '${isDebit ? '-' : '+'}${currencyFormat.format(tx.amount)}',
        style: GoogleFonts.inter(
          color: isDebit ? Colors.red : Colors.green,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(
        begin: 0.05, end: 0, duration: 400.ms, curve: Curves.easeOutQuad);
  }
}
