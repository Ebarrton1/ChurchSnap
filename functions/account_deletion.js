"use strict";

const {onCall, HttpsError} = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

const MAX_AUTH_AGE_SECONDS = 5 * 60;
const MAX_BATCH_WRITES = 400;
const DELETED_ACCOUNT_ID = "deleted-account";
const DELETED_ACCOUNT_NAME = "Former ChurchSnap User";

const PROTECTED_ROLES = new Set([
  "admin",
  "pastor",
  "groupLeader",
  "ministryLeader",
]);

const RETAINED_GIVING_STATUSES = new Set([
  "confirmed",
  "verified",
  "received",
  "completed",
]);

function isRecentAuthentication(authTime, nowSeconds = Date.now() / 1000) {
  const numericAuthTime = Number(authTime);

  return Number.isFinite(numericAuthTime) &&
    numericAuthTime > 0 &&
    nowSeconds - numericAuthTime <= MAX_AUTH_AGE_SECONDS;
}

function isProtectedRole(role) {
  return PROTECTED_ROLES.has(String(role || "").trim());
}

function isRegisteredPasswordAccount(token) {
  const provider = String(
      token?.firebase?.sign_in_provider || "",
  ).trim();
  const email = String(token?.email || "").trim();

  return provider === "password" && email.length > 0;
}

function givingRetentionAction(status) {
  return RETAINED_GIVING_STATUSES.has(
      String(status || "").trim().toLowerCase(),
  ) ? "anonymize" : "delete";
}

function requireSafeId(value, label) {
  const normalized = String(value || "").trim();

  if (!/^[A-Za-z0-9._-]{1,128}$/.test(normalized)) {
    throw new HttpsError(
        "invalid-argument",
        `${label} is missing or invalid.`,
    );
  }

  return normalized;
}

function uniqueDocuments(documents) {
  const byPath = new Map();

  for (const document of documents) {
    byPath.set(document.ref.path, document);
  }

  return [...byPath.values()];
}

function chunks(values, size = MAX_BATCH_WRITES) {
  const result = [];

  for (let index = 0; index < values.length; index += size) {
    result.push(values.slice(index, index + size));
  }

  return result;
}

async function queryByFields(collection, fields, userId) {
  const documents = [];

  for (const field of fields) {
    const snapshot = await collection.where(field, "==", userId).get();
    documents.push(...snapshot.docs);
  }

  return uniqueDocuments(documents);
}

async function queryArrayMembership(collection, field, userId) {
  const snapshot = await collection
      .where(field, "array-contains", userId)
      .get();

  return snapshot.docs;
}

async function deleteDocuments(db, documents) {
  for (const group of chunks(uniqueDocuments(documents))) {
    const batch = db.batch();

    for (const document of group) {
      batch.delete(document.ref);
    }

    await batch.commit();
  }
}

async function updateDocuments(db, updates) {
  for (const group of chunks(updates)) {
    const batch = db.batch();

    for (const update of group) {
      batch.update(update.reference, update.data);
    }

    await batch.commit();
  }
}

async function resolveChurchId(db, userId, requestedChurchId) {
  const linkReference = db.collection("userChurchLinks").doc(userId);
  const linkSnapshot = await linkReference.get();
  const linkedChurchId = String(
      linkSnapshot.data()?.churchId || "",
  ).trim();

  if (linkedChurchId) {
    if (
      requestedChurchId &&
      String(requestedChurchId).trim() !== linkedChurchId
    ) {
      throw new HttpsError(
          "permission-denied",
          "The requested church does not match this account.",
      );
    }

    return requireSafeId(linkedChurchId, "Church");
  }

  return requireSafeId(requestedChurchId, "Church");
}

