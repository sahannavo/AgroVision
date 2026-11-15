import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
  RulesTestEnvironment,
} from '@firebase/rules-unit-testing';
import * as fs from 'fs';
import * as path from 'path';

describe('Storage Security Rules Unit Tests', () => {
  let testEnv: RulesTestEnvironment;

  const PROJECT_ID = 'agrovision-storage-test';
  const ALICE_UID = 'alice_storage_123';
  const BOB_UID = 'bob_storage_456';

  before(async () => {
    const rulesPath = path.resolve(__dirname, '../../storage.rules');
    const storageRules = fs.readFileSync(rulesPath, 'utf8');

    testEnv = await initializeTestEnvironment({
      projectId: PROJECT_ID,
      storage: {
        rules: storageRules,
        host: '127.0.0.1',
        port: 9199,
      },
    });
  });

  after(async () => {
    if (testEnv) {
      await testEnv.cleanup();
    }
  });

  describe('Diagnoses Storage Rules', () => {
    it('only the owner can upload images under 5 MB to diagnoses/{uid}', async () => {
      const aliceContext = testEnv.authenticatedContext(ALICE_UID);
      const storage = aliceContext.storage();
      const fileRef = storage.ref(`diagnoses/${ALICE_UID}/leaf1.jpg`);

      const smallImageBuffer = Buffer.from('fake-image-bytes');

      await assertSucceeds(
        fileRef.put(smallImageBuffer, { contentType: 'image/jpeg' })
      );
    });

    it('another user cannot upload to diagnoses/{uid}', async () => {
      const bobContext = testEnv.authenticatedContext(BOB_UID);
      const storage = bobContext.storage();
      const fileRef = storage.ref(`diagnoses/${ALICE_UID}/leaf1.jpg`);

      const smallImageBuffer = Buffer.from('fake-image-bytes');

      await assertFails(
        fileRef.put(smallImageBuffer, { contentType: 'image/jpeg' })
      );
    });

    it('rejects non-image files', async () => {
      const aliceContext = testEnv.authenticatedContext(ALICE_UID);
      const storage = aliceContext.storage();
      const fileRef = storage.ref(`diagnoses/${ALICE_UID}/malicious.exe`);

      const exeBuffer = Buffer.from('not-an-image');

      await assertFails(
        fileRef.put(exeBuffer, { contentType: 'application/octet-stream' })
      );
    });
  });
});
