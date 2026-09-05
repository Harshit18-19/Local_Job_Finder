# Local Job Finder

Flutter application for discovering local jobs and submitting applications.
Applications are stored in Cloud Firestore, begin with a `pending` status, and
can only be approved or rejected by Firebase Auth users with the `reviewer`
custom claim.

## One-time Firebase setup

The repository intentionally does not contain a Firebase project ID or platform
configuration files. Connect it to your own Firebase project before running the
application flow.

1. Install the Firebase CLI and FlutterFire CLI:

   ```sh
   npm install -g firebase-tools
   dart pub global activate flutterfire_cli
   ```

2. Sign in and configure the Flutter platforms you intend to ship:

   ```sh
   firebase login
   flutterfire configure --project YOUR_FIREBASE_PROJECT_ID --platforms android,ios,web,macos
   ```

   This replaces the placeholder `lib/firebase_options.dart` and creates the
   native Firebase config files. Keep those files in the project; their API
   keys identify the app but are not secrets.

3. In the Firebase console, enable **Authentication → Sign-in method →
   Anonymous**. This is required because an application is tied to the
   authenticated submitter. Also enable Email/Password and Google if you decide
   to migrate the app's existing local login screens to Firebase Auth.

4. Add your project ID to `.firebaserc` (use the sample below), then install
   the Cloud Function dependencies and deploy:

   ```sh
   cp .firebaserc.example .firebaserc
   # replace YOUR_FIREBASE_PROJECT_ID in .firebaserc
   cd functions && npm install && cd ..
   firebase deploy --only firestore:rules,functions
   ```

## Reviewer access

Reviewer access is deliberately server-controlled. Assign the custom claim with
the Admin SDK in a trusted environment, then have the reviewer sign out and
back in so their token refreshes:

```js
await getAuth().setCustomUserClaims(USER_UID, { role: 'reviewer' });
```

The deployed function writes a reviewer notification when a new Firestore
application is created. Firestore rules prevent applicants from changing their
application after submission and prevent non-reviewers from reading the review
queue.

## Verify

```sh
flutter pub get
flutter analyze
flutter run
```
