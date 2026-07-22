import { readFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { after, before, beforeEach, test } from "node:test";
import { fileURLToPath } from "node:url";

import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from "@firebase/rules-unit-testing";

import {
  addDoc,
  collection,
  deleteDoc,
  deleteField,
  doc,
  getDoc,
  getDocs,
  serverTimestamp,
  setDoc,
  updateDoc,
} from "firebase/firestore";
import {
  getMetadata,
  ref,
  uploadBytes,
} from "firebase/storage";

const projectId = "demo-churchsnap-hardening";
const bucketUrl = `gs://${projectId}.appspot.com`;

const currentDirectory = dirname(fileURLToPath(import.meta.url));
const projectDirectory = resolve(currentDirectory, "..");

let testEnvironment;

function memberData({
  uid,
  churchId,
  role = "member",
  isActive = true,
  isEmailVerified = false,
}) {
  return {
    id: uid,
    churchId,
    displayName: uid,
    email: `${uid}@example.test`,
    role,
    isActive,
    isEmailVerified,
  };
}

function validPrayer({
  uid = "alice",
  name = "Test Member",
  request = "Please pray for this test request.",
  isPrivate = false,
  published = true,
} = {}) {
  return {
    createdByUid: uid,
    name,
    request,
    isPrivate,
    published,
    createdAt: serverTimestamp(),
  };
}

function validGiving({
  uid = "alice",
  giverId = uid,
} = {}) {
  return {
    giverId,
    createdByUid: uid,
    giverName: "Alice Member",
    fundId: "general-fund",
    fundName: "General Fund",
    description: "Rules test submission",
    amountMinorUnits: 2500,
    currencyCode: "USD",
    currencySymbol: "$",
    recurring: false,
    status: "pending",
    submittedAt: serverTimestamp(),
  };
}

async function seedData() {
  await testEnvironment.withSecurityRulesDisabled(async (context) => {
    const firestore = context.firestore();

    await Promise.all([
      setDoc(doc(firestore, "churches/alpha"), {
        isActive: true,
        visitorAccessEnabled: true,
      }),
      setDoc(doc(firestore, "churches/beta"), {
        isActive: true,
        visitorAccessEnabled: true,
      }),

      setDoc(
        doc(firestore, "churches/alpha/members/alice"),
        memberData({
          uid: "alice",
          churchId: "alpha",
        }),
      ),
      setDoc(
        doc(firestore, "churches/alpha/members/bob"),
        memberData({
          uid: "bob",
          churchId: "alpha",
        }),
      ),
      setDoc(
        doc(firestore, "churches/alpha/members/visitor"),
        memberData({
          uid: "visitor",
          churchId: "alpha",
          role: "visitor",
        }),
      ),
      setDoc(
        doc(firestore, "churches/alpha/members/admin"),
        memberData({
          uid: "admin",
          churchId: "alpha",
          role: "admin",
        }),
      ),
      setDoc(
        doc(firestore, "churches/alpha/members/inactive-admin"),
        memberData({
          uid: "inactive-admin",
          churchId: "alpha",
          role: "admin",
          isActive: false,
        }),
      ),
      setDoc(
        doc(firestore, "churches/beta/members/charlie"),
        memberData({
          uid: "charlie",
          churchId: "beta",
        }),
      ),

      setDoc(
        doc(firestore, "churches/alpha/resources/public-resource"),
        {
          title: "Published resource",
          published: true,
        },
      ),
      setDoc(
        doc(firestore, "churches/alpha/resources/private-resource"),
        {
          title: "Unpublished resource",
          published: false,
        },
      ),
    ]);

    const storage = context.storage(bucketUrl);
    const imageBytes = new Uint8Array([1, 2, 3, 4]);

    await Promise.all([
      uploadBytes(
        ref(
          storage,
          "churches/alpha/member_profile_photos/alice/profile.jpg",
        ),
        imageBytes,
        {
          contentType: "image/jpeg",
        },
      ),
      uploadBytes(
        ref(
          storage,
          "churches/alpha/resources/public-resource/resource.pdf",
        ),
        imageBytes,
        {
          contentType: "application/pdf",
        },
      ),
      uploadBytes(
        ref(
          storage,
          "churches/alpha/resources/private-resource/private.pdf",
        ),
        imageBytes,
        {
          contentType: "application/pdf",
        },
      ),
    ]);
  });
}

before(async () => {
  testEnvironment = await initializeTestEnvironment({
    projectId,
    firestore: {
      rules: readFileSync(
        resolve(projectDirectory, "firestore.rules"),
        "utf8",
      ),
    },
    storage: {
      rules: readFileSync(
        resolve(projectDirectory, "storage.rules"),
        "utf8",
      ),
    },
  });
});

beforeEach(async () => {
  await testEnvironment.clearFirestore();
  await testEnvironment.clearStorage();
  await seedData();
});

after(async () => {
  await testEnvironment.cleanup();
});

test(
  "approved member can submit a public prayer",
  async () => {
    const firestore =
      testEnvironment.authenticatedContext("alice").firestore();

    await assertSucceeds(
      addDoc(
        collection(
          firestore,
          "churches/alpha/prayer_requests",
        ),
        validPrayer(),
      ),
    );
  },
);

test(
  "approved member can submit a private prayer",
  async () => {
    const firestore =
      testEnvironment.authenticatedContext("alice").firestore();

    await assertSucceeds(
      addDoc(
        collection(
          firestore,
          "churches/alpha/prayer_requests",
        ),
        validPrayer({
          isPrivate: true,
          published: false,
        }),
      ),
    );
  },
);

test(
  "member cannot publish a private prayer",
  async () => {
    const firestore =
      testEnvironment.authenticatedContext("alice").firestore();

    await assertFails(
      addDoc(
        collection(
          firestore,
          "churches/alpha/prayer_requests",
        ),
        validPrayer({
          isPrivate: true,
          published: true,
        }),
      ),
    );
  },
);

test(
  "member can read own private prayer",
  async () => {
    const aliceFirestore =
      testEnvironment.authenticatedContext("alice").firestore();

    const prayerReference = await addDoc(
      collection(
        aliceFirestore,
        "churches/alpha/prayer_requests",
      ),
      validPrayer({
        isPrivate: true,
        published: false,
      }),
    );

    await assertSucceeds(getDoc(prayerReference));
  },
);

test(
  "another member cannot read a private prayer",
  async () => {
    const aliceFirestore =
      testEnvironment.authenticatedContext("alice").firestore();

    const prayerReference = await addDoc(
      collection(
        aliceFirestore,
        "churches/alpha/prayer_requests",
      ),
      validPrayer({
        isPrivate: true,
        published: false,
      }),
    );

    const bobFirestore =
      testEnvironment.authenticatedContext("bob").firestore();

    await assertFails(
      getDoc(doc(bobFirestore, prayerReference.path)),
    );
  },
);

test(
  "visitor cannot submit a prayer",
  async () => {
    const firestore =
      testEnvironment.authenticatedContext("visitor").firestore();

    await assertFails(
      addDoc(
        collection(
          firestore,
          "churches/alpha/prayer_requests",
        ),
        validPrayer(),
      ),
    );
  },
);

test(
  "approved member can submit giving for self",
  async () => {
    const firestore =
      testEnvironment.authenticatedContext("alice").firestore();

    await assertSucceeds(
      addDoc(
        collection(
          firestore,
          "churches/alpha/giving_submissions",
        ),
        validGiving(),
      ),
    );
  },
);

test(
  "member cannot forge another giver identity",
  async () => {
    const firestore =
      testEnvironment.authenticatedContext("alice").firestore();

    await assertFails(
      addDoc(
        collection(
          firestore,
          "churches/alpha/giving_submissions",
        ),
        validGiving({
          uid: "alice",
          giverId: "bob",
        }),
      ),
    );
  },
);

test(
  "member of another church cannot inject giving",
  async () => {
    const firestore =
      testEnvironment.authenticatedContext("charlie").firestore();

    await assertFails(
      addDoc(
        collection(
          firestore,
          "churches/alpha/giving_submissions",
        ),
        validGiving({
          uid: "charlie",
        }),
      ),
    );
  },
);

test(
  "member cannot verify own email through Firestore",
  async () => {
    const firestore =
      testEnvironment.authenticatedContext("alice").firestore();

    await assertFails(
      updateDoc(
        doc(
          firestore,
          "churches/alpha/members/alice",
        ),
        {
          isEmailVerified: true,
        },
      ),
    );
  },
);

test(
  "member can still update an allowed profile field",
  async () => {
    const firestore =
      testEnvironment.authenticatedContext("alice").firestore();

    await assertSucceeds(
      updateDoc(
        doc(
          firestore,
          "churches/alpha/members/alice",
        ),
        {
          displayName: "Alice Updated",
        },
      ),
    );
  },
);

async function seedJoinMember(
  uid,
  {
    role = "member",
    isActive = true,
  } = {},
) {
  await testEnvironment.withSecurityRulesDisabled(async (context) => {
    await setDoc(
      doc(context.firestore(), `churches/alpha/members/${uid}`),
      {
        displayName: uid,
        email: `${uid}@example.test`,
        role,
        isActive,
      },
    );
  });
}

async function seedJoinTarget({
  targetType = "ministry",
  targetId = "worship",
  targetName = "Worship Team",
  leaderId = "",
  active = true,
} = {}) {
  await testEnvironment.withSecurityRulesDisabled(async (context) => {
    const firestore = context.firestore();

    if (targetType === "smallGroup") {
      await setDoc(
        doc(firestore, `churches/alpha/small_groups/${targetId}`),
        {
          name: targetName,
          description: "A test small group.",
          leaderId,
          leaderName: leaderId,
          location: "Fellowship Hall",
          meetingDate: null,
          capacity: 12,
          memberIds: [],
          active,
        },
      );

      return;
    }

    await setDoc(
      doc(firestore, `churches/alpha/ministries/${targetId}`),
      {
        name: targetName,
        description: "A test ministry.",
        leaderId,
        leaderName: leaderId,
        memberIds: [],
        isActive: active,
      },
    );
  });
}

function joinRequestId({
  userId = "join-member",
  targetType = "ministry",
  targetId = "worship",
} = {}) {
  return `${targetType}__${targetId}__${userId}`;
}

function validJoinRequest({
  userId = "join-member",
  memberName = "Join Member",
  targetType = "ministry",
  targetId = "worship",
  targetName = "Worship Team",
  note = "",
} = {}) {
  return {
    userId,
    memberName,
    targetType,
    targetId,
    targetName,
    status: "pending",
    note,
    createdAt: serverTimestamp(),
    reviewedAt: null,
    reviewedByUid: "",
  };
}

test(
  "approved member can request to join an active ministry",
  async () => {
    await seedJoinMember("join-member");
    await seedJoinTarget();

    const memberFirestore =
      testEnvironment.authenticatedContext("join-member").firestore();

    await assertSucceeds(
      setDoc(
        doc(
          memberFirestore,
          `churches/alpha/group_ministry_join_requests/${
            joinRequestId()
          }`,
        ),
        validJoinRequest(),
      ),
    );
  },
);

test(
  "visitor cannot request to join a ministry",
  async () => {
    await seedJoinMember("join-visitor", { role: "visitor" });
    await seedJoinTarget();

    const visitorFirestore =
      testEnvironment.authenticatedContext("join-visitor").firestore();

    await assertFails(
      setDoc(
        doc(
          visitorFirestore,
          `churches/alpha/group_ministry_join_requests/${
            joinRequestId({ userId: "join-visitor" })
          }`,
        ),
        validJoinRequest({ userId: "join-visitor" }),
      ),
    );
  },
);

test(
  "member cannot forge another member join request",
  async () => {
    await seedJoinMember("join-member");
    await seedJoinTarget();

    const memberFirestore =
      testEnvironment.authenticatedContext("join-member").firestore();

    await assertFails(
      setDoc(
        doc(
          memberFirestore,
          `churches/alpha/group_ministry_join_requests/${
            joinRequestId({ userId: "another-member" })
          }`,
        ),
        validJoinRequest({ userId: "another-member" }),
      ),
    );
  },
);

test(
  "member can read own join request but another member cannot",
  async () => {
    await seedJoinMember("join-member");
    await seedJoinMember("join-other");
    await seedJoinTarget();

    const memberFirestore =
      testEnvironment.authenticatedContext("join-member").firestore();

    const requestReference = doc(
      memberFirestore,
      `churches/alpha/group_ministry_join_requests/${joinRequestId()}`,
    );

    await assertSucceeds(
      setDoc(requestReference, validJoinRequest()),
    );

    await assertSucceeds(getDoc(requestReference));

    const otherFirestore =
      testEnvironment.authenticatedContext("join-other").firestore();

    await assertFails(
      getDoc(
        doc(
          otherFirestore,
          `churches/alpha/group_ministry_join_requests/${
            joinRequestId()
          }`,
        ),
      ),
    );
  },
);

test(
  "member cannot approve own join request",
  async () => {
    await seedJoinMember("join-member");
    await seedJoinTarget();

    const memberFirestore =
      testEnvironment.authenticatedContext("join-member").firestore();

    const requestReference = doc(
      memberFirestore,
      `churches/alpha/group_ministry_join_requests/${joinRequestId()}`,
    );

    await assertSucceeds(
      setDoc(requestReference, validJoinRequest()),
    );

    await assertFails(
      updateDoc(requestReference, {
        status: "approved",
        reviewedAt: serverTimestamp(),
        reviewedByUid: "join-member",
      }),
    );
  },
);

test(
  "administrator can approve ministry request and add member",
  async () => {
    await seedJoinMember("join-member");
    await seedJoinMember("join-admin", { role: "admin" });
    await seedJoinTarget();

    const memberFirestore =
      testEnvironment.authenticatedContext("join-member").firestore();

    await assertSucceeds(
      setDoc(
        doc(
          memberFirestore,
          `churches/alpha/group_ministry_join_requests/${
            joinRequestId()
          }`,
        ),
        validJoinRequest(),
      ),
    );

    const adminFirestore =
      testEnvironment.authenticatedContext("join-admin").firestore();

    await assertSucceeds(
      updateDoc(
        doc(
          adminFirestore,
          `churches/alpha/group_ministry_join_requests/${
            joinRequestId()
          }`,
        ),
        {
          status: "approved",
          reviewedAt: serverTimestamp(),
          reviewedByUid: "join-admin",
        },
      ),
    );

    await assertSucceeds(
      updateDoc(
        doc(adminFirestore, "churches/alpha/ministries/worship"),
        {
          memberIds: ["join-member"],
        },
      ),
    );
  },
);

test(
  "unassigned group leader cannot review another leader request",
  async () => {
    await seedJoinMember("join-member");
    await seedJoinMember("group-leader-one", { role: "groupLeader" });
    await seedJoinMember("group-leader-two", { role: "groupLeader" });

    await seedJoinTarget({
      targetType: "smallGroup",
      targetId: "life-group",
      targetName: "Life Group",
      leaderId: "group-leader-one",
    });

    const memberFirestore =
      testEnvironment.authenticatedContext("join-member").firestore();

    const requestId = joinRequestId({
      targetType: "smallGroup",
      targetId: "life-group",
    });

    await assertSucceeds(
      setDoc(
        doc(
          memberFirestore,
          `churches/alpha/group_ministry_join_requests/${requestId}`,
        ),
        validJoinRequest({
          targetType: "smallGroup",
          targetId: "life-group",
          targetName: "Life Group",
        }),
      ),
    );

    const otherLeaderFirestore =
      testEnvironment.authenticatedContext(
        "group-leader-two",
      ).firestore();

    await assertFails(
      updateDoc(
        doc(
          otherLeaderFirestore,
          `churches/alpha/group_ministry_join_requests/${requestId}`,
        ),
        {
          status: "approved",
          reviewedAt: serverTimestamp(),
          reviewedByUid: "group-leader-two",
        },
      ),
    );
  },
);

test(
  "assigned group leader can approve group request and add member",
  async () => {
    await seedJoinMember("join-member");
    await seedJoinMember("group-leader-one", { role: "groupLeader" });

    await seedJoinTarget({
      targetType: "smallGroup",
      targetId: "life-group",
      targetName: "Life Group",
      leaderId: "group-leader-one",
    });

    const memberFirestore =
      testEnvironment.authenticatedContext("join-member").firestore();

    const requestId = joinRequestId({
      targetType: "smallGroup",
      targetId: "life-group",
    });

    await assertSucceeds(
      setDoc(
        doc(
          memberFirestore,
          `churches/alpha/group_ministry_join_requests/${requestId}`,
        ),
        validJoinRequest({
          targetType: "smallGroup",
          targetId: "life-group",
          targetName: "Life Group",
        }),
      ),
    );

    const leaderFirestore =
      testEnvironment.authenticatedContext(
        "group-leader-one",
      ).firestore();

    await assertSucceeds(
      updateDoc(
        doc(
          leaderFirestore,
          `churches/alpha/group_ministry_join_requests/${requestId}`,
        ),
        {
          status: "approved",
          reviewedAt: serverTimestamp(),
          reviewedByUid: "group-leader-one",
        },
      ),
    );

    await assertSucceeds(
      updateDoc(
        doc(
          leaderFirestore,
          "churches/alpha/small_groups/life-group",
        ),
        {
          memberIds: ["join-member"],
        },
      ),
    );
  },
);
test(
  "same-church approved member can read profile photo",
  async () => {
    const storage =
      testEnvironment.authenticatedContext("bob").storage(bucketUrl);

    await assertSucceeds(
      getMetadata(
        ref(
          storage,
          "churches/alpha/member_profile_photos/alice/profile.jpg",
        ),
      ),
    );
  },
);

test(
  "cross-church member cannot read profile photo",
  async () => {
    const storage =
      testEnvironment.authenticatedContext("charlie").storage(bucketUrl);

    await assertFails(
      getMetadata(
        ref(
          storage,
          "churches/alpha/member_profile_photos/alice/profile.jpg",
        ),
      ),
    );
  },
);

test(
  "visitor cannot read member profile photos",
  async () => {
    const storage =
      testEnvironment.authenticatedContext("visitor").storage(bucketUrl);

    await assertFails(
      getMetadata(
        ref(
          storage,
          "churches/alpha/member_profile_photos/alice/profile.jpg",
        ),
      ),
    );
  },
);

test(
  "member can upload own profile photo",
  async () => {
    const storage =
      testEnvironment.authenticatedContext("alice").storage(bucketUrl);

    await assertSucceeds(
      uploadBytes(
        ref(
          storage,
          "churches/alpha/member_profile_photos/alice/new-profile.png",
        ),
        new Uint8Array([1, 2, 3]),
        {
          contentType: "image/png",
        },
      ),
    );
  },
);

test(
  "member cannot upload another member's photo",
  async () => {
    const storage =
      testEnvironment.authenticatedContext("alice").storage(bucketUrl);

    await assertFails(
      uploadBytes(
        ref(
          storage,
          "churches/alpha/member_profile_photos/bob/profile.png",
        ),
        new Uint8Array([1, 2, 3]),
        {
          contentType: "image/png",
        },
      ),
    );
  },
);

test(
  "inactive administrator cannot upload home image",
  async () => {
    const storage =
      testEnvironment
        .authenticatedContext("inactive-admin")
        .storage(bucketUrl);

    await assertFails(
      uploadBytes(
        ref(
          storage,
          "churches/alpha/home/inactive-admin.jpg",
        ),
        new Uint8Array([1, 2, 3]),
        {
          contentType: "image/jpeg",
        },
      ),
    );
  },
);

test(
  "active administrator can upload home image",
  async () => {
    const storage =
      testEnvironment.authenticatedContext("admin").storage(bucketUrl);

    await assertSucceeds(
      uploadBytes(
        ref(
          storage,
          "churches/alpha/home/admin-home.jpg",
        ),
        new Uint8Array([1, 2, 3]),
        {
          contentType: "image/jpeg",
        },
      ),
    );
  },
);

test(
  "published resource is publicly readable",
  async () => {
    const storage =
      testEnvironment.unauthenticatedContext().storage(bucketUrl);

    await assertSucceeds(
      getMetadata(
        ref(
          storage,
          "churches/alpha/resources/public-resource/resource.pdf",
        ),
      ),
    );
  },
);

test(
  "unpublished resource is denied to normal member",
  async () => {
    const storage =
      testEnvironment.authenticatedContext("alice").storage(bucketUrl);

    await assertFails(
      getMetadata(
        ref(
          storage,
          "churches/alpha/resources/private-resource/private.pdf",
        ),
      ),
    );
  },
);

test(
  "administrator can read unpublished resource",
  async () => {
    const storage =
      testEnvironment.authenticatedContext("admin").storage(bucketUrl);

    await assertSucceeds(
      getMetadata(
        ref(
          storage,
          "churches/alpha/resources/private-resource/private.pdf",
        ),
      ),
    );
  },
);

test(
  "administrator cannot upload unsupported media type",
  async () => {
    const storage =
      testEnvironment.authenticatedContext("admin").storage(bucketUrl);

    await assertFails(
      uploadBytes(
        ref(
          storage,
          "churches/alpha/media/sermons/not-allowed.txt",
        ),
        new Uint8Array([1, 2, 3]),
        {
          contentType: "text/plain",
        },
      ),
    );
  },
);

test(
  "administrator can upload supported media image",
  async () => {
    const storage =
      testEnvironment.authenticatedContext("admin").storage(bucketUrl);

    await assertSucceeds(
      uploadBytes(
        ref(
          storage,
          "churches/alpha/media/images/allowed.jpg",
        ),
        new Uint8Array([1, 2, 3]),
        {
          contentType: "image/jpeg",
        },
      ),
    );
  },
);
// CHURCHSNAP_NOTIFICATION_INBOX_AUTHORIZATION_TESTS_V1

beforeEach(async () => {
  await testEnvironment.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();

    const aliceMember = await getDoc(
      doc(db, "churches/alpha/members/alice"),
    );

    const aliceRole = aliceMember.data()?.role ?? "member";
    const nonMatchingRole =
      aliceRole === "volunteer" ? "member" : "volunteer";

    await Promise.all([
      setDoc(
        doc(
          db,
          "churches/alpha/members/alice/notificationInbox/inbox-unread",
        ),
        {
          id: "inbox-unread",
          sourceNotificationId: "source-all",
          title: "All-member update",
          body: "This is visible in Alice's private inbox.",
          type: "announcement",
          targetRole: "all",
          recipientRole: aliceRole,
          read: false,
          createdAt: new Date("2026-07-22T10:00:00Z"),
          updatedAt: new Date("2026-07-22T10:00:00Z"),
        },
      ),
      setDoc(
        doc(
          db,
          "churches/alpha/members/alice/notificationInbox/inbox-read",
        ),
        {
          id: "inbox-read",
          sourceNotificationId: "source-role",
          title: "Previously read update",
          body: "This notification starts in the read state.",
          type: "event",
          targetRole: aliceRole,
          recipientRole: aliceRole,
          read: true,
          readAt: new Date("2026-07-22T10:01:00Z"),
          createdAt: new Date("2026-07-22T09:59:00Z"),
          updatedAt: new Date("2026-07-22T10:01:00Z"),
        },
      ),
      setDoc(
        doc(db, "churches/alpha/announcements/public-announcement"),
        {
          title: "Published announcement",
          body: "Visible publicly.",
          published: true,
          createdAt: new Date("2026-07-22T09:00:00Z"),
        },
      ),
      setDoc(
        doc(db, "churches/alpha/announcements/private-announcement"),
        {
          title: "Draft announcement",
          body: "Visible only to church administrators.",
          published: false,
          createdAt: new Date("2026-07-22T09:05:00Z"),
        },
      ),
      setDoc(
        doc(db, "churches/alpha/notifications/source-all"),
        {
          title: "All-member source",
          body: "Visible to all active approved members.",
          type: "announcement",
          targetRole: "all",
          createdAt: new Date("2026-07-22T09:10:00Z"),
        },
      ),
      setDoc(
        doc(db, "churches/alpha/notifications/source-matching-role"),
        {
          title: "Matching-role source",
          body: "Visible to Alice's role.",
          type: "volunteer",
          targetRole: aliceRole,
          createdAt: new Date("2026-07-22T09:15:00Z"),
        },
      ),
      setDoc(
        doc(db, "churches/alpha/notifications/source-other-role"),
        {
          title: "Other-role source",
          body: "Not visible to Alice.",
          type: "volunteer",
          targetRole: nonMatchingRole,
          createdAt: new Date("2026-07-22T09:20:00Z"),
        },
      ),
    ]);
  });
});

