"use strict";

const test = require("node:test");
const assert = require("node:assert/strict");

const {
  givingRetentionAction,
  isProtectedRole,
  isRecentAuthentication,
  isRegisteredPasswordAccount,
} = require("./account_deletion");

test("recent authentication is accepted for five minutes", () => {
  assert.equal(isRecentAuthentication(1000, 1299), true);
  assert.equal(isRecentAuthentication(1000, 1301), false);
  assert.equal(isRecentAuthentication(undefined, 1000), false);
});

test("only registered password accounts can invoke deletion", () => {
  assert.equal(
      isRegisteredPasswordAccount({
        email: "member@example.com",
        firebase: {sign_in_provider: "password"},
      }),
      true,
  );

  assert.equal(
      isRegisteredPasswordAccount({
        firebase: {sign_in_provider: "anonymous"},
      }),
      false,
  );

  assert.equal(
      isRegisteredPasswordAccount({
        email: "member@example.com",
        firebase: {sign_in_provider: "google.com"},
      }),
      false,
  );

  assert.equal(isRegisteredPasswordAccount({}), false);
});

test("protected church leadership roles cannot self-delete", () => {
  assert.equal(isProtectedRole("admin"), true);
  assert.equal(isProtectedRole("pastor"), true);
  assert.equal(isProtectedRole("groupLeader"), true);
  assert.equal(isProtectedRole("ministryLeader"), true);
  assert.equal(isProtectedRole("member"), false);
  assert.equal(isProtectedRole("visitor"), false);
});

test("confirmed giving is anonymized and pending giving is deleted", () => {
  assert.equal(givingRetentionAction("confirmed"), "anonymize");
  assert.equal(givingRetentionAction("verified"), "anonymize");
  assert.equal(givingRetentionAction("received"), "anonymize");
  assert.equal(givingRetentionAction("pending"), "delete");
  assert.equal(givingRetentionAction("rejected"), "delete");
});