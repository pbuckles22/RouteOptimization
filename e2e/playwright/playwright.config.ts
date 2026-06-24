import { defineConfig, devices } from '@playwright/test';

const baseURL = process.env.E2E_BASE_URL ?? 'http://localhost:8080';
const channel = process.env.PW_CHANNEL; // e.g. 'chrome' | 'msedge'

export default defineConfig({
  testDir: './tests',
  fullyParallel: false,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 1 : 0,
  workers: 1,
  reporter: [['list']],
  timeout: 120_000,
  use: {
    baseURL,
    trace: 'on-first-retry',
    ...(channel ? { channel } : {}),
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
  ],
  webServer: {
    command: 'bash script/run_web_e2e.sh',
    url: baseURL,
    cwd: '../..',
    // Playwright starts/stops the app server for each test run. After Dart/UI
    // changes, set E2E_FRESH_SERVER=1 to rebuild. Do not rely on run_web.sh.
    reuseExistingServer: !process.env.CI && !process.env.E2E_FRESH_SERVER,
    timeout: 300_000,
  },
});
