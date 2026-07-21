# Firebase Hosting App-Shell Cache Policy

ChurchSnap's Flutter web app uses stable app-shell filenames such as
`index.html`, `flutter_bootstrap.js`, `main.dart.js`, and
`flutter_service_worker.js`.

A browser can retain an older copy of those files after a production
deployment. A versioned query string can appear correct while the plain root
URL continues loading the older cached app shell because the query string is a
different cache key.

Firebase Hosting now sends the following headers for the root URL and the
Flutter app-shell files:

```text
Cache-Control: no-cache, no-store, must-revalidate
Pragma: no-cache
Expires: 0
```

Images and other static assets keep their normal caching behavior. The policy
prioritizes reliable release updates while preserving caching for content that
does not control application startup.

After the first deployment of this policy, users who already have an older
service worker may need to clear site data once. Subsequent releases should
revalidate the normal production URL without requiring a release query string.