const fs = require('node:fs');
const path = require('node:path');
const {
  after,
  before,
  beforeEach,
  test,
} = require('node:test');

const {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} = require('@firebase/rules-unit-testing');

const {
  collection,
  doc,
  getDoc,
  getDocs,
  serverTimestamp,
  setDoc,
  updateDoc,
  writeBatch,
} = require('firebase/firestore');

const {
  getBytes,
  ref,
  uploadBytes,
} = require('firebase/storage');

const projectId = 'demo-churchsnap-release-readiness';
const churchId = 'church-a';
const otherChurchId = 'church-b';
const storageBucket = `gs://${projectId}.appspot.com`;

let testEnv;

function memberData({
  id,
  role,
  church = churchId,
  isActive = true,
}) {
  return {
    id,
    churchId: church,
    displayName: `Test ${id}`,
    firstName: 'Test',
    middleName: '',
    lastName: id,
    email: `${id}@example.com`,
    phone: '876-555-0100',
    photoUrl: '',
    role,
    isActive,
    isEmailVerified: true,
    directoryVisible: true,
    directoryEmailVisible: true,
    directoryPhoneVisible: true,
    profileNameComplete: true,
    authAccountType: "registered",
  };
}

function firestoreFor(userId) {
  return testEnv.authenticatedContext(userId).firestore();
}

function storageFor(userId) {
  return testEnv.authenticatedContext(userId).storage(storageBucket);
}

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId,
    firestore: {
      rules: fs.readFileSync(
        path.resolve(__dirname, '..', '..', 'firestore.rules'),
        'utf8',
      ),
    },
    storage: {
      rules: fs.readFileSync(
        path.resolve(__dirname, '..', '..', 'storage.rules'),
        'utf8',
      ),
    },
  });
});

after(async () => {
  await testEnv.cleanup();
});

beforeEach(async () => {
  await testEnv.clearFirestore();
  await testEnv.clearStorage();

  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();

    const members = [
      memberData({ id: 'admin', role: 'admin' }),
      memberData({ id: 'pastor', role: 'pastor' }),
      memberData({ id: 'member', role: 'member' }),
      memberData({ id: 'other-member', role: 'member' }),
      memberData({ id: 'visitor', role: 'visitor' }),
      memberData({ id: 'ministry-leader', role: 'ministryLeader' }),
      memberData({ id: 'group-leader', role: 'groupLeader' }),
      memberData({ id: 'inactive-member', role: 'member', isActive: false }),
      memberData({
        id: 'cross-church-member',
        role: 'member',
        church: otherChurchId,
      }),
    ];

    const writes = [
      setDoc(doc(db, 'churches', churchId), {
        name: 'Church A',
        isActive: true,
        visitorAccessEnabled: true,
      }),
      setDoc(doc(db, 'churches', otherChurchId), {
        name: 'Church B',
        isActive: true,
        visitorAccessEnabled: true,
      }),
      setDoc(doc(db, 'churches', churchId, 'events', 'published-event'), {
        title: 'Published Event',
        published: true,
        attendeeIds: [],
        rsvpCount: 0,
      }),
      setDoc(doc(db, 'churches', churchId, 'events', 'member-event'), {
        title: 'Member Event',
        published: false,
        attendeeIds: [],
        rsvpCount: 0,
      }),
      setDoc(doc(db, 'churches', churchId, 'ministries', 'owned-ministry'), {
        name: 'Owned Ministry',
        leaderId: 'ministry-leader',
        memberIds: [],
        isActive: true,
      }),
      setDoc(doc(db, 'churches', churchId, 'ministries', 'other-ministry'), {
        name: 'Other Ministry',
        leaderId: 'someone-else',
        memberIds: [],
        isActive: true,
      }),
      setDoc(doc(db, 'churches', churchId, 'small_groups', 'owned-group'), {
        name: 'Owned Group',
        leaderId: 'group-leader',
        memberIds: [],
        isActive: true,
      }),
      setDoc(doc(db, 'churches', churchId, 'small_groups', 'other-group'), {
        name: 'Other Group',
        leaderId: 'someone-else',
        memberIds: [],
        isActive: true,
      }),
      setDoc(
        doc(db, 'churches', churchId, 'memberPrivateProfiles', 'member'),
        {
          firstName: 'Test',
          lastName: 'member',
          dateOfBirth: new Date('1990-01-01T00:00:00Z'),
        },
      ),
      setDoc(
        doc(
          db,
          'churches',
          churchId,
          'memberPrivateProfiles',
          'other-member',
        ),
        {
          firstName: 'Test',
          lastName: 'other-member',
          dateOfBirth: new Date('1991-01-01T00:00:00Z'),
        },
      ),
    ];

    for (const member of members) {
      writes.push(
        setDoc(
          doc(db, 'churches', member.churchId, 'members', member.id),
          member,
        ),
      );
    }

    await Promise.all(writes);
  });
});

