import 'package:churchsnap/features/web_admin/models/web_admin_action_item.dart';
import 'package:churchsnap/features/web_admin/services/web_admin_action_center_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WebAdminActionCenterBuilder', () {
    test('prioritizes urgent giving and prayer follow-up', () {
      final now = DateTime.utc(2026, 7, 19, 12);

      final items = WebAdminActionCenterBuilder.build(
        prayerRequests: [
          WebAdminActionSource(
            id: 'prayer-1',
            data: {
              'memberName': 'Jordan',
              'request': 'Please pray for an urgent family situation.',
              'status': 'new',
              'priority': 'urgent',
              'createdAt': now,
            },
          ),
        ],
        events: [
          WebAdminActionSource(
            id: 'event-1',
            data: {
              'title': 'Sunday Worship',
              'location': 'Main Sanctuary',
              'startDate': now.add(const Duration(days: 3)),
            },
          ),
        ],
        members: [
          WebAdminActionSource(
            id: 'member-1',
            data: {'displayName': 'Alex', 'profileComplete': false},
          ),
        ],
        donations: [
          WebAdminActionSource(
            id: 'donation-1',
            data: {
              'memberName': 'Taylor',
              'fundName': 'Building Fund',
              'amount': 50,
              'currency': 'USD',
              'status': 'failed',
            },
          ),
        ],
        now: now,
      );

      expect(items, hasLength(4));
      expect(items[0].priority, WebAdminActionPriority.urgent);
      expect(items[1].priority, WebAdminActionPriority.urgent);
      expect(
        items.map((item) => item.kind),
        containsAll(WebAdminActionKind.values),
      );
    });

    test('excludes completed and out-of-window records', () {
      final now = DateTime.utc(2026, 7, 19, 12);

      final items = WebAdminActionCenterBuilder.build(
        prayerRequests: const [
          WebAdminActionSource(
            id: 'resolved-prayer',
            data: {'status': 'resolved'},
          ),
        ],
        events: [
          WebAdminActionSource(
            id: 'old-event',
            data: {
              'title': 'Old Event',
              'startDate': now.subtract(const Duration(days: 10)),
            },
          ),
        ],
        members: const [
          WebAdminActionSource(
            id: 'complete-member',
            data: {'displayName': 'Complete Member', 'profileComplete': true},
          ),
        ],
        donations: const [
          WebAdminActionSource(
            id: 'completed-donation',
            data: {'status': 'completed'},
          ),
        ],
        now: now,
      );

      expect(items, isEmpty);
    });
  });
}
