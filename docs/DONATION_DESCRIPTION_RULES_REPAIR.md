# Donation Description Firestore Rules Repair

The donation-description rules initially contained duplicated logical
operators. The update comparison was spread across multiple lines, so a
single-line literal repair did not match it.

The corrected rules now contain valid expressions equivalent to:

```text
&& request.resource.data.get('description', '') is string
&& request.resource.data.get('description', '').size() <= 500
&& request.resource.data.get('description', '')
   == resource.data.get('description', '')
```

The first two expressions validate the optional giver description. The third
prevents an administrator from changing it while confirming or rejecting the
gift.

A regression test rejects duplicated `&&` operators even when whitespace or
line breaks occur between them.