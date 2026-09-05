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
   flutterfire configure --project YOUR_FIREBASE_PROJECT_ID --platforms ios
   ```

   This creates `ios/Runner/GoogleService-Info.plist`. Keep it in the project;
   its API keys identify the app but are not secrets.

3. In the Firebase console, enable **Authentication → Sign-in method →
   Anonymous**. This is required because an application is tied to the
   authenticated submitter. Enable **Email/Password** as well: it is used for
   stable applicant and reviewer identities. Google remains an optional sign-in
   method.

4. Add your project ID to `.firebaserc` (use the sample below), then install
   the Cloud Function dependencies and deploy:

   ```sh
   cp .firebaserc.example .firebaserc
   # replace YOUR_FIREBASE_PROJECT_ID in .firebaserc
   cd functions && npm install && cd ..
   firebase deploy --only firestore:rules,functions
   ```

## Reviewer access

The supplied initial reviewer Firebase UID is already secured in the app and
Firestore rules. For additional reviewers, assign the custom claim with the
Admin SDK in a trusted environment, then have the reviewer sign out and back
in so their token refreshes:

```js
await getAuth().setCustomUserClaims(USER_UID, { role: 'reviewer' });
```

Create the reviewer with the app's Email/Password sign-up first, then use that
Firebase Authentication user's UID in the command. On their next sign-in they
will see **Application approvals** in the profile sheet. They can approve or
reject a pending application; the applicant's **Applied jobs** screen updates
immediately.

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
