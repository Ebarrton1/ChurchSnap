import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/widgets/churchsnap_screen.dart';

class AdminQrScannerScreen extends StatefulWidget {
  const AdminQrScannerScreen({super.key});

  @override
  State<AdminQrScannerScreen> createState() => _AdminQrScannerScreenState();
}

class _AdminQrScannerScreenState extends State<AdminQrScannerScreen> {
  bool hasScanned = false;

  @override
  Widget build(BuildContext context) {
    return ChurchSnapScreen(
      title: 'QR Check-In',
      subtitle: 'Scan a member QR code to check them in.',
      children: [
        AppCard(
          child: SizedBox(
            height: 420,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: MobileScanner(
                onDetect: (capture) {
                  if (hasScanned) return;

                  final barcode = capture.barcodes.firstOrNull;
                  final memberId = barcode?.rawValue;

                  if (memberId == null || memberId.isEmpty) return;

                  setState(() => hasScanned = true);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Scanned member ID: $memberId')),
                  );
                },
              ),
            ),
          ),
        ),
        FilledButton.icon(
          onPressed: () {
            setState(() => hasScanned = false);
          },
          icon: const Icon(Icons.qr_code_scanner_rounded),
          label: const Text('Scan Again'),
        ),
      ],
    );
  }
}
