import { expect, test } from '@playwright/test';

import { mockMapApis, searchAndSelect } from './fixtures';

test.describe('RouteWise web harness', () => {
  test.beforeEach(async ({ page }) => {
    await mockMapApis(page);
    await page.goto('/');
    await expect(page.locator('flutter-view')).toBeVisible({
      timeout: 120_000,
    });

    await expect(
      page.getByRole('textbox', { name: /search places/i }),
    ).toBeVisible({ timeout: 60_000 });
  });

  test('search → add stops → optimize → launch enabled', async ({ page }) => {
    await searchAndSelect(page, '2314', '2314 Joree Ln');
    await expect(page.getByRole('checkbox', { name: 'Start' })).toBeVisible();

    await searchAndSelect(page, 'burger', 'Burger King');

    await page.getByRole('button', { name: /optimize route/i }).click();
    await expect(page.getByText(/estimated distance/i)).toBeVisible({
      timeout: 15_000,
    });

    const launch = page.getByRole('button', { name: /launch in google maps/i });
    await expect(launch).toBeVisible();
    await expect(launch).toBeEnabled();
  });
});