test(
  "member can read own notification inbox item",
  async () => {
    const db =
      testEnvironment.authenticatedContext("alice").firestore();

    await assertSucceeds(
      getDoc(
        doc(
          db,
          "churches/alpha/members/alice/notificationInbox/inbox-unread",
        ),
      ),
    );
  },
);

test(
  "member can list own notification inbox",
  async () => {
    const db =
      testEnvironment.authenticatedContext("alice").firestore();

    await assertSucceeds(
      getDocs(
        collection(
          db,
          "churches/alpha/members/alice/notificationInbox",
        ),
      ),
    );
  },
);

test(
  "member cannot read another member notification inbox",
  async () => {
    const db =
      testEnvironment.authenticatedContext("bob").firestore();

    await assertFails(
      getDoc(
        doc(
          db,
          "churches/alpha/members/alice/notificationInbox/inbox-unread",
        ),
      ),
    );
  },
);

test(
  "member cannot list another member notification inbox",
  async () => {
    const db =
      testEnvironment.authenticatedContext("bob").firestore();

    await assertFails(
      getDocs(
        collection(
          db,
          "churches/alpha/members/alice/notificationInbox",
        ),
      ),
    );
  },
);

test(
  "administrator can read member notification inbox",
  async () => {
    const db =
      testEnvironment.authenticatedContext("admin").firestore();

    await assertSucceeds(
      getDoc(
        doc(
          db,
          "churches/alpha/members/alice/notificationInbox/inbox-unread",
        ),
      ),
    );
  },
);