async function ensureResponsibilitiesTransferred(
    churchReference,
    memberSnapshot,
    userId,
) {
  const role = String(memberSnapshot.data()?.role || "").trim();

  if (isProtectedRole(role)) {
    throw new HttpsError(
        "failed-precondition",
        "Transfer administrator, pastor, or leadership responsibility " +
        "before deleting this account.",
    );
  }

  const [ministryLeadership, groupLeadership] = await Promise.all([
    churchReference
        .collection("ministries")
        .where("leaderId", "==", userId)
        .limit(1)
        .get(),
    churchReference
        .collection("small_groups")
        .where("leaderId", "==", userId)
        .limit(1)
        .get(),
  ]);

  if (!ministryLeadership.empty || !groupLeadership.empty) {
    throw new HttpsError(
        "failed-precondition",
        "Transfer ministry or small-group leadership before deleting " +
        "this account.",
    );
  }
}

async function removeProfilePhotos(bucket, churchId, userId) {
  const prefix =
    `churches/${churchId}/member_profile_photos/${userId}/`;

  await bucket.deleteFiles({prefix});
}

function anonymizedGivingData() {
  const deleteField = admin.firestore.FieldValue.delete();

  return {
    giverId: DELETED_ACCOUNT_ID,
    memberId: DELETED_ACCOUNT_ID,
    userId: DELETED_ACCOUNT_ID,
    createdByUid: DELETED_ACCOUNT_ID,
    ownerUid: DELETED_ACCOUNT_ID,
    giverName: DELETED_ACCOUNT_NAME,
    memberName: DELETED_ACCOUNT_NAME,
    donorName: DELETED_ACCOUNT_NAME,
    email: deleteField,
    giverEmail: deleteField,
    phone: deleteField,
    giverPhone: deleteField,
    note: deleteField,
    description: deleteField,
    accountDeletedAt: admin.firestore.FieldValue.serverTimestamp(),
  };
}

async function deleteAccountData({
  db,
  bucket,
  userId,
  churchId,
}) {
  const churchReference = db.collection("churches").doc(churchId);
  const memberReference = churchReference.collection("members").doc(userId);
  const privateProfileReference = churchReference
      .collection("memberPrivateProfiles")
      .doc(userId);

  const memberSnapshot = await memberReference.get();

  if (memberSnapshot.exists) {
    await ensureResponsibilitiesTransferred(
        churchReference,
        memberSnapshot,
        userId,
    );
  }

  const [
    prayerDocuments,
    joinRequestDocuments,
    volunteerDocuments,
    eventCheckInDocuments,
    checkInDocuments,
    attendanceDocuments,
    celebrationDocuments,
    givingDocuments,
    donationDocuments,
    eventDocuments,
    ministryDocuments,
    smallGroupDocuments,
  ] = await Promise.all([
    queryByFields(
        churchReference.collection("prayer_requests"),
        ["createdByUid", "ownerUid", "userId", "memberId"],
        userId,
    ),
    queryByFields(
        churchReference.collection("group_ministry_join_requests"),
        ["userId", "memberId", "createdByUid"],
        userId,
    ),
    queryByFields(
        churchReference.collection("volunteer_assignments"),
        ["memberId", "userId"],
        userId,
    ),
    queryByFields(
        churchReference.collection("eventCheckIns"),
        ["memberId", "userId"],
        userId,
    ),
    queryByFields(
        churchReference.collection("check_ins"),
        ["memberId", "userId"],
        userId,
    ),
    queryByFields(
        churchReference.collection("attendance"),
        ["memberId", "userId"],
        userId,
    ),
    queryByFields(
        churchReference.collection("celebrationAlerts"),
        ["memberId", "userId"],
        userId,
    ),
    queryByFields(
        churchReference.collection("giving_submissions"),
        ["giverId", "memberId", "userId", "createdByUid"],
        userId,
    ),
    queryByFields(
        churchReference.collection("donations"),
        ["giverId", "memberId", "userId", "createdByUid"],
        userId,
    ),
    queryArrayMembership(
        churchReference.collection("events"),
        "attendeeIds",
        userId,
    ),
    queryArrayMembership(
        churchReference.collection("ministries"),
        "memberIds",
        userId,
    ),
    queryArrayMembership(
        churchReference.collection("small_groups"),
        "memberIds",
        userId,
    ),
  ]);

  await removeProfilePhotos(bucket, churchId, userId);

  const personalDocuments = uniqueDocuments([
    ...prayerDocuments,
    ...joinRequestDocuments,
    ...volunteerDocuments,
    ...eventCheckInDocuments,
    ...checkInDocuments,
    ...attendanceDocuments,
    ...celebrationDocuments,
  ]);

  await deleteDocuments(db, personalDocuments);

  const financialUpdates = [];
  const unconfirmedGivingDocuments = [];

  for (const document of givingDocuments) {
    if (givingRetentionAction(document.data().status) === "anonymize") {
      financialUpdates.push({
        reference: document.ref,
        data: anonymizedGivingData(),
      });
    } else {
      unconfirmedGivingDocuments.push(document);
    }
  }

  for (const document of donationDocuments) {
    financialUpdates.push({
      reference: document.ref,
      data: anonymizedGivingData(),
    });
  }

  await deleteDocuments(db, unconfirmedGivingDocuments);
  await updateDocuments(db, financialUpdates);

  const membershipUpdates = [];

  for (const document of eventDocuments) {
    const attendeeIds = Array.isArray(document.data().attendeeIds) ?
      document.data().attendeeIds.filter((value) => value !== userId) :
      [];

    membershipUpdates.push({
      reference: document.ref,
      data: {
        attendeeIds,
        rsvpCount: attendeeIds.length,
      },
    });
  }

  for (const document of [...ministryDocuments, ...smallGroupDocuments]) {
    membershipUpdates.push({
      reference: document.ref,
      data: {
        memberIds: admin.firestore.FieldValue.arrayRemove(userId),
      },
    });
  }

  await updateDocuments(db, membershipUpdates);

  if (memberSnapshot.exists) {
    await db.recursiveDelete(memberReference);
  }

  await Promise.all([
    privateProfileReference.delete(),
    db.collection("userChurchLinks").doc(userId).delete(),
    db.collection("accountSessions").doc(userId).delete(),
  ]);

  return {
    deletedPersonalDocuments: personalDocuments.length,
    deletedUnconfirmedGivingDocuments:
      unconfirmedGivingDocuments.length,
    anonymizedFinancialDocuments: financialUpdates.length,
    updatedMembershipDocuments: membershipUpdates.length,
  };
}

