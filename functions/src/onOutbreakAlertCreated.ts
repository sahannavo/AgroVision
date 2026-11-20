import * as admin from 'firebase-admin';
import { onDocumentCreated } from 'firebase-functions/v2/firestore';

// Initialize Firebase Admin if not already initialized
if (admin.apps.length === 0) {
  admin.initializeApp();
}

const db = admin.firestore();
const messaging = admin.messaging();

/**
 * Calculates distance between two coordinates in kilometers using Haversine formula.
 */
export function calculateDistanceKm(
  lat1: number,
  lon1: number,
  lat2: number,
  lon2: number
): number {
  const earthRadiusKm = 6371;
  const dLat = ((lat2 - lat1) * Math.PI) / 180;
  const dLon = ((lon2 - lon1) * Math.PI) / 180;

  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos((lat1 * Math.PI) / 180) *
      Math.cos((lat2 * Math.PI) / 180) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);

  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return earthRadiusKm * c;
}

/**
 * Cloud Function triggered on new documents in the outbreakAlerts collection.
 *
 * Requirements:
 * 1. Find users whose location is inside radiusKm of centerPoint.
 * 2. Collect their fcmToken values.
 * 3. Send an FCM push notification with disease name and first preventive step.
 * 4. Write one notifications document per user.
 * 5. Remove tokens that FCM reports as invalid.
 * 6. Never include another farmer's data in the notification.
 */
export const onOutbreakAlertCreated = onDocumentCreated(
  'outbreakAlerts/{alertId}',
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
      console.log('No data associated with the event');
      return;
    }

    const alertId = event.params.alertId;
    const alertData = snapshot.data();

    const diseaseName = alertData.diseaseName || 'Crop Disease';
    const radiusKm = typeof alertData.radiusKm === 'number' ? alertData.radiusKm : 20;
    const centerPoint = alertData.centerPoint || {};
    const centerLat = centerPoint.latitude ?? centerPoint.lat;
    const centerLon = centerPoint.longitude ?? centerPoint.lng;

    if (centerLat === undefined || centerLon === undefined) {
      console.error(`Alert ${alertId} missing valid coordinates:`, centerPoint);
      return;
    }

    // Extract the first preventive step safely
    const preventiveSteps = alertData.preventiveSteps || [];
    const firstStep =
      Array.isArray(preventiveSteps) && preventiveSteps.length > 0
        ? preventiveSteps[0]
        : 'Inspect nightshade fields immediately for early symptoms.';

    console.log(
      `Processing outbreak alert ${alertId} for ${diseaseName} within ${radiusKm}km of (${centerLat}, ${centerLon})`
    );

    // Query all users who have an fcmToken and location configured
    const usersSnapshot = await db
      .collection('users')
      .where('fcmToken', '!=', null)
      .get();

    const targetUsers: Array<{
      uid: string;
      fcmToken: string;
      distanceKm: number;
    }> = [];

    for (const userDoc of usersSnapshot.docs) {
      const userData = userDoc.data();
      const userLoc = userData.location;

      if (!userLoc) continue;

      const userLat = userLoc.latitude ?? userLoc.lat;
      const userLon = userLoc.longitude ?? userLoc.lng;

      if (userLat === undefined || userLon === undefined) continue;

      const distance = calculateDistanceKm(centerLat, centerLon, userLat, userLon);

      if (distance <= radiusKm) {
        targetUsers.push({
          uid: userDoc.id,
          fcmToken: userData.fcmToken,
          distanceKm: distance,
        });
      }
    }

    console.log(`Found ${targetUsers.length} user(s) inside the ${radiusKm}km radius.`);

    if (targetUsers.length === 0) {
      return;
    }

    const notificationTitle = `Disease Alert: ${diseaseName} nearby`;
    const notificationBody = `Outbreak reported within ${radiusKm}km: ${firstStep}`;

    // Send notifications and write records per user
    const nowIso = new Date().toISOString();
    const batch = db.batch();

    for (const target of targetUsers) {
      let deliveryStatus = 'PENDING';

      try {
        await messaging.send({
          token: target.fcmToken,
          notification: {
            title: notificationTitle,
            body: notificationBody,
          },
          data: {
            alertId: alertId,
            route: '/alerts',
            diseaseName: diseaseName,
          },
          android: {
            priority: 'high',
            notification: {
              channelId: 'outbreak_alerts',
              clickAction: 'FLUTTER_NOTIFICATION_CLICK',
            },
          },
        });

        deliveryStatus = 'SENT';
      } catch (err: any) {
        console.error(`Failed to send FCM to user ${target.uid}:`, err);
        deliveryStatus = 'FAILED';

        // Clean up invalid or expired tokens
        if (
          err.code === 'messaging/invalid-registration-token' ||
          err.code === 'messaging/registration-token-not-registered'
        ) {
          console.log(`Removing invalid FCM token for user ${target.uid}`);
          await db.collection('users').doc(target.uid).update({
            fcmToken: admin.firestore.FieldValue.delete(),
          });
        }
      }

      // Write one notifications document per user (preserving owner isolation)
      const notifRef = db.collection('notifications').doc();
      batch.set(notifRef, {
        userId: target.uid,
        alertId: alertId,
        title: notificationTitle,
        body: notificationBody,
        sentAt: nowIso,
        deliveryStatus: deliveryStatus,
      });
    }

    await batch.commit();
    console.log(`Finished processing notifications for alert ${alertId}`);
  }
);
