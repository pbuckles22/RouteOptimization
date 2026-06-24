import type { Page } from '@playwright/test';
import { expect } from '@playwright/test';

const startPlaceId = 'e2e-place-start';
const secondPlaceId = 'e2e-place-second';

function isPlacesProxy(url: URL): boolean {
  return url.hostname === '127.0.0.1' && url.port === '8765';
}

export async function mockMapApis(page: Page): Promise<void> {
  await page.route(
    (url) => isPlacesProxy(url),
    async (route) => {
      const url = new URL(route.request().url());

      if (url.pathname === '/search') {
        const q = (url.searchParams.get('q') ?? '').toLowerCase();
        const predictions =
          q.includes('2314')
            ? [
                {
                  place_id: startPlaceId,
                  description: '2314 Joree Ln, San Ramon, CA 94582, USA',
                  structured_formatting: {
                    main_text: '2314 Joree Ln',
                    secondary_text: 'San Ramon, CA 94582, USA',
                  },
                  types: ['street_address'],
                },
              ]
            : q.includes('burger')
              ? [
                  {
                    place_id: secondPlaceId,
                    description: '5315 Hopyard Rd, Pleasanton, CA 94588, USA',
                    structured_formatting: {
                      main_text: 'Burger King',
                      secondary_text: '5315 Hopyard Rd, Pleasanton, CA',
                    },
                    types: ['establishment'],
                  },
                ]
              : [];

        await route.fulfill({
          contentType: 'application/json',
          body: JSON.stringify({ status: 'OK', predictions }),
        });
        return;
      }

      if (url.pathname === '/details') {
        const placeId = url.searchParams.get('place_id');
        const result =
          placeId === startPlaceId
            ? {
                place_id: startPlaceId,
                name: '2314 Joree Ln',
                formatted_address: '2314 Joree Ln, San Ramon, CA 94582, USA',
                geometry: { location: { lat: 37.7799, lng: -121.978 } },
              }
            : {
                place_id: secondPlaceId,
                name: 'Burger King',
                formatted_address: '5315 Hopyard Rd, Pleasanton, CA 94588, USA',
                geometry: { location: { lat: 37.6945, lng: -121.875 } },
              };

        await route.fulfill({
          contentType: 'application/json',
          body: JSON.stringify({ status: 'OK', result }),
        });
        return;
      }

      await route.continue();
    },
  );

  await page.route('**/api.mapbox.com/**', async (route) => {
    const url = route.request().url();
    if (url.includes('optimized-trips')) {
      await route.fulfill({
        contentType: 'application/json',
        body: JSON.stringify({
          code: 'Ok',
          trips: [{ distance: 12_000 }],
          waypoints: [{ waypoint_index: 0 }, { waypoint_index: 1 }],
        }),
      });
      return;
    }

    await route.continue();
  });
}

/** Type into Flutter semantics textbox; fill() alone does not fire onChanged. */
export async function searchAndSelect(
  page: Page,
  query: string,
  resultText: string,
): Promise<void> {
  const search = page.getByRole('textbox', { name: /search places/i });
  await search.click();
  await search.fill('');
  await search.pressSequentially(query, { delay: 80 });

  const result = page.getByText(resultText).first();
  await expect(result).toBeVisible({ timeout: 15_000 });
  await result.click();
}