test('public users can read public church and published event data', async () => {
  const db = testEnv.unauthenticatedContext().firestore();

  await assertSucceeds(getDoc(doc(db, 'churches', churchId)));
  await assertSucceeds(
    getDoc(doc(db, 'churches', churchId, 'events', 'published-event')),
  );
  await assertFails(
    getDoc(doc(db, 'churches', churchId, 'events', 'member-event')),
  );
});

test('visitors remain outside the member directory and member-only event data', async () => {
  const db = firestoreFor('visitor');

  await assertSucceeds(
    getDoc(doc(db, 'churches', churchId, 'events', 'published-event')),
  );
  await assertFails(
    getDoc(doc(db, 'churches', churchId, 'events', 'member-event')),
  );
  await assertFails(
    getDocs(collection(db, 'churches', churchId, 'members')),
  );
});

test('approved members can list the directory and read member-only events', async () => {
  const db = firestoreFor('member');

  await assertSucceeds(
    getDocs(collection(db, 'churches', churchId, 'members')),
  );
  await assertSucceeds(
    getDoc(doc(db, 'churches', churchId, 'events', 'member-event')),
  );
});

test('members can read only their own private profile', async () => {
  const db = firestoreFor('member');

  await assertSucceeds(
    getDoc(
      doc(db, 'churches', churchId, 'memberPrivateProfiles', 'member'),
    ),
  );
  await assertFails(
    getDoc(
      doc(
        db,
        'churches',
        churchId,
        'memberPrivateProfiles',
        'other-member',
      ),
    ),
  );
});

test('members may update approved self-profile fields but not their role', async () => {
  const db = firestoreFor('member');
  const memberRef = doc(db, 'churches', churchId, 'members', 'member');

  await assertSucceeds(
    updateDoc(memberRef, {
      phone: '876-555-0199',
      updatedAt: serverTimestamp(),
    }),
  );

  await assertFails(
    updateDoc(memberRef, {
      role: 'admin',
      updatedAt: serverTimestamp(),
    }),
  );
});

test('inactive members cannot use approved-member reads', async () => {
  const db = firestoreFor('inactive-member');

  await assertFails(
    getDocs(collection(db, 'churches', churchId, 'members')),
  );
  await assertFails(
    getDoc(
      doc(
        db,
        'churches',
        churchId,
        'memberPrivateProfiles',
        'inactive-member',
      ),
    ),
  );
});

test('membership in another church does not grant cross-church access', async () => {
  const db = firestoreFor('cross-church-member');

  await assertFails(
    getDocs(collection(db, 'churches', churchId, 'members')),
  );
});

test('ministry leaders can update only their assigned ministry', async () => {
  const db = firestoreFor('ministry-leader');

  await assertSucceeds(
    updateDoc(
      doc(db, 'churches', churchId, 'ministries', 'owned-ministry'),
      { name: 'Updated Owned Ministry' },
    ),
  );

  await assertFails(
    updateDoc(
      doc(db, 'churches', churchId, 'ministries', 'other-ministry'),
      { name: 'Unauthorized Update' },
    ),
  );
});