test(
  "member can mark own notification read",
  async () => {
    const db =
      testEnvironment.authenticatedContext("alice").firestore();

    await assertSucceeds(
      updateDoc(
        doc(
          db,
          "churches/alpha/members/alice/notificationInbox/inbox-unread",
        ),
        {
          read: true,
          readAt: new Date("2026-07-22T10:30:00Z"),
        },
      ),
    );
  },
);

test(
  "member can mark own notification unread",
  async () => {
    const db =
      testEnvironment.authenticatedContext("alice").firestore();

    await assertSucceeds(
      updateDoc(
        doc(
          db,
          "churches/alpha/members/alice/notificationInbox/inbox-read",
        ),
        {
          read: false,
          readAt: deleteField(),
        },
      ),
    );
  },
);

test(
  "member cannot alter notification inbox content",
  async () => {
    const db =
      testEnvironment.authenticatedContext("alice").firestore();

    await assertFails(
      updateDoc(
        doc(
          db,
          "churches/alpha/members/alice/notificationInbox/inbox-unread",
        ),
        {
          title: "Tampered title",
        },
      ),
    );
  },
);

test(
  "member cannot create notification inbox item",
  async () => {
    const db =
      testEnvironment.authenticatedContext("alice").firestore();

    await assertFails(
      setDoc(
        doc(
          db,
          "churches/alpha/members/alice/notificationInbox/client-created",
        ),
        {
          title: "Client-created notification",
          body: "This must be denied.",
          type: "announcement",
          targetRole: "all",
          read: false,
          createdAt: new Date("2026-07-22T10:35:00Z"),
        },
      ),
    );
  },
);

