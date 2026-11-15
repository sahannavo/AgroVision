export interface DailyForecastData {
  date: string;
  high: number;
  low: number;
  condition: string;
  rainChance: number;
}

export interface WeatherForecastData {
  currentTemperature: number;
  condition: string;
  humidity: number;
  rainChance: number;
  daily: DailyForecastData[];
  fetchedAt: string;
  expiresAt: string;
  isCached: boolean;
  isStale?: boolean;
}

export interface WeatherCacheDoc {
  cacheId: string;
  regionKey: string;
  forecastJson: WeatherForecastData;
  fetchedAt: FirebaseFirestore.Timestamp;
  expiresAt: FirebaseFirestore.Timestamp;
  lastRequestedAt: FirebaseFirestore.Timestamp;
}
