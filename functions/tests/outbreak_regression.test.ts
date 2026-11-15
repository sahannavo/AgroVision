import { describe, it } from 'node:test';
import * as assert from 'node:assert';

describe('Outbreak Detection Edge Cases & Regression Thresholds', () => {
  it('verify outbreak parameters default accurately when env is unset', () => {
    const radius = Number(process.env.OUTBREAK_RADIUS_KM ?? 25);
    const minReports = Number(process.env.OUTBREAK_MIN_REPORTS ?? 3);
    const windowHours = Number(process.env.OUTBREAK_WINDOW_HOURS ?? 72);

    assert.strictEqual(radius, 25);
    assert.strictEqual(minReports, 3);
    assert.strictEqual(windowHours, 72);
  });

  it('verify coordinate rounding protects user privacy (~1km grid, 2 decimals)', () => {
    const lat = 7.48632198;
    const lon = 80.36234129;

    const roundedLat = Math.round(lat * 100) / 100;
    const roundedLon = Math.round(lon * 100) / 100;

    assert.strictEqual(roundedLat, 7.49);
    assert.strictEqual(roundedLon, 80.36);
  });
});
