import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
  RulesTestEnvironment,
} from '@firebase/rules-unit-testing';
import * as fs from 'fs';
import * as path from 'path';

describe('Firestore Security Rules Unit Tests', () => {
  let testEnv: RulesTestEnvironment;

  const PROJECT_ID = 'agrovision-test-project';
  const ALICE_UID = 'alice_farmer_123';
  const BOB_UID = 'bob_farmer_456';

  before(async () => {
    const rulesPath = path.resolve(__dirname, '../../firestore.rules');
    const firestoreRules = fs.readFileSync(rulesPath, 'utf8');

    testEnv = await initializeTestEnvironment({
      projectId: PROJECT_ID,
      firestore: {
        rules: firestoreRules,
        host: '127.0.0.1',
        port: 8080,
      },
    });
  });

  after(async () => {
    if (testEnv) {
      await testEnv.cleanup();
    }
  });

  beforeEach(async () => {
    if (testEnv) {
      await testEnv.clearFirestore();
    }
  });

  describe('Unauthenticated Access Control', () => {
    it('an unsigned user cannot read or write anything', async () => {
      const unauthContext = testEnv.unauthenticatedContext();
      const db = unauthContext.firestore();

      // Read attempts
      await assertFails(db.collection('users').doc(ALICE_UID).get());
      await assertFails(db.collection('cropProfiles').doc('plot1').get());
      await assertFails(db.collection('weatherCache').doc('colombo').get());
      await assertFails(db.collection('outbreakAlerts').doc('alert1').get());

      // Write attempts
      await assertFails(
        db.collection('users').doc(ALICE_UID).set({ name: 'Alice', userId: ALICE_UID })
      );
      await assertFails(
        db.collection('cropProfiles').doc('plot1').set({ crop: 'Tomato', area: 1.5, userId: ALICE_UID })
      );
    });
  });

  describe('CropProfiles Ownership & Isolation', () => {
    it('a user can read and write their own plot', async () => {
      const aliceContext = testEnv.authenticatedContext(ALICE_UID);
      const db = aliceContext.firestore();

      const alicePlotRef = db.collection('cropProfiles').doc('alice_plot_1');

      // Create own plot
      await assertSucceeds(
        alicePlotRef.set({
          crop: 'Tomato',
          variety: 'Thilina',
          area: 2.0,
          userId: ALICE_UID,
          plantedDate: '2026-10-15',
        })
      );

      // Read own plot
      await assertSucceeds(alicePlotRef.get());
    });

    it("a user cannot read or write another user's plot", async () => {
      // Seed Alice's plot with admin context
      await testEnv.withSecurityRulesDisabled(async (context) => {
        const adminDb = context.firestore();
        await adminDb.collection('cropProfiles').doc('alice_plot_private').set({
          crop: 'Tomato',
          area: 1.0,
          userId: ALICE_UID,
        });
      });

      const bobContext = testEnv.authenticatedContext(BOB_UID);
      const bobDb = bobContext.firestore();

      // Bob tries to read Alice's plot
      await assertFails(bobDb.collection('cropProfiles').doc('alice_plot_private').get());

      // Bob tries to update Alice's plot
      await assertFails(
        bobDb.collection('cropProfiles').doc('alice_plot_private').update({
          area: 5.0,
        })
      );
    });

    it('rejects crop plot creation when area is less than or equal to 0', async () => {
      const aliceContext = testEnv.authenticatedContext(ALICE_UID);
      const db = aliceContext.firestore();

      // Zero area
      await assertFails(
        db.collection('cropProfiles').doc('invalid_plot_0').set({
          crop: 'Potato',
          area: 0,
          userId: ALICE_UID,
        })
      );

      // Negative area
      await assertFails(
        db.collection('cropProfiles').doc('invalid_plot_neg').set({
          crop: 'Potato',
          area: -1.5,
          userId: ALICE_UID,
        })
      );
    });
  });

  describe('Diagnoses & Field Validation', () => {
    it('validates confidence is between 0 and 1 on diagnoses write', async () => {
      const aliceContext = testEnv.authenticatedContext(ALICE_UID);
      const db = aliceContext.firestore();

      // Valid confidence (0.85)
      await assertSucceeds(
        db.collection('diagnoses').doc('diag_valid').set({
          disease: 'Late Blight',
          confidence: 0.85,
          userId: ALICE_UID,
        })
      );

      // Invalid confidence (> 1.0)
      await assertFails(
        db.collection('diagnoses').doc('diag_invalid_high').set({
          disease: 'Late Blight',
          confidence: 1.25,
          userId: ALICE_UID,
        })
      );

      // Invalid confidence (< 0.0)
      await assertFails(
        db.collection('diagnoses').doc('diag_invalid_low').set({
          disease: 'Late Blight',
          confidence: -0.1,
          userId: ALICE_UID,
        })
      );
    });
  });

  describe('OutbreakAlerts & WeatherCache Client Restrictions', () => {
    it('signed-in users can read outbreakAlerts but a client cannot write outbreakAlerts', async () => {
      // Seed an alert with no userId
      await testEnv.withSecurityRulesDisabled(async (context) => {
        const adminDb = context.firestore();
        await adminDb.collection('outbreakAlerts').doc('alert_kurunegala').set({
          diseaseName: 'Early Blight',
          severity: 'HIGH',
          radiusKm: 15,
        });
      });

      const aliceContext = testEnv.authenticatedContext(ALICE_UID);
      const db = aliceContext.firestore();

      // Read succeeds
      await assertSucceeds(db.collection('outbreakAlerts').doc('alert_kurunegala').get());

      // Client write fails
      await assertFails(
        db.collection('outbreakAlerts').doc('client_created_alert').set({
          diseaseName: 'Unauthorized Alert',
          severity: 'LOW',
        })
      );
    });

    it('signed-in users cannot write to weatherCache', async () => {
      const aliceContext = testEnv.authenticatedContext(ALICE_UID);
      const db = aliceContext.firestore();

      await assertFails(
        db.collection('weatherCache').doc('kurunegala').set({
          tempC: 28,
          cachedAt: new Date().toISOString(),
        })
      );
    });
  });
});