test(
  "member cannot delete notification inbox item",
  async () => {
    const db =
      testEnvironment.authenticatedContext("alice").firestore();

    await assertFails(
      deleteDoc(
        doc(
          db,
          "churches/alpha/members/alice/notificationInbox/inbox-unread",
        ),
      ),
    );
  },
);

test(
  "published announcement remains publicly readable",
  async () => {
    const db =
      testEnvironment.unauthenticatedContext().firestore();

    await assertSucceeds(
      getDoc(
        doc(
          db,
          "churches/alpha/announcements/public-announcement",
        ),
      ),
    );
  },
);

test(
  "normal member cannot read unpublished announcement",
  async () => {
    const db =
      testEnvironment.authenticatedContext("alice").firestore();

    await assertFails(
      getDoc(
        doc(
          db,
          "churches/alpha/announcements/private-announcement",
        ),
      ),
    );
  },
);

test(
  "administrator can read unpublished announcement",
  async () => {
    const db =
      testEnvironment.authenticatedContext("admin").firestore();

    await assertSucceeds(
      getDoc(
        doc(
          db,
          "churches/alpha/announcements/private-announcement",
        ),
      ),
    );
  },
);

test(
  "member can read notification targeted to own role",
  async () => {
    const db =
      testEnvironment.authenticatedContext("alice").firestore();

    await assertSucceeds(
      getDoc(
        doc(
          db,
          "churches/alpha/notifications/source-matching-role",
        ),
      ),
    );
  },
);

