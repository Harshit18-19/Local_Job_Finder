const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');

initializeApp();

// A server-side notification is created whenever an applicant submits. Reviewers
// can use this collection for a notification badge or email/push integration.
exports.notifyReviewersOfNewApplication = onDocumentCreated(
  'applications/{applicationId}',
  async (event) => {
    const application = event.data.data();
    if (!application) return;
    await getFirestore().collection('reviewerNotifications').add({
      type: 'application_submitted',
      applicationId: event.params.applicationId,
      title: 'New application awaiting approval',
      body: `${application.applicantName} applied for ${application.jobTitle} at ${application.company}.`,
      read: false,
      createdAt: FieldValue.serverTimestamp(),
    });
  },
);
