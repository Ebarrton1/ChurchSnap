import {
  after,
  before,
  beforeEach,
  test,
} from "node:test";

import {
  readFileSync,
} from "node:fs";

import {
  dirname,
  resolve,
} from "node:path";

import {
  fileURLToPath,
} from "node:url";

import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from "@firebase/rules-unit-testing";

import {
  addDoc,
  collection,
  doc,
  getDoc,
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