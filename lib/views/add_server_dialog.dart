import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/server_provider.dart';

class AddServerDialog extends StatefulWidget {
  const AddServerDialog({super.key});

  @override
  State<AddServerDialog> createState() => _AddServerDialogState();
}

class _AddServerDialogState extends State<AddServerDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _urlController = TextEditingController();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      setState(() {
        _urlController.text = data!.text!.trim();
        _errorMessage = null;
      });
    }
  }

  Future<void> _submitUrl(String url) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty) {
      setState(() => _errorMessage = 'Iltimos, havolani kiriting');
      return;
    }

    if (!trimmed.startsWith('vless://')) {
      setState(() => _errorMessage = 'Havola "vless://" bilan boshlanishi kerak');
      return;
    }

    final serverProvider = context.read<ServerProvider>();
    final success = await serverProvider.addServerFromUrl(trimmed);

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.surfaceLight,
          content: Row(
            children: const [
              Icon(Icons.check_circle_rounded, color: AppColors.connected),
              SizedBox(width: 8),
              Text('Server muvaffaqiyatli qo\'shildi!'),
            ],
          ),
        ),
      );
    } else if (mounted) {
      setState(() => _errorMessage = 'Havolani o\'qishda xatolik yuz berdi');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Yangi Server Qo\'shish',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.textSecondary),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tab bar
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.black,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                tabs: const [
                  Tab(
                    icon: Icon(Icons.link_rounded, size: 18),
                    text: 'Havola (URL)',
                  ),
                  Tab(
                    icon: Icon(Icons.qr_code_scanner_rounded, size: 18),
                    text: 'QR Kod',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              height: 250,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: URL input
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _urlController,
                        maxLines: 4,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              'vless://uuid@host:port?security=reality&sni=...#Name',
                          hintStyle: const TextStyle(
                              color: AppColors.textMuted, fontSize: 12),
                          filled: true,
                          fillColor: AppColors.surfaceLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide:
                                const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide:
                                const BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide:
                                const BorderSide(color: AppColors.primary),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _pasteFromClipboard,
                              icon: const Icon(Icons.content_paste_rounded,
                                  size: 16, color: AppColors.primary),
                              label: const Text('Joylash (Paste)',
                                  style: TextStyle(color: AppColors.primary)),
                              style: OutlinedButton.styleFrom(
                                side:
                                    const BorderSide(color: AppColors.primary),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                              color: AppColors.error, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () => _submitUrl(_urlController.text),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Saqlash',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                      ),
                    ],
                  ),

                  // Tab 2: QR Scanner
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      children: [
                        MobileScanner(
                          onDetect: (capture) {
                            final List<Barcode> barcodes = capture.barcodes;
                            for (final barcode in barcodes) {
                              if (barcode.rawValue != null) {
                                _submitUrl(barcode.rawValue!);
                                break;
                              }
                            }
                          },
                        ),
                        Center(
                          child: Container(
                            width: 170,
                            height: 170,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: AppColors.primary, width: 2.5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          left: 0,
                          right: 0,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              '3X-UI dagi QR-kodni kameraga qarating',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white, fontSize: 11),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
