import { describe, it } from 'node:test';
import * as assert from 'node:assert';
import { buildRegionKey, normalizeWeatherResponse } from '../src/getWeatherForecast';

describe('Weather Functions Logic & Normalization', () => {
  it('buildRegionKey rounds coordinates to 0.1 degree resolution', () => {
    // Kurunegala coordinates: 7.4863, 80.3623
    const key = buildRegionKey(7.4863, 80.3623);
    assert.strictEqual(key, '7.5_80.4');

    // Nuwara Eliya coordinates: 6.9497, 80.7891
    const key2 = buildRegionKey(6.9497, 80.7891);
    assert.strictEqual(key2, '6.9_80.8');
  });

  it('normalizeWeatherResponse normalizes OpenWeather API payload to WeatherForecast shape', () => {
    const now = new Date('2026-10-28T10:00:00.000Z');
    const mockApiData = {
      current: {
        temp: 29.4,
        humidity: 82,
        weather: [{ main: 'Scattered Clouds', description: 'scattered clouds' }],
      },
      daily: [
        {
          dt: 1793181600,
          temp: { max: 31.2, min: 23.5 },
          weather: [{ main: 'Scattered Clouds' }],
          pop: 0.4,
        },
        {
          dt: 1793268000,
          temp: { max: 30.1, min: 24.0 },
          weather: [{ main: 'Moderate Rain' }],
          pop: 0.65,
        },
      ],
    };

    const result = normalizeWeatherResponse(mockApiData, now);

    assert.strictEqual(result.currentTemperature, 29.4);
    assert.strictEqual(result.condition, 'Scattered Clouds');
    assert.strictEqual(result.humidity, 82);
    assert.strictEqual(result.rainChance, 40);
    assert.strictEqual(result.isCached, false);
    assert.strictEqual(result.daily.length, 2);
    assert.strictEqual(result.daily[0].high, 31);
    assert.strictEqual(result.daily[0].low, 24);

    // Verify 1 hour cache duration
    const fetchedTime = new Date(result.fetchedAt).getTime();
    const expiresTime = new Date(result.expiresAt).getTime();
    assert.strictEqual(expiresTime - fetchedTime, 60 * 60 * 1000);
  });

  it('normalizeWeatherResponse generates safe fallback daily schedule when daily array is absent', () => {
    const now = new Date();
    const minimalData = {
      main: { temp: 28.0, humidity: 80 },
      weather: [{ main: 'Rain' }],
    };

    const result = normalizeWeatherResponse(minimalData, now);

    assert.strictEqual(result.currentTemperature, 28.0);
    assert.strictEqual(result.condition, 'Rain');
    assert.strictEqual(result.daily.length, 7);
  });
});
