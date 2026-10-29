import * as admin from 'firebase-admin';

// Initialize the Firebase Admin SDK once at the root module level
if (admin.apps.length === 0) {
  admin.initializeApp();
}

export { getWeatherForecast, buildRegionKey, normalizeWeatherResponse } from './getWeatherForecast';
export { refreshWeatherCache } from './refreshWeatherCache';
export { onDiagnosisCreated, PREVENTIVE_STEPS_TABLE } from './onDiagnosisCreated';
