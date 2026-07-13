
const {setGlobalOptions} = require("firebase-functions");
const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

setGlobalOptions({maxInstances: 10});

const ALLOWED_ROLES = new Set([
  "visitor",
  "member",
  "volunteer",
  "groupLeader",
  "ministryLeader",
  "pastor",
  "admin",
]);

const MAX_MULTICAST_TOKENS = 500;

const STALE_TOKEN_CODES = new Set([
  "messaging/invalid-registration-token",
  "messaging/registration-token-not-registered",
]);

function chunk(values, size) {
  const result = [];

  for (let index = 0; index < values.length; index += size) {
    result.push(values.slice(index, index + size));
  }

  return result;
}

async function removeStaleTokens(staleRecipients) {
  await Promise.all(
    staleRecipients.map(async ({memberReference, token}) => {
      try {
        await admin.firestore().runTransaction(async (transaction) => {
          const currentSnapshot = await transaction.get(memberReference);
          const currentToken = currentSnapshot.data()?.fcmToken;

          if (currentToken === token) {
            transaction.update(memberReference, {
              fcmToken: admin.firestore.FieldValue.delete(),
              fcmTokenUpdatedAt:
                admin.firestore.FieldValue.serverTimestamp(),
            });
          }
        });
      } catch (error) {
        console.error("Unable to remove stale FCM token", error);
      }
    }),
  );
}

exports.sendNotificationOnCreate = onDocumentCreated(
  "churches/{churchId}/notifications/{notificationId}",
  async (event) => {
    const snapshot = event.data;

    if (!snapshot) {
      return;
    }

    const notification = snapshot.data();
    const churchId = event.params.churchId;
    const notificationId = event.params.notificationId;

    const title = String(notification.title || "ChurchSnap")
      .trim()
      .slice(0, 120);

    const body = String(notification.body || "")
      .trim()
      .slice(0, 500);

    const targetRole = String(notification.targetRole || "all");

    if (targetRole !== "all" && !ALLOWED_ROLES.has(targetRole)) {
      await snapshot.ref.update({
        sent: false,
        deliveryStatus: "failed",
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
        successCount: 0,
        failureCount: 0,
        recipientCount: 0,
        sendResult: `Unsupported audience: ${targetRole}`,
      });

      return;
    }

    await snapshot.ref.update({
      deliveryStatus: "sending",
      sendResult: "",
    });

    const membersSnapshot = await admin
      .firestore()
      .collection("churches")
      .doc(churchId)
      .collection("members")
      .get();

    const recipientsByToken = new Map();

    for (const memberDocument of membersSnapshot.docs) {
      const member = memberDocument.data();
      const role = String(member.role || "member");
      const token = member.fcmToken;

      if (member.isActive === false) {
        continue;
      }

      if (targetRole !== "all" && role !== targetRole) {
        continue;
      }

      if (typeof token !== "string" || token.trim().length === 0) {
        continue;
      }

      recipientsByToken.set(token, {
        token,
        memberReference: memberDocument.ref,
      });
    }

    const recipients = Array.from(recipientsByToken.values());

    if (recipients.length === 0) {
      await snapshot.ref.update({
        sent: false,
        deliveryStatus: "noRecipients",
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
        successCount: 0,
        failureCount: 0,
        recipientCount: 0,
        sendResult: "No active device tokens found for this audience",
      });

      return;
    }

    let successCount = 0;
    let failureCount = 0;
    const staleRecipients = [];

    try {
      for (const recipientBatch of chunk(
        recipients,
        MAX_MULTICAST_TOKENS,
      )) {
        const response = await admin.messaging().sendEachForMulticast({
          tokens: recipientBatch.map((recipient) => recipient.token),
          notification: {
            title,
            body,
          },
          data: {
            type: String(notification.type || "announcement"),
            notificationId,
            churchId,
            targetRole,
          },
          android: {
            collapseKey: notificationId,
            priority: "high",
          },
        });

        successCount += response.successCount;
        failureCount += response.failureCount;

        response.responses.forEach((result, index) => {
          const errorCode = result.error?.code;

          if (errorCode && STALE_TOKEN_CODES.has(errorCode)) {
            staleRecipients.push(recipientBatch[index]);
          }
        });
      }

      await removeStaleTokens(staleRecipients);

      const deliveryStatus =
        failureCount === 0
          ? "sent"
          : successCount > 0
            ? "partial"
            : "failed";

      await snapshot.ref.update({
        sent: successCount > 0,
        deliveryStatus,
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
        successCount,
        failureCount,
        recipientCount: recipients.length,
        sendResult:
          failureCount === 0
            ? "Delivery completed"
            : `${failureCount} device delivery failures`,
      });
    } catch (error) {
      console.error("Notification delivery failed", error);

      await snapshot.ref.update({
        sent: successCount > 0,
        deliveryStatus: successCount > 0 ? "partial" : "failed",
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
        successCount,
        failureCount:
          Math.max(failureCount, recipients.length - successCount),
        recipientCount: recipients.length,
        sendResult: error instanceof Error
          ? error.message
          : "Notification delivery failed",
      });
    }
  },
);
