# Open Member Profile Web Photo Stabilization

The Church Member Directory passes its `MemberDirectoryEntry` into
`AdminMemberProfileScreen` as a `ChurchMember`, including the stored
`photoUrl`.

The directory list already used `WebHtmlElementStrategy.fallback`, but the
opened profile's `_MemberIdentityCard` had a separate `Image.network` call
without that web strategy. This caused the image to appear in the list while
remaining blank in the opened profile for URLs that require an HTML image
element rather than Flutter's byte-fetching loader.

The opened profile now uses:

```dart
webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
```

The existing profile placeholder and image error handling remain unchanged.
Firebase rules and stored member data do not require modification.