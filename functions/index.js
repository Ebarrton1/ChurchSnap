
const {setGlobalOptions} = require("firebase-functions");
const {onDocumentCreated} = require("firebase-functions/v2/firestore");const {onSchedule} = require("firebase-functions/scheduler");

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

async function writeNotificationInboxEntries({
  audienceMembers,
  notification,
  notificationId,
  title,
  body,
  targetRole,
  createdAt,
}) {
  for (const memberBatch of chunk(audienceMembers, 450)) {
    const batch = admin.firestore().batch();

    for (const recipient of memberBatch) {
      const inboxReference = recipient.memberReference
        .collection("notificationInbox")
        .doc(notificationId);

      batch.set(
        inboxReference,
        {
          id: notificationId,
          sourceNotificationId: notificationId,
          title,
          body,
          type: String(notification.type || "announcement"),
          targetRole,
          recipientRole: recipient.role,
          createdAt,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        {merge: true},
      );
    }

    await batch.commit();
  }
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

    const audienceMembers = [];
    const recipientsByToken = new Map();

    for (const memberDocument of membersSnapshot.docs) {
      const member = memberDocument.data();
      const role = String(member.role || "member");
      const token = member.fcmToken;

      if (member.isActive === false || role === "visitor") {
        continue;
      }

      if (targetRole !== "all" && role !== targetRole) {
        continue;
      }

      const recipient = {
        memberId: memberDocument.id,
        memberReference: memberDocument.ref,
        role,
      };

      audienceMembers.push(recipient);

      if (typeof token !== "string" || token.trim().length === 0) {
        continue;
      }

      recipientsByToken.set(token, {
        ...recipient,
        token,
      });
    }

    await writeNotificationInboxEntries({
      audienceMembers,
      notification,
      notificationId,
      title,
      body,
      targetRole,
      createdAt:
        notification.createdAt ||
        snapshot.createTime ||
        admin.firestore.FieldValue.serverTimestamp(),
    });

    const recipients = Array.from(recipientsByToken.values());

    if (recipients.length === 0) {
      await snapshot.ref.update({
        sent: false,
        deliveryStatus: "noRecipients",
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
        successCount: 0,
        failureCount: 0,
        recipientCount: 0,
        inboxRecipientCount: audienceMembers.length,
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
        inboxRecipientCount: audienceMembers.length,
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
        inboxRecipientCount: audienceMembers.length,
        sendResult: error instanceof Error
          ? error.message
          : "Notification delivery failed",
      });
    }
  },
);

const CHURCHSNAP_CELEBRATION_WINDOW_DAYS = 7;
const CHURCHSNAP_DEFAULT_TIME_ZONE = "America/New_York";

function churchSnapDateParts(date, timeZone) {
  const formatter = new Intl.DateTimeFormat("en-US", {
    timeZone,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  });
  const values = {};

  for (const part of formatter.formatToParts(date)) {
    if (part.type !== "literal") {
      values[part.type] = Number(part.value);
    }
  }

  return {
    year: values.year,
    month: values.month,
    day: values.day,
  };
}

function churchSnapMonthDay(value, timeZone) {
  if (!value) {
    return null;
  }

  let date = null;

  if (typeof value.toDate === "function") {
    date = value.toDate();
  } else if (value instanceof Date) {
    date = value;
  } else if (typeof value === "string") {
    date = new Date(value);
  }

  if (!date || Number.isNaN(date.getTime())) {
    return null;
  }

  const parts = churchSnapDateParts(date, timeZone);

  return `${String(parts.month).padStart(2, "0")}-${String(
      parts.day,
  ).padStart(2, "0")}`;
}

function churchSnapUpcomingDateKeys(now, timeZone) {
  const today = churchSnapDateParts(now, timeZone);
  const base = new Date(Date.UTC(today.year, today.month - 1, today.day));
  const keys = new Map();

  for (
    let offset = 0;
    offset <= CHURCHSNAP_CELEBRATION_WINDOW_DAYS;
    offset += 1
  ) {
    const date = new Date(
        base.getTime() + offset * 24 * 60 * 60 * 1000,
    );
    const monthDay = `${String(date.getUTCMonth() + 1).padStart(
        2,
        "0",
    )}-${String(date.getUTCDate()).padStart(2, "0")}`;

    keys.set(monthDay, offset);
  }

  return {
    todayKey: `${today.year}-${String(today.month).padStart(
        2,
        "0",
    )}-${String(today.day).padStart(2, "0")}`,
    keys,
  };
}

function churchSnapIsInCelebrationWindow(monthDay, dateWindow) {
  if (!monthDay) {
    return false;
  }

  if (dateWindow.keys.has(monthDay)) {
    return true;
  }

  return (
    monthDay === "02-29" &&
    !dateWindow.keys.has("02-29") &&
    dateWindow.keys.has("02-28")
  );
}

function churchSnapNotificationBody(
    birthdayCount,
    anniversaryCount,
) {
  const parts = [];

  if (birthdayCount > 0) {
    parts.push(
        `${birthdayCount} birthday${birthdayCount === 1 ? "" : "s"}`,
    );
  }

  if (anniversaryCount > 0) {
    parts.push(
        `${anniversaryCount} wedding anniversary${
          anniversaryCount === 1 ? "" : "ies"
        }`,
    );
  }

  return `${parts.join(" and ")} coming up within 7 days.`;
}

