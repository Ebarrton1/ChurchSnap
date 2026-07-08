const { setGlobalOptions } = require("firebase-functions");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");

admin.initializeApp();

setGlobalOptions({ maxInstances: 10 });

exports.sendAnnouncementNotification = onDocumentCreated(
  "churches/{churchId}/announcements/{announcementId}",
  async (event) => {
    const snapshot = event.data;

    if (!snapshot) {
      logger.info("No announcement data.");
      return;
    }

    const announcement = snapshot.data();
    const churchId = event.params.churchId;

    if (announcement.published !== true) {
      logger.info("Announcement is not published.");
      return;
    }

    const title = announcement.title || "New Church Announcement";
    const body = announcement.message || "Open ChurchSnap for the latest update.";

    const membersSnapshot = await admin
      .firestore()
      .collection("churches")
      .doc(churchId)
      .collection("members")
      .get();

    const tokens = [];

    membersSnapshot.forEach((doc) => {
      const token = doc.data().fcmToken;
      if (token) {
        tokens.push(token);
      }
    });

    if (tokens.length === 0) {
      logger.info("No FCM tokens found.");
      return;
    }

    const response = await admin.messaging().sendEachForMulticast({
      tokens,
      notification: {
        title,
        body,
      },
      data: {
        type: "announcement",
        churchId,
        announcementId: event.params.announcementId,
      },
    });

    logger.info("Announcement notification sent.", {
      successCount: response.successCount,
      failureCount: response.failureCount,
    });
  }
);