import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/member_notification.dart';
import '../services/member_notification_inbox_service.dart';

typedef NotificationInboxScope = ({String churchId, String memberId});

final memberNotificationInboxServiceProvider =
    Provider.family<MemberNotificationInboxService, NotificationInboxScope>((
      ref,
      scope,
    ) {
      return MemberNotificationInboxService(
        churchId: scope.churchId,
        memberId: scope.memberId,
      );
    });

final memberNotificationInboxProvider =
    StreamProvider.family<List<MemberNotification>, NotificationInboxScope>((
      ref,
      scope,
    ) {
      return ref
          .watch(memberNotificationInboxServiceProvider(scope))
          .watchInbox();
    });