test('group leaders can update only their assigned small group', async () => {
  const db = firestoreFor('group-leader');

  await assertSucceeds(
    updateDoc(
      doc(db, 'churches', churchId, 'small_groups', 'owned-group'),
      { name: 'Updated Owned Group' },
    ),
  );

  await assertFails(
    updateDoc(
      doc(db, 'churches', churchId, 'small_groups', 'other-group'),
      { name: 'Unauthorized Update' },
    ),
  );

  await assertFails(
    updateDoc(
      doc(db, 'churches', churchId, 'ministries', 'owned-ministry'),
      { name: 'Wrong Leader Type' },
    ),
  );
});

test('ordinary members cannot manage ministry or group records', async () => {
  const db = firestoreFor('member');

  await assertFails(
    updateDoc(
      doc(db, 'churches', churchId, 'ministries', 'owned-ministry'),
      { name: 'Member Update' },
    ),
  );

  await assertFails(
    updateDoc(
      doc(db, 'churches', churchId, 'small_groups', 'owned-group'),
      { name: 'Member Update' },
    ),
  );
});

test('administrators and pastors can manage general admin content', async () => {
  const adminDb = firestoreFor('admin');
  const pastorDb = firestoreFor('pastor');

  await assertSucceeds(
    updateDoc(
      doc(adminDb, 'churches', churchId, 'events', 'member-event'),
      { title: 'Administrator Updated Event' },
    ),
  );

  await assertSucceeds(
    updateDoc(
      doc(pastorDb, 'churches', churchId, 'events', 'member-event'),
      { title: 'Pastor Updated Event' },
    ),
  );
});

test('only exact administrators can complete audited staff-role changes', async () => {
  const adminDb = firestoreFor('admin');
  const memberRef = doc(
    adminDb,
    'churches',
    churchId,
    'members',
    'other-member',
  );
  const auditRef = doc(
    adminDb,
    'churches',
    churchId,
    'admin_audit_logs',
    'admin-role-change',
  );

  const batch = writeBatch(adminDb);
  batch.update(memberRef, {
    role: 'volunteer',
    roleUpdatedAt: serverTimestamp(),
    roleUpdatedBy: 'admin',
    updatedAt: serverTimestamp(),
  });
  batch.set(auditRef, {
    action: 'roleChanged',
    actorId: 'admin',
    actorRole: 'admin',
    targetMemberId: 'other-member',
    createdAt: serverTimestamp(),
  });

  await assertSucceeds(batch.commit());
});

test('pastors cannot perform exact-administrator governance actions', async () => {
  const pastorDb = firestoreFor('pastor');
  const memberRef = doc(
    pastorDb,
    'churches',
    churchId,
    'members',
    'other-member',
  );
  const auditRef = doc(
    pastorDb,
    'churches',
    churchId,
    'admin_audit_logs',
    'pastor-role-change',
  );

  const batch = writeBatch(pastorDb);
  batch.update(memberRef, {
    role: 'volunteer',
    roleUpdatedAt: serverTimestamp(),
    roleUpdatedBy: 'pastor',
    updatedAt: serverTimestamp(),
  });
  batch.set(auditRef, {
    action: 'roleChanged',
    actorId: 'pastor',
    actorRole: 'pastor',
    targetMemberId: 'other-member',
    createdAt: serverTimestamp(),
  });

  await assertFails(batch.commit());
});

test('members can upload an image only to their own profile-photo path', async () => {
  const storage = storageFor('member');
  const image = new Uint8Array([137, 80, 78, 71]);

  await assertSucceeds(
    uploadBytes(
      ref(
        storage,
        `churches/${churchId}/member_profile_photos/member/profile.png`,
      ),
      image,
      { contentType: 'image/png' },
    ),
  );

  await assertFails(
    uploadBytes(
      ref(
        storage,
        `churches/${churchId}/member_profile_photos/other-member/profile.png`,
      ),
      image,
      { contentType: 'image/png' },
    ),
  );
});

test('visitors cannot upload member profile photographs', async () => {
  const storage = storageFor('visitor');

  await assertFails(
    uploadBytes(
      ref(
        storage,
        `churches/${churchId}/member_profile_photos/visitor/profile.png`,
      ),
      new Uint8Array([137, 80, 78, 71]),
      { contentType: 'image/png' },
    ),
  );
});

