import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/vault_item.dart';
import '../../providers/vault_provider.dart';

class VaultToolsTab extends StatefulWidget {
  const VaultToolsTab({super.key});

  @override
  State<VaultToolsTab> createState() => _VaultToolsTabState();
}

class _VaultToolsTabState extends State<VaultToolsTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Split Bill State
  final _billCtrl = TextEditingController(text: '150000');
  final _taxCtrl = TextEditingController(text: '10');
  int _peopleCount = 3;

  // Discount Calculator State
  final _originalPriceCtrl = TextEditingController(text: '200000');
  final _discountPctCtrl = TextEditingController(text: '20');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _billCtrl.dispose();
    _taxCtrl.dispose();
    _originalPriceCtrl.dispose();
    _discountPctCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Brankas & Utilitas'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accentSky,
          indicatorWeight: 3,
          labelColor: AppColors.accentSky,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'Brankas ID'),
            Tab(text: 'Kalkulator Cepat'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildVaultSection(),
          _buildToolsSection(),
        ],
      ),
    );
  }

  // --- VAULT SECTION ---
  Widget _buildVaultSection() {
    final vault = context.watch<VaultProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddVaultDialog(context),
        backgroundColor: AppColors.textPrimary,
        foregroundColor: AppColors.canvas,
        icon: const Icon(Icons.add, size: 20),
        label: const Text('Simpan Kartu ID', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Security badge header
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_outlined, color: AppColors.accentEmerald, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Penyimpanan Aman Lokal', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        Text('Data tersimpan di memori internal perangkat Anda.', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Vault Items List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: vault.items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = vault.items[index];
                IconData cardIcon = Icons.credit_card;
                Color cardAccent = AppColors.accentSky;

                if (item.category == VaultCategory.ktp) {
                  cardIcon = Icons.badge_outlined;
                  cardAccent = AppColors.accentEmerald;
                } else if (item.category == VaultCategory.sim) {
                  cardIcon = Icons.directions_car_outlined;
                  cardAccent = AppColors.accentAmber;
                } else if (item.category == VaultCategory.bank) {
                  cardIcon = Icons.account_balance_outlined;
                  cardAccent = AppColors.accentPurple;
                }

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: item.isExpiringSoon ? AppColors.accentAmber : AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: cardAccent.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(cardIcon, size: 16, color: cardAccent),
                              ),
                              const SizedBox(width: 10),
                              Text(item.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            ],
                          ),
                          Row(
                            children: [
                              if (item.isExpiringSoon)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentAmber.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text('Segera Habis', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.accentAmber)),
                                ),
                              IconButton(
                                onPressed: () => vault.deleteItem(item.id),
                                icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Card Number with 1-Click Copy
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.canvas,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.numberOrCode,
                              style: const TextStyle(fontSize: 14, fontFamily: 'monospace', fontWeight: FontWeight.bold, color: AppColors.textPrimary, letterSpacing: 1),
                            ),
                            InkWell(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: item.numberOrCode));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Nomor ${item.title} disalin ke clipboard!'),
                                    duration: const Duration(seconds: 2),
                                    backgroundColor: AppColors.surfaceElevated,
                                  ),
                                );
                              },
                              child: const Row(
                                children: [
                                  Icon(Icons.copy_rounded, size: 14, color: AppColors.accentSky),
                                  SizedBox(width: 4),
                                  Text('Salin', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accentSky)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (item.expiryDate != null || (item.notes != null && item.notes!.isNotEmpty)) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (item.expiryDate != null)
                              Text('Berlaku s/d: ${Formatters.formatDate(item.expiryDate!)}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            if (item.notes != null)
                              Text(item.notes!, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // --- TOOLS SECTION ---
  Widget _buildToolsSection() {
    // Split Bill Calculations
    final billTotal = double.tryParse(_billCtrl.text) ?? 0.0;
    final taxPct = double.tryParse(_taxCtrl.text) ?? 0.0;
    final totalWithTax = billTotal + (billTotal * taxPct / 100);
    final perPerson = _peopleCount > 0 ? totalWithTax / _peopleCount : 0.0;

    // Discount Calculations
    final origPrice = double.tryParse(_originalPriceCtrl.text) ?? 0.0;
    final discPct = double.tryParse(_discountPctCtrl.text) ?? 0.0;
    final savings = origPrice * (discPct / 100);
    final finalPrice = origPrice - savings;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. SPLIT BILL CALCULATOR
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.pie_chart_outline_rounded, color: AppColors.accentPurple, size: 20),
                    SizedBox(width: 8),
                    Text('Kalkulator Split Bill', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _billCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Total Tagihan (Rp)',
                          labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                          filled: true,
                          fillColor: AppColors.canvas,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: _taxCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Pajak (%)',
                          labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                          filled: true,
                          fillColor: AppColors.canvas,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Dibagi $_peopleCount Orang', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    Row(
                      children: [
                        IconButton.filled(
                          onPressed: _peopleCount > 1 ? () => setState(() => _peopleCount--) : null,
                          iconSize: 16,
                          style: IconButton.styleFrom(backgroundColor: AppColors.surfaceElevated),
                          icon: const Icon(Icons.remove, color: AppColors.textPrimary),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text('$_peopleCount', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        ),
                        IconButton.filled(
                          onPressed: () => setState(() => _peopleCount++),
                          iconSize: 16,
                          style: IconButton.styleFrom(backgroundColor: AppColors.surfaceElevated),
                          icon: const Icon(Icons.add, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(color: AppColors.border, height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Nominal Per Orang:', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    Text(
                      Formatters.formatRupiah(perPerson),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.accentEmerald),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 2. DISCOUNT CALCULATOR
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.discount_outlined, color: AppColors.accentAmber, size: 20),
                    SizedBox(width: 8),
                    Text('Kalkulator Diskon Belanja', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _originalPriceCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Harga Asli (Rp)',
                          labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                          filled: true,
                          fillColor: AppColors.canvas,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: _discountPctCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Diskon (%)',
                          labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                          filled: true,
                          fillColor: AppColors.canvas,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
                const Divider(color: AppColors.border, height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Hemat / Potongan:', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        Text(Formatters.formatRupiah(savings), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.accentRose)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Harga Bayar:', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        Text(Formatters.formatRupiah(finalPrice), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.accentEmerald)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showAddVaultDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final numberCtrl = TextEditingController();
    VaultCategory category = VaultCategory.ktp;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Simpan Kartu / ID Baru', style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Nama Dokumen (Contoh: BPJS Ketenagakerjaan)',
                  hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  filled: true,
                  fillColor: AppColors.canvas,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: numberCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Nomor Kartu / ID',
                  hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  filled: true,
                  fillColor: AppColors.canvas,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<VaultCategory>(
                initialValue: category,
                dropdownColor: AppColors.surfaceElevated,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Kategori Dokumen',
                  labelStyle: const TextStyle(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.canvas,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                items: VaultCategory.values
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.name.toUpperCase())))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setDialogState(() => category = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal', style: TextStyle(color: AppColors.textMuted))),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.trim().isNotEmpty && numberCtrl.text.trim().isNotEmpty) {
                  context.read<VaultProvider>().addItem(
                    title: titleCtrl.text.trim(),
                    numberOrCode: numberCtrl.text.trim(),
                    holderName: 'Edvan',
                    category: category,
                  );
                  Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.textPrimary, foregroundColor: AppColors.canvas),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