test(
  "member cannot read notification targeted to another role",
  async () => {
    const db =
      testEnvironment.authenticatedContext("alice").firestore();

    await assertFails(
      getDoc(
        doc(
          db,
          "churches/alpha/notifications/source-other-role",
        ),
      ),
    );
  },
);
// CHURCHSNAP_NOTIFICATION_UNREAD_READAT_HARDENING_V1

test(
  "member cannot retain readAt when marking notification unread",
  async () => {
    const db =
      testEnvironment.authenticatedContext("alice").firestore();

    await assertFails(
      updateDoc(
        doc(
          db,
          "churches/alpha/members/alice/notificationInbox/inbox-read",
        ),
        {
          read: false,
        },
      ),
    );
  },
);
// CHURCHSNAP_NOTIFICATION_INBOX_MEMBERSHIP_HARDENING_V1

test(
  "cross-church account cannot read inbox under own uid",
  async () => {
    await testEnvironment.withSecurityRulesDisabled(async (context) => {
      await setDoc(
        doc(
          context.firestore(),
          "churches/alpha/members/charlie/notificationInbox/cross-church",
        ),
        {
          title: "Private Alpha notification",
          body: "Charlie does not belong to Alpha.",
          type: "announcement",
          targetRole: "all",
          read: false,
          createdAt: new Date("2026-07-22T11:00:00Z"),
        },
      );
    });

    const db =
      testEnvironment.authenticatedContext("charlie").firestore();

    await assertFails(
      getDoc(
        doc(
          db,
          "churches/alpha/members/charlie/notificationInbox/cross-church",
        ),
      ),
    );
  },
);