test('administrators can upload a profile image for another member', async () => {
  const storage = storageFor('admin');

  await assertSucceeds(
    uploadBytes(
      ref(
        storage,
        `churches/${churchId}/member_profile_photos/member/admin-upload.png`,
      ),
      new Uint8Array([137, 80, 78, 71]),
      { contentType: 'image/png' },
    ),
  );
});

test('profile-photo uploads reject non-image content', async () => {
  const storage = storageFor('member');

  await assertFails(
    uploadBytes(
      ref(
        storage,
        `churches/${churchId}/member_profile_photos/member/profile.txt`,
      ),
      new TextEncoder().encode('not an image'),
      { contentType: 'text/plain' },
    ),
  );
});

test('approved members can read profile images while visitors cannot', async () => {
  const adminStorage = storageFor('admin');
  const objectPath =
    `churches/${churchId}/member_profile_photos/member/read-test.png`;
  const objectRef = ref(adminStorage, objectPath);

  await assertSucceeds(
    uploadBytes(
      objectRef,
      new Uint8Array([137, 80, 78, 71]),
      { contentType: 'image/png' },
    ),
  );

  await assertSucceeds(getBytes(ref(storageFor('member'), objectPath)));
  await assertFails(getBytes(ref(storageFor('visitor'), objectPath)));
});

// CHURCHSNAP_REGISTERED_ACCOUNT_ROLE_GUARD_TESTS_V3
const {
  assertFails: roleGuardAssertFails,
  assertSucceeds: roleGuardAssertSucceeds,
  initializeTestEnvironment: initializeRoleGuardTestEnvironment,
} = require("@firebase/rules-unit-testing");
const {
  collection: roleGuardCollection,
  doc: roleGuardDoc,
  getDocs: roleGuardGetDocs,
  setDoc: roleGuardSetDoc,
  updateDoc: roleGuardUpdateDoc,
} = require("firebase/firestore");
const {
  ref: roleGuardStorageRef,
  uploadBytes: roleGuardUploadBytes,
} = require("firebase/storage");
const {
  after: roleGuardAfter,
  before: roleGuardBefore,
  beforeEach: roleGuardBeforeEach,
  describe: roleGuardDescribe,
  test: roleGuardTest,
} = require("node:test");
const { readFileSync: roleGuardReadFileSync } = require("node:fs");
const { resolve: roleGuardResolve } = require("node:path");