const deleteChurchSnapAccount = onCall(
    {
      timeoutSeconds: 540,
      memory: "512MiB",
    },
    async (request) => {
      if (!request.auth) {
        throw new HttpsError(
            "unauthenticated",
            "Sign in before deleting your ChurchSnap account.",
        );
      }

      if (!isRegisteredPasswordAccount(request.auth.token)) {
        throw new HttpsError(
            "failed-precondition",
            "Only registered email/password accounts can be deleted here.",
        );
      }

      if (String(request.data?.confirmation || "").trim() !== "DELETE") {
        throw new HttpsError(
            "invalid-argument",
            "Type DELETE to confirm permanent account deletion.",
        );
      }

      if (!isRecentAuthentication(request.auth.token.auth_time)) {
        throw new HttpsError(
            "failed-precondition",
            "Sign in again before deleting your account.",
        );
      }

      const userId = requireSafeId(request.auth.uid, "User");
      const db = admin.firestore();
      const bucket = admin.storage().bucket();
      const churchId = await resolveChurchId(
          db,
          userId,
          request.data?.churchId,
      );

      try {
        const summary = await deleteAccountData({
          db,
          bucket,
          userId,
          churchId,
        });

        await admin.auth().deleteUser(userId);

        return {
          deleted: true,
          retainedData:
            "Confirmed financial and security records may be retained " +
            "without active account access.",
          ...summary,
        };
      } catch (error) {
        if (error instanceof HttpsError) {
          throw error;
        }

        console.error("ChurchSnap account deletion failed", {
          userId,
          churchId,
          error,
        });

        throw new HttpsError(
            "internal",
            "ChurchSnap could not complete account deletion. " +
            "No further action is required until you try again.",
        );
      }
    },
);

module.exports = {
  deleteChurchSnapAccount,
  givingRetentionAction,
  isProtectedRole,
  isRecentAuthentication,
  isRegisteredPasswordAccount,
};