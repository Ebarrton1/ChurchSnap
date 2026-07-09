const {setGlobalOptions} = require("firebase-functions");
const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

setGlobalOptions({maxInstances: 10});

exports.sendNotificationOnCreate = onDocumentCreated(
  "churches/{churchId}/notifications/{notificationId}",
  async (event) => {
    const snapshot = event.data;

    if (!snapshot) {
      return;
    }

    const notification = snapshot.data();
    const churchId = event.params.churchId;

    const title = notification.title || "ChurchSnap";
    const body = notification.body || "";
    const targetRole = notification.targetRole || "all";

    let membersQuery = admin
      .firestore()
      .collection("churches")
      .doc(churchId)
      .collection("members");

    if (targetRole !== "all") {
      membersQuery = membersQuery.where("role", "==", targetRole);
    }

    const membersSnapshot = await membersQuery.get();

    const tokens = membersSnapshot.docs
      .map((doc) => doc.data().fcmToken)
      .filter((token) => typeof token === "string" && token.length > 0);

    if (tokens.length === 0) {
      await snapshot.ref.update({
        sent: false,
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
        sendResult: "No device tokens found",
      });

      return;
    }

    const response = await admin.messaging().sendEachForMulticast({
      tokens,
      notification: {
        title,
        body,
      },
      data: {
        type: notification.type || "announcement",
        notificationId: event.params.notificationId,
        churchId,
      },
    });

    await snapshot.ref.update({
      sent: true,
      sentAt: admin.firestore.FieldValue.serverTimestamp(),
      successCount: response.successCount,
      failureCount: response.failureCount,
    });
  },
);