roleGuardDescribe("registered-account role guard", () => {
  let roleGuardEnvironment;

  roleGuardBefore(async () => {
    roleGuardEnvironment = await initializeRoleGuardTestEnvironment({
      projectId: "demo-churchsnap-release-readiness",
      firestore: {
        rules: roleGuardReadFileSync(
          roleGuardResolve(__dirname, "../../firestore.rules"),
          "utf8",
        ),
      },
      storage: {
        rules: roleGuardReadFileSync(
          roleGuardResolve(__dirname, "../../storage.rules"),
          "utf8",
        ),
      },
    });
  });

  roleGuardBeforeEach(async () => {
    await roleGuardEnvironment.clearFirestore();
  });

  roleGuardAfter(async () => {
    await roleGuardEnvironment.cleanup();
  });

  roleGuardTest(
    "rejects anonymous promotion, allows registered promotion and guest repair",
    async () => {
      await roleGuardEnvironment.withSecurityRulesDisabled(async (context) => {
        const db = context.firestore();

        await roleGuardSetDoc(
          roleGuardDoc(db, "churches/alpha"),
          {
            isActive: true,
            visitorAccessEnabled: true,
          },
        );

        await roleGuardSetDoc(
          roleGuardDoc(db, "churches/alpha/members/guard-admin"),
          {
            id: "guard-admin",
            churchId: "alpha",
            displayName: "Guard Admin",
            email: "admin@example.com",
            role: "admin",
            isActive: true,
            authAccountType: "registered",
          },
        );

        await roleGuardSetDoc(
          roleGuardDoc(db, "churches/alpha/members/guard-anonymous"),
          {
            id: "guard-anonymous",
            churchId: "alpha",
            displayName: "Guest Visitor",
            email: "",
            role: "visitor",
            isActive: true,
            authAccountType: "anonymous",
          },
        );

        await roleGuardSetDoc(
          roleGuardDoc(db, "churches/alpha/members/guard-registered"),
          {
            id: "guard-registered",
            churchId: "alpha",
            displayName: "Registered Visitor",
            email: "member@example.com",
            role: "visitor",
            isActive: true,
            authAccountType: "registered",
          },
        );

        await roleGuardSetDoc(
          roleGuardDoc(db, "churches/alpha/members/guard-malformed-guest"),
          {
            id: "guard-malformed-guest",
            churchId: "alpha",
            displayName: "Malformed Guest",
            email: "",
            role: "member",
            isActive: true,
            authAccountType: "anonymous",
          },
        );
      });

      const adminDb = roleGuardEnvironment
        .authenticatedContext("guard-admin", {
          firebase: { sign_in_provider: "password" },
        })
        .firestore();

      await roleGuardAssertFails(
        roleGuardUpdateDoc(
          roleGuardDoc(adminDb, "churches/alpha/members/guard-anonymous"),
          {
            role: "member",
            roleUpdatedAt: new Date("2026-08-07T18:00:00Z"),
            roleUpdatedBy: "guard-admin",
          },
        ),
      );

      await roleGuardAssertFails(
        roleGuardUpdateDoc(
          roleGuardDoc(adminDb, "churches/alpha/members/guard-anonymous"),
          {
            role: "admin",
            roleUpdatedAt: new Date("2026-08-07T18:01:00Z"),
            roleUpdatedBy: "guard-admin",
          },
        ),
      );

      await roleGuardAssertSucceeds(
        roleGuardUpdateDoc(
          roleGuardDoc(adminDb, "churches/alpha/members/guard-registered"),
          {
            role: "member",
            roleUpdatedAt: new Date("2026-08-07T18:02:00Z"),
            roleUpdatedBy: "guard-admin",
          },
        ),
      );

      await roleGuardAssertSucceeds(
        roleGuardUpdateDoc(
          roleGuardDoc(adminDb, "churches/alpha/members/guard-malformed-guest"),
          {
            role: "visitor",
            roleUpdatedAt: new Date("2026-08-07T18:03:00Z"),
            roleUpdatedBy: "guard-admin",
          },
        ),
      );
    },
  );

  roleGuardTest(
    "users may only self-tag the account type matching their auth token",
    async () => {
      await roleGuardEnvironment.withSecurityRulesDisabled(async (context) => {
        const db = context.firestore();

        await roleGuardSetDoc(
          roleGuardDoc(db, "churches/alpha"),
          {
            isActive: true,
            visitorAccessEnabled: true,
          },
        );

        await roleGuardSetDoc(
          roleGuardDoc(db, "churches/alpha/members/guard-password-user"),
          {
            id: "guard-password-user",
            churchId: "alpha",
            displayName: "Password User",
            email: "password@example.com",
            role: "visitor",
            isActive: true,
          },
        );

        await roleGuardSetDoc(
          roleGuardDoc(db, "churches/alpha/members/guard-anon-user"),
          {
            id: "guard-anon-user",
            churchId: "alpha",
            displayName: "Guest Visitor",
            email: "",
            role: "visitor",
            isActive: true,
          },
        );
      });

      const passwordDb = roleGuardEnvironment
        .authenticatedContext("guard-password-user", {
          firebase: { sign_in_provider: "password" },
        })
        .firestore();

      await roleGuardAssertSucceeds(
        roleGuardUpdateDoc(
          roleGuardDoc(
            passwordDb,
            "churches/alpha/members/guard-password-user",
          ),
          {
            authAccountType: "registered",
            authAccountTypeUpdatedAt: new Date("2026-08-07T18:04:00Z"),
          },
        ),
      );

      const anonymousDb = roleGuardEnvironment
        .authenticatedContext("guard-anon-user", {
          provider_id: "anonymous",
          firebase: { sign_in_provider: "anonymous" },
        })
        .firestore();

      await roleGuardAssertSucceeds(
        roleGuardUpdateDoc(
          roleGuardDoc(
            anonymousDb,
            "churches/alpha/members/guard-anon-user",
          ),
          {
            authAccountType: "anonymous",
            authAccountTypeUpdatedAt: new Date("2026-08-07T18:05:00Z"),
          },
        ),
      );

      await roleGuardAssertFails(
        roleGuardUpdateDoc(
          roleGuardDoc(
            anonymousDb,
            "churches/alpha/members/guard-anon-user",
          ),
          {
            authAccountType: "registered",
            authAccountTypeUpdatedAt: new Date("2026-08-07T18:06:00Z"),
          },
        ),
      );
    },
  );

  roleGuardTest(
    "anonymous auth cannot use a stale elevated member role",
    async () => {
      await roleGuardEnvironment.withSecurityRulesDisabled(async (context) => {
        const db = context.firestore();

        await roleGuardSetDoc(
          roleGuardDoc(db, "churches/alpha"),
          {
            isActive: true,
            visitorAccessEnabled: true,
          },
        );

        await roleGuardSetDoc(
          roleGuardDoc(db, "churches/alpha/members/guard-stale-anon"),
          {
            id: "guard-stale-anon",
            churchId: "alpha",
            displayName: "Stale Guest",
            email: "",
            role: "member",
            isActive: true,
            authAccountType: "anonymous",
          },
        );
      });

      const anonymousDb = roleGuardEnvironment
        .authenticatedContext("guard-stale-anon", {
          provider_id: "anonymous",
          firebase: { sign_in_provider: "anonymous" },
        })
        .firestore();

      await roleGuardAssertFails(
        roleGuardGetDocs(
          roleGuardCollection(anonymousDb, "churches/alpha/members"),
        ),
      );
    },
  );
  roleGuardTest(
    "anonymous stale admin cannot use privileged Storage writes",
    async () => {
      await roleGuardEnvironment.withSecurityRulesDisabled(async (context) => {
        const db = context.firestore();

        await roleGuardSetDoc(
          roleGuardDoc(db, "churches/alpha"),
          {
            isActive: true,
            visitorAccessEnabled: true,
          },
        );

        await roleGuardSetDoc(
          roleGuardDoc(db, "churches/alpha/members/guard-stale-storage-admin"),
          {
            id: "guard-stale-storage-admin",
            churchId: "alpha",
            displayName: "Stale Storage Admin",
            email: "",
            role: "admin",
            isActive: true,
            authAccountType: "anonymous",
          },
        );

        await roleGuardSetDoc(
          roleGuardDoc(db, "churches/alpha/members/guard-storage-admin"),
          {
            id: "guard-storage-admin",
            churchId: "alpha",
            displayName: "Registered Storage Admin",
            email: "storage-admin@example.com",
            role: "admin",
            isActive: true,
            authAccountType: "registered",
          },
        );
      });

      const bucketUrl = "gs://demo-churchsnap-release-readiness.appspot.com";
      const imageBytes = new Uint8Array([1, 2, 3, 4]);

      const anonymousStorage = roleGuardEnvironment
        .authenticatedContext("guard-stale-storage-admin", {
          provider_id: "anonymous",
          firebase: { sign_in_provider: "anonymous" },
        })
        .storage(bucketUrl);

      await roleGuardAssertFails(
        roleGuardUploadBytes(
          roleGuardStorageRef(
            anonymousStorage,
            "churches/alpha/home/stale-anonymous-admin.jpg",
          ),
          imageBytes,
          { contentType: "image/jpeg" },
        ),
      );

      const registeredStorage = roleGuardEnvironment
        .authenticatedContext("guard-storage-admin", {
          firebase: { sign_in_provider: "password" },
        })
        .storage(bucketUrl);

      await roleGuardAssertSucceeds(
        roleGuardUploadBytes(
          roleGuardStorageRef(
            registeredStorage,
            "churches/alpha/home/registered-admin.jpg",
          ),
          imageBytes,
          { contentType: "image/jpeg" },
        ),
      );
    },
  );
});
