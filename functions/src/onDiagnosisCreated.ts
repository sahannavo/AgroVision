import * as admin from 'firebase-admin';
import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import * as geofire from 'geofire-common';

/**
 * Standard agronomic preventive steps mapped to detected diseases.
 */
export const PREVENTIVE_STEPS_TABLE: Record<string, string[]> = {
  earlyBlight: [
    'Apply copper-based fungicide or Mancozeb at first sign of concentric spots',
    'Prune and destroy lower infected leaves to improve plant aeration',
    'Avoid overhead sprinkler irrigation; switch to drip lines',
  ],
  lateBlight: [
    'Apply systemic fungicide (e.g., Metalaxyl or Dimethomorph)',
    'Rogue and safely destroy severely infected plants immediately',
    'Avoid foliar wetness and harvesting under rain',
  ],
  bacterialSpot: [
    'Spray copper hydroxide mixed with Mancozeb',
    'Disinfect farm pruning shears and stakes with 10% bleach solution',
    'Procure certified pathogen-free seedlings for next planting cycles',
  ],
  leafCurl: [
    'Control whitefly vectors using yellow sticky traps and neem kernel extract',
    'Eradicate solanaceous volunteer weeds that harbor viruses',
    'Cover seedbeds with 40-mesh insect-proof netting',
  ],
};

/**
 * Firestore Trigger: onDiagnosisCreated.
 *
 * Runs whenever a new diagnosis record is written to Firestore.
 * - Disregards healthy scans or low-confidence classifications (< 0.70).
 * - Identifies spatial clusters within OUTBREAK_RADIUS_KM and temporal window OUTBREAK_WINDOW_HOURS.
 * - When reaching OUTBREAK_MIN_REPORTS, generates or updates an outbreakAlerts document.
 * - Privacy guaranteed: Alert stores only rounded ~1km center coordinates, with zero PII or user IDs.
 */
export const onDiagnosisCreated = onDocumentCreated(
  'diagnoses/{diagnosisId}',
  async (event) => {
    const snap = event.data;
    if (!snap) return;

    const data = snap.data();
    const { predictedClass, confidenceScore, location } = data;

    // 1. Filter out healthy or low confidence scans (< 0.70)
    if (!predictedClass || typeof predictedClass !== 'string') return;
    if (predictedClass.toLowerCase().includes('healthy')) return;
    if (typeof confidenceScore !== 'number' || confidenceScore < 0.70) return;
    if (
      !location ||
      typeof location.latitude !== 'number' ||
      typeof location.longitude !== 'number'
    ) {
      return;
    }

    const db = admin.firestore();
    const radiusKm = parseFloat(process.env.OUTBREAK_RADIUS_KM || '25');
    const windowHours = parseFloat(process.env.OUTBREAK_WINDOW_HOURS || '72');
    const minReports = parseInt(process.env.OUTBREAK_MIN_REPORTS || '3', 10);

    const now = new Date();
    const windowStart = new Date(now.getTime() - windowHours * 60 * 60 * 1000);
    const centerLat = location.latitude;
    const centerLon = location.longitude;

    // 2. Query matching recent diagnoses of the same pathogen
    const recentSnap = await db
      .collection('diagnoses')
      .where('predictedClass', '==', predictedClass)
      .where('diagnosedAt', '>=', admin.firestore.Timestamp.fromDate(windowStart))
      .get();

    let matchingReports = 0;
    for (const doc of recentSnap.docs) {
      const d = doc.data();
      if (
        d.location &&
        typeof d.location.latitude === 'number' &&
        typeof d.location.longitude === 'number'
      ) {
        const dist = geofire.distanceBetween(
          [centerLat, centerLon],
          [d.location.latitude, d.location.longitude]
        );
        if (dist <= radiusKm) {
          matchingReports++;
        }
      }
    }

    // 3. When threshold is met
    if (matchingReports >= minReports) {
      const activeAlertsSnap = await db
        .collection('outbreakAlerts')
        .where('diseaseType', '==', predictedClass)
        .get();

      let existingAlertDoc: FirebaseFirestore.DocumentSnapshot | null = null;
      for (const alertDoc of activeAlertsSnap.docs) {
        const alertData = alertDoc.data();
        if (alertData.centerPoint) {
          const dist = geofire.distanceBetween(
            [centerLat, centerLon],
            [alertData.centerPoint.latitude, alertData.centerPoint.longitude]
          );
          if (dist <= radiusKm) {
            existingAlertDoc = alertDoc;
            break;
          }
        }
      }

      if (existingAlertDoc) {
        await existingAlertDoc.ref.update({
          reportCount: matchingReports,
          lastReportedAt: admin.firestore.Timestamp.fromDate(now),
        });
        console.log(`Updated outbreakAlerts ${existingAlertDoc.id} count: ${matchingReports}`);
      } else {
        // Privacy: Round coordinates to 0.01 degree (~1.1 km)
        const roundedLat = Math.round(centerLat * 100) / 100;
        const roundedLon = Math.round(centerLon * 100) / 100;

        const preventiveSteps =
          PREVENTIVE_STEPS_TABLE[predictedClass] || [
            'Inspect adjacent solanaceous plots for symptoms',
            'Isolate and sanitize diseased crop stands',
            'Notify local agricultural extension service officers',
          ];

        const alertRef = await db.collection('outbreakAlerts').add({
          diseaseType: predictedClass,
          centerPoint: new admin.firestore.GeoPoint(roundedLat, roundedLon),
          radiusKm,
          reportCount: matchingReports,
          preventiveSteps,
          createdAt: admin.firestore.Timestamp.fromDate(now),
        });
        console.log(`Created new outbreakAlerts ${alertRef.id} for ${predictedClass}`);
      }
    }
  }
);
