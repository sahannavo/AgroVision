import * as admin from 'firebase-admin';
import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { WeatherForecastData, DailyForecastData } from './types';

/**
 * Builds a deterministic region key by rounding geographic coordinates to 0.1 degree (~11km).
 */
export function buildRegionKey(lat: number, lon: number): string {
  return `${lat.toFixed(1)}_${lon.toFixed(1)}`;
}

/**
 * Maps OpenWeatherMap API response payload to the normalized AgroVision WeatherForecast data format.
 */
export function normalizeWeatherResponse(
  raw: any,
  now: Date
): WeatherForecastData {
  const currentTemp = raw.current?.temp ?? raw.main?.temp ?? 29.0;
  const condition =
    raw.current?.weather?.[0]?.main ??
    raw.weather?.[0]?.main ??
    'Scattered Clouds';
  const humidity = raw.current?.humidity ?? raw.main?.humidity ?? 85;
  const rainChance = Math.round(
    (raw.daily?.[0]?.pop ?? (raw.rain ? 0.6 : 0.35)) * 100
  );

  const daily: DailyForecastData[] = [];
  if (Array.isArray(raw.daily)) {
    for (let i = 0; i < Math.min(raw.daily.length, 7); i++) {
      const d = raw.daily[i];
      const date = new Date(d.dt * 1000);
      daily.push({
        date: date.toISOString(),
        high: Math.round(d.temp?.max ?? currentTemp + 2),
        low: Math.round(d.temp?.min ?? currentTemp - 4),
        condition: d.weather?.[0]?.main ?? condition,
        rainChance: Math.round((d.pop ?? 0.3) * 100),
      });
    }
  } else {
    // Fallback daily array if standard 5-day / 3-hour list was supplied
    for (let i = 0; i < 7; i++) {
      const d = new Date(now.getTime() + i * 86400000);
      daily.push({
        date: d.toISOString(),
        high: 31.0,
        low: 23.0,
        condition: i % 2 === 0 ? 'Scattered Clouds' : 'Moderate Rain',
        rainChance: i % 2 === 0 ? 30 : 65,
      });
    }
  }

  const expiresAt = new Date(now.getTime() + 60 * 60 * 1000); // 1 hour ahead

  return {
    currentTemperature: Math.round(currentTemp * 10) / 10,
    condition,
    humidity,
    rainChance,
    daily,
    fetchedAt: now.toISOString(),
    expiresAt: expiresAt.toISOString(),
    isCached: false,
  };
}

/**
 * HTTPS Callable Cloud Function: getWeatherForecast.
 *
 * Enforces signed-in authentication, validates coordinates, utilizes a 1-hour
 * Firestore weatherCache, and queries OpenWeatherMap server-side.
 */
export const getWeatherForecast = onCall(
  { maxInstances: 10, timeoutSeconds: 30 },
  async (request) => {
    // 1. Authentication Check
    if (!request.auth) {
      throw new HttpsError(
        'unauthenticated',
        'Authentication required to access weather forecasting services.'
      );
    }

    const { latitude, longitude } = request.data || {};
    if (
      typeof latitude !== 'number' ||
      latitude < -90 ||
      latitude > 90 ||
      typeof longitude !== 'number' ||
      longitude < -180 ||
      longitude > 180
    ) {
      throw new HttpsError(
        'invalid-argument',
        'Valid numeric latitude (-90 to 90) and longitude (-180 to 180) must be provided.'
      );
    }

    const regionKey = buildRegionKey(latitude, longitude);
    const db = admin.firestore();
    const cacheRef = db.collection('weatherCache').doc(regionKey);
    const cacheSnap = await cacheRef.get();
    const now = new Date();

    // 2. Cache Hit Verification
    if (cacheSnap.exists) {
      const cacheData = cacheSnap.data();
      const expiresAtDate = cacheData?.expiresAt?.toDate
        ? cacheData.expiresAt.toDate()
        : new Date(cacheData?.expiresAt || 0);

      if (now < expiresAtDate && cacheData?.forecastJson) {
        // Record usage for cache refresh policy
        await cacheRef.update({
          lastRequestedAt: admin.firestore.Timestamp.fromDate(now),
        });

        const cachedForecast: WeatherForecastData = {
          ...cacheData.forecastJson,
          isCached: true,
        };
        return cachedForecast;
      }
    }

    // 3. Query OpenWeatherMap Server-Side
    const apiKey = process.env.OPENWEATHER_API_KEY;
    if (apiKey && apiKey !== 'your_openweather_api_key_here') {
      try {
        const url = `https://api.openweathermap.org/data/2.5/onecall?lat=${latitude}&lon=${longitude}&units=metric&exclude=minutely,hourly,alerts&appid=${apiKey}`;
        const response = await fetch(url);

        if (!response.ok) {
          throw new Error(`OpenWeatherMap HTTP error ${response.status}: ${response.statusText}`);
        }

        const rawData = await response.json();
        const normalized = normalizeWeatherResponse(rawData, now);

        // Store into weatherCache
        await cacheRef.set({
          cacheId: regionKey,
          regionKey,
          forecastJson: normalized,
          fetchedAt: admin.firestore.Timestamp.fromDate(now),
          expiresAt: admin.firestore.Timestamp.fromDate(new Date(normalized.expiresAt)),
          lastRequestedAt: admin.firestore.Timestamp.fromDate(now),
        });

        return normalized;
      } catch (err) {
        console.warn(`Weather API lookup failed for ${regionKey}, checking for stale cache:`, err);
      }
    }

    // 4. Stale Cache Fallback or Deterministic Sri Lanka Agricultural Baseline
    if (cacheSnap.exists && cacheSnap.data()?.forecastJson) {
      const stale = cacheSnap.data()!.forecastJson as WeatherForecastData;
      return {
        ...stale,
        isCached: true,
        isStale: true,
      };
    }

    // Baseline fallback representing the Sri Lankan Dry/Intermediate zone agricultural climate
    const fallbackBaseline = normalizeWeatherResponse(
      {
        current: { temp: 29.0, humidity: 85, weather: [{ main: 'Scattered Clouds' }] },
        daily: [
          { dt: Math.floor(now.getTime() / 1000), temp: { max: 31, min: 23 }, pop: 0.4 },
          { dt: Math.floor(now.getTime() / 1000) + 86400, temp: { max: 30, min: 24 }, pop: 0.65 },
          { dt: Math.floor(now.getTime() / 1000) + 172800, temp: { max: 28, min: 22 }, pop: 0.8 },
          { dt: Math.floor(now.getTime() / 1000) + 259200, temp: { max: 29, min: 23 }, pop: 0.7 },
          { dt: Math.floor(now.getTime() / 1000) + 345600, temp: { max: 31, min: 24 }, pop: 0.3 },
          { dt: Math.floor(now.getTime() / 1000) + 432000, temp: { max: 32, min: 24 }, pop: 0.2 },
          { dt: Math.floor(now.getTime() / 1000) + 518400, temp: { max: 31, min: 23 }, pop: 0.25 },
        ],
      },
      now
    );

    return {
      ...fallbackBaseline,
      isCached: false,
      isStale: true,
    };
  }
);
