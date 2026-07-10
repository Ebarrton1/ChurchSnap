import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/widgets/churchsnap_screen.dart';
import '../../features/attendance/services/qr_check_in_service.dart';
import '../../features/events/repositories/event_repository.dart';
import '../../models/church_event.dart';

class AdminQrScannerScreen extends StatefulWidget {
  const AdminQrScannerScreen({super.key});
  @override
  State<AdminQrScannerScreen> createState() => _AdminQrScannerScreenState();
}

class _AdminQrScannerScreenState extends State<AdminQrScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  final QrCheckInService _checkInService = QrCheckInService();
  final EventRepository _eventRepository = EventRepository();
  ChurchEvent? _selectedEvent;
  bool _isProcessing = false;
  bool _hasScanned = false;
  String? _lastMessage;
  bool _lastCheckInSucceeded = false;
  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChurchSnapScreen(
      title: 'QR Check-In',
      subtitle: 'Select an event, then scan a member QR code.',
      children: [
        StreamBuilder<List<ChurchEvent>>(
          stream: _eventRepository.watchPublishedEvents(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AppCard(
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return const AppCard(child: Text('Unable to load events.'));
            }
            final events = snapshot.data ?? <ChurchEvent>[];
            if (events.isEmpty) {
              return const AppCard(
                child: Text(
                  'No published events are available. Create an event before '
                  'using QR check-in.',
                ),
              );
            }
            return AppCard(
              child: DropdownButtonFormField<ChurchEvent>(
                initialValue: _selectedEvent,
                decoration: const InputDecoration(
                  labelText: 'Check-in event',
                  prefixIcon: Icon(Icons.event_rounded),
                ),
                items: events.map((event) {
                  return DropdownMenuItem<ChurchEvent>(
                    value: event,
                    child: Text(event.title),
                  );
                }).toList(),
                onChanged: _isProcessing
                    ? null
                    : (event) {
                        setState(() {
                          _selectedEvent = event;
                          _lastMessage = null;
                          _lastCheckInSucceeded = false;
                          _hasScanned = false;
                        });
                      },
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        AppCard(
          child: SizedBox(
            height: 420,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  MobileScanner(
                    controller: _scannerController,
                    onDetect: _handleBarcodeCapture,
                  ),
                  if (_selectedEvent == null)
                    Container(
                      alignment: Alignment.center,
                      color: Colors.black54,
                      padding: const EdgeInsets.all(24),
                      child: const Text(
                        'Select an event before scanning.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  if (_isProcessing)
                    const ColoredBox(
                      color: Colors.black54,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (_lastMessage != null) ...[
          const SizedBox(height: 12),
          AppCard(
            child: ListTile(
              leading: CircleAvatar(
                child: Icon(
                  _lastCheckInSucceeded
                      ? Icons.check_rounded
                      : Icons.error_outline_rounded,
                ),
              ),
              title: Text(
                _lastCheckInSucceeded
                    ? 'Check-in successful'
                    : 'Check-in not completed',
              ),
              subtitle: Text(_lastMessage!),
            ),
          ),
        ],
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _isProcessing ? null : _resetScanner,
            icon: const Icon(Icons.qr_code_scanner_rounded),
            label: const Text('Scan Again'),
          ),
        ),
      ],
    );
  }

  Future<void> _handleBarcodeCapture(BarcodeCapture capture) async {
    if (_selectedEvent == null || _hasScanned || _isProcessing) {
      return;
    }
    final barcode = capture.barcodes.firstOrNull;
    final memberId = barcode?.rawValue?.trim();
    if (memberId == null || memberId.isEmpty) {
      return;
    }
    setState(() {
      _hasScanned = true;
      _isProcessing = true;
      _lastMessage = null;
    });
    await _scannerController.stop();
    final result = await _checkInService.checkInMember(
      memberId: memberId,
      eventId: _selectedEvent!.id,
    );
    if (!mounted) return;
    setState(() {
      _isProcessing = false;
      _lastCheckInSucceeded = result.success;
      _lastMessage = result.message;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.message)));
  }

  Future<void> _resetScanner() async {
    setState(() {
      _hasScanned = false;
      _isProcessing = false;
      _lastMessage = null;
      _lastCheckInSucceeded = false;
    });
    await _scannerController.start();
  }
}
