import { expect } from 'chai';
import { calculateDistanceKm } from '../src/onOutbreakAlertCreated';

describe('onOutbreakAlertCreated Trigger Logic Unit Tests', () => {
  it('calculates distance correctly using Haversine formula', () => {
    // Kurunegala (7.4818, 80.3609) to Dambulla (7.8742, 80.6511) is approx 54-58 km
    const distanceKm = calculateDistanceKm(7.4818, 80.3609, 7.8742, 80.6511);

    expect(distanceKm).to.be.greaterThan(50);
    expect(distanceKm).to.be.lessThan(65);
  });

  it('determines user within radius should be notified', () => {
    const centerLat = 7.4818;
    const centerLon = 80.3609;
    const radiusKm = 20.0;

    // User located 5 km away
    const userLat = 7.4918;
    const userLon = 80.3709;
    const distance = calculateDistanceKm(centerLat, centerLon, userLat, userLon);

    expect(distance).to.be.lessThanOrEqual(radiusKm);
  });

  it('determines user outside radius should not be notified', () => {
    const centerLat = 7.4818;
    const centerLon = 80.3609;
    const radiusKm = 10.0;

    // User located in Jaffna (~250 km away)
    const userLat = 9.6615;
    const userLon = 80.0255;
    const distance = calculateDistanceKm(centerLat, centerLon, userLat, userLon);

    expect(distance).to.be.greaterThan(radiusKm);
  });
});
