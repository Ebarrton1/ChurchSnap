# Church Member Directory Numeric Date Display

Church Member Directory dates now use one consistent numeric presentation:

```text
DD/MM/YYYY
```

Example:

```text
05/07/2026
```

The format is used for:

- Removed-member dates in the Church Member Directory list.
- Membership dates in the opened member profile.
- Marriage dates in the opened member profile.
- Dates of birth in the opened member profile.
- Selected dates shown in the member-edit dialog.

This update changes display formatting only. Firestore timestamps and private
member-profile date values remain unchanged.