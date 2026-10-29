import { describe, it } from 'node:test';
import * as assert from 'node:assert';
import * as geofire from 'geofire-common';
import { PREVENTIVE_STEPS_TABLE } from '../src/onDiagnosisCreated';

describe('Outbreak Detection Clustering & Logic', () => {
  it('geofire distance calculates proximity accurately within OUTBREAK_RADIUS_KM (25km)', () => {
    // Kurunegala town (7.4863, 80.3623) and Mawathagama (~14km away: 7.4333, 80.4500)
    const dist = geofire.distanceBetween([7.4863, 80.3623], [7.4333, 80.4500]);
    assert.ok(dist < 25, `Expected distance < 25km, got ${dist}`);

    // Kurunegala to Kandy (~40km away: 7.2906, 80.6337)
    const farDist = geofire.distanceBetween([7.4863, 80.3623], [7.2906, 80.6337]);
    assert.ok(farDist > 25, `Expected distance > 25km, got ${farDist}`);
  });

  it('preventive steps table contains agronomic guidance for key nightshade diseases', () => {
    assert.ok(PREVENTIVE_STEPS_TABLE['earlyBlight']);
    assert.ok(PREVENTIVE_STEPS_TABLE['earlyBlight'].length >= 3);
    assert.ok(PREVENTIVE_STEPS_TABLE['lateBlight']);
    assert.ok(PREVENTIVE_STEPS_TABLE['bacterialSpot']);
    assert.ok(PREVENTIVE_STEPS_TABLE['leafCurl']);
  });
});