test(
  "visitor cannot read own notification inbox",
  async () => {
    await testEnvironment.withSecurityRulesDisabled(async (context) => {
      await setDoc(
        doc(
          context.firestore(),
          "churches/alpha/members/visitor/notificationInbox/visitor-entry",
        ),
        {
          title: "Member-only notification",
          body: "Visitors must not read private member notifications.",
          type: "announcement",
          targetRole: "all",
          read: false,
          createdAt: new Date("2026-07-22T11:01:00Z"),
        },
      );
    });

    const db =
      testEnvironment.authenticatedContext("visitor").firestore();

    await assertFails(
      getDoc(
        doc(
          db,
          "churches/alpha/members/visitor/notificationInbox/visitor-entry",
        ),
      ),
    );
  },
);

test(
  "inactive member cannot read own notification inbox",
  async () => {
    await testEnvironment.withSecurityRulesDisabled(async (context) => {
      await setDoc(
        doc(
          context.firestore(),
          "churches/alpha/members/inactive-admin/notificationInbox/inactive-entry",
        ),
        {
          title: "Active-member notification",
          body: "Inactive accounts must not retain inbox access.",
          type: "announcement",
          targetRole: "administrator",
          read: false,
          createdAt: new Date("2026-07-22T11:02:00Z"),
        },
      );
    });

    const db =
      testEnvironment
        .authenticatedContext("inactive-admin")
        .firestore();

    await assertFails(
      getDoc(
        doc(
          db,
          "churches/alpha/members/inactive-admin/notificationInbox/inactive-entry",
        ),
      ),
    );
  },
);

test(
  "inactive member cannot update own notification inbox",
  async () => {
    await testEnvironment.withSecurityRulesDisabled(async (context) => {
      await setDoc(
        doc(
          context.firestore(),
          "churches/alpha/members/inactive-admin/notificationInbox/inactive-update",
        ),
        {
          title: "Inactive account notification",
          body: "This entry must not be editable by an inactive account.",
          type: "announcement",
          targetRole: "administrator",
          read: false,
          createdAt: new Date("2026-07-22T11:03:00Z"),
        },
      );
    });

    const db =
      testEnvironment
        .authenticatedContext("inactive-admin")
        .firestore();

    await assertFails(
      updateDoc(
        doc(
          db,
          "churches/alpha/members/inactive-admin/notificationInbox/inactive-update",
        ),
        {
          read: true,
          readAt: new Date("2026-07-22T11:04:00Z"),
        },
      ),
    );
  },
);
