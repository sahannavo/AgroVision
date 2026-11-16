import * as admin from 'firebase-admin';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import { normalizeWeatherResponse } from './getWeatherForecast';

/**
 * Scheduled Cloud Function: refreshWeatherCache.
 *
 * Runs once every hour. Identifies active agricultural regions requested
 * by farmers within the past 24 hours, and refreshes up to 20 caches per run
 * to conserve the free API quota.
 */
export const refreshWeatherCache = onSchedule(
  {
    schedule: 'every 1 hours',
    timeZone: 'Asia/Colombo',
    maxInstances: 1,
  },
  async () => {
    const db = admin.firestore();
    const now = new Date();
    const twentyFourHoursAgo = new Date(now.getTime() - 24 * 60 * 60 * 1000);

    const apiKey = process.env.OPENWEATHER_API_KEY;
    if (!apiKey || apiKey === 'your_openweather_api_key_here') {
      console.log('Skipping weather cache refresh: OPENWEATHER_API_KEY is not configured.');
      return;
    }

    try {
      const activeRegionsSnap = await db
        .collection('weatherCache')
        .where('lastRequestedAt', '>=', admin.firestore.Timestamp.fromDate(twentyFourHoursAgo))
        .limit(20)
        .get();

      if (activeRegionsSnap.empty) {
        console.log('No active regions requested in the last 24 hours. Refresh cycle complete.');
        return;
      }

      console.log(`Refreshing weather cache for ${activeRegionsSnap.size} active agricultural regions...`);

      for (const doc of activeRegionsSnap.docs) {
        const regionKey = doc.id;
        const [latStr, lonStr] = regionKey.split('_');
        const lat = parseFloat(latStr);
        const lon = parseFloat(lonStr);

        if (isNaN(lat) || isNaN(lon)) continue;

        try {
          const url = `https://api.openweathermap.org/data/2.5/onecall?lat=${lat}&lon=${lon}&units=metric&exclude=minutely,hourly,alerts&appid=${apiKey}`;
          const response = await fetch(url);

          if (response.ok) {
            const rawData = await response.json();
            const normalized = normalizeWeatherResponse(rawData, now);

            await doc.ref.update({
              forecastJson: normalized,
              fetchedAt: admin.firestore.Timestamp.fromDate(now),
              expiresAt: admin.firestore.Timestamp.fromDate(new Date(normalized.expiresAt)),
            });
            console.log(`Successfully refreshed weather cache for region ${regionKey}`);
          }
        } catch (regionErr) {
          console.warn(`Failed to refresh region ${regionKey}:`, regionErr);
        }
      }
    } catch (err) {
      console.error('Error during scheduled weather cache refresh:', err);
    }
  }
);