async function churchSnapSendCelebrationPush(tokens, message) {
  let successCount = 0;
  let failureCount = 0;

  for (let index = 0; index < tokens.length; index += 500) {
    const tokenBatch = tokens.slice(index, index + 500);
    const response = await admin.messaging().sendEachForMulticast({
      tokens: tokenBatch,
      notification: message.notification,
      data: message.data,
    });

    successCount += response.successCount;
    failureCount += response.failureCount;
  }

  return {successCount, failureCount};
}

exports.sendUpcomingCelebrationAlerts = onSchedule(
    {
      schedule: "0 8 * * *",
      timeZone: CHURCHSNAP_DEFAULT_TIME_ZONE,
    },
    async () => {
      const firestore = admin.firestore();
      const churchesSnapshot = await firestore
          .collection("churches")
          .get();
      const now = new Date();

      for (const churchDocument of churchesSnapshot.docs) {
        const churchId = churchDocument.id;
        const churchData = churchDocument.data();
        const timeZone =
          churchData.timeZone ||
          churchData.timezone ||
          CHURCHSNAP_DEFAULT_TIME_ZONE;

        if (churchData.celebrationRemindersEnabled === false) {
          continue;
        }

        const dateWindow = churchSnapUpcomingDateKeys(now, timeZone);
        const churchReference = churchDocument.ref;
        const membersSnapshot = await churchReference
            .collection("members")
            .get();
        const profilesSnapshot = await churchReference
            .collection("memberPrivateProfiles")
            .get();

        const membersById = new Map(
            membersSnapshot.docs.map((document) => [
              document.id,
              document.data(),
            ]),
        );

        let birthdayCount = 0;
        let anniversaryCount = 0;

        for (const profileDocument of profilesSnapshot.docs) {
          const member = membersById.get(profileDocument.id);

          if (!member) {
            continue;
          }

          const role = String(member.role || "")
              .trim()
              .toLowerCase();

          if (
            member.isActive === false ||
            role === "visitor" ||
            role === "guest"
          ) {
            continue;
          }

          const profile = profileDocument.data();
          const birthdayKey = churchSnapMonthDay(
              profile.dateOfBirth,
              timeZone,
          );

          if (
            profile.birthdayReminderEnabled !== false &&
            churchSnapIsInCelebrationWindow(
                birthdayKey,
                dateWindow,
            )
          ) {
            birthdayCount += 1;
          }

          const anniversaryKey = churchSnapMonthDay(
              profile.weddingAnniversaryDate,
              timeZone,
          );
          const maritalStatus = String(
              profile.maritalStatus || "",
          )
              .trim()
              .toLowerCase();

          if (
            profile.anniversaryReminderEnabled !== false &&
            maritalStatus === "married" &&
            churchSnapIsInCelebrationWindow(
                anniversaryKey,
                dateWindow,
            )
          ) {
            anniversaryCount += 1;
          }
        }

        if (birthdayCount === 0 && anniversaryCount === 0) {
          continue;
        }

        const alertReference = churchReference
            .collection("celebrationAlerts")
            .doc(`daily-${dateWindow.todayKey}`);

        try {
          await alertReference.create({
            birthdayCount,
            anniversaryCount,
            windowDays: CHURCHSNAP_CELEBRATION_WINDOW_DAYS,
            timeZone,
            status: "processing",
            createdAt:
              admin.firestore.FieldValue.serverTimestamp(),
          });
        } catch (error) {
          if (
            error &&
            (
              error.code === 6 ||
              error.code === "6" ||
              error.code === "already-exists"
            )
          ) {
            continue;
          }

          throw error;
        }

        const tokens = Array.from(
            new Set(
                membersSnapshot.docs
                    .map((document) => document.data())
                    .filter((member) => {
                      const role = String(member.role || "")
                          .trim()
                          .toLowerCase();

                      return (
                        member.isActive !== false &&
                        (role === "admin" || role === "pastor")
                      );
                    })
                    .map((member) => member.fcmToken)
                    .filter(
                        (token) =>
                          typeof token === "string" &&
                          token.trim().length > 0,
                    ),
            ),
        );

        if (tokens.length === 0) {
          await alertReference.update({
            status: "no_admin_device_tokens",
            completedAt:
              admin.firestore.FieldValue.serverTimestamp(),
          });
          continue;
        }

        try {
          const result = await churchSnapSendCelebrationPush(
              tokens,
              {
                notification: {
                  title: "Upcoming celebrations",
                  body: churchSnapNotificationBody(
                      birthdayCount,
                      anniversaryCount,
                  ),
                },
                data: {
                  type: "celebrations",
                  churchId,
                  windowDays: String(
                      CHURCHSNAP_CELEBRATION_WINDOW_DAYS,
                  ),
                },
              },
          );

          await alertReference.update({
            status: "sent",
            sentAt:
              admin.firestore.FieldValue.serverTimestamp(),
            successCount: result.successCount,
            failureCount: result.failureCount,
          });
        } catch (error) {
          await alertReference.update({
            status: "failed",
            failureMessage: String(error),
            completedAt:
              admin.firestore.FieldValue.serverTimestamp(),
          });

          throw error;
        }
      }
    },
);
