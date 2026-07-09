import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/widgets/churchsnap_screen.dart';

class MyQrCodeScreen extends StatelessWidget {
  const MyQrCodeScreen({
    super.key,
    required this.memberId,
    required this.memberName,
  });

  final String memberId;
  final String memberName;

  @override
  Widget build(BuildContext context) {
    return ChurchSnapScreen(
      title: 'My QR Code',
      subtitle: 'Present this code when checking in.',
      children: [
        AppCard(
          child: Column(
            children: [
              Text(
                memberName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              QrImageView(data: memberId, version: QrVersions.auto, size: 250),
              const SizedBox(height: 20),
              SelectableText(
                memberId,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
