/**
 * Fetches Stitch screen HTML + screenshot URLs via @google/stitch-sdk, then downloads with curl -L.
 *
 * Auth (pick one):
 *   - OAuth: STITCH_ACCESS_TOKEN + GOOGLE_CLOUD_PROJECT
 *   - API key: STITCH_API_KEY (may be rejected by stitch.googleapis.com for some accounts)
 *
 * Usage:
 *   export STITCH_ACCESS_TOKEN=...
 *   export GOOGLE_CLOUD_PROJECT=...
 *   node fetch_screen.mjs
 */
import { execFileSync } from "node:child_process";
import { mkdirSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { Stitch, StitchToolClient } from "@google/stitch-sdk";

const __dirname = dirname(fileURLToPath(import.meta.url));

const PROJECT_ID = "17980223272648333277";
const SCREEN_ID = "ef8afe1b91ae49b1b27a1015a9b27a4c";

const REPO_ROOT = join(__dirname, "..", "..");
const OUT_DIR = join(
  REPO_ROOT,
  "assets",
  "stitch",
  PROJECT_ID,
  SCREEN_ID,
);

function makeClient() {
  const token = process.env.STITCH_ACCESS_TOKEN?.trim();
  const gcpProject =
    process.env.GOOGLE_CLOUD_PROJECT?.trim() ||
    process.env.STITCH_GOOGLE_CLOUD_PROJECT?.trim();
  const apiKey = process.env.STITCH_API_KEY?.trim();

  if (token && gcpProject) {
    return new StitchToolClient({
      accessToken: token,
      projectId: gcpProject,
    });
  }
  if (apiKey) {
    return new StitchToolClient({ apiKey });
  }
  console.error(`Missing credentials. Set one of:
  • STITCH_ACCESS_TOKEN + GOOGLE_CLOUD_PROJECT (OAuth)
  • STITCH_API_KEY

See: https://github.com/google-labs-code/stitch-sdk#configuration`);
  process.exit(1);
}

function curlDownload(url, dest) {
  mkdirSync(dirname(dest), { recursive: true });
  execFileSync("curl", ["-fL", "--retry", "3", "-o", dest, url], {
    stdio: "inherit",
  });
}

async function main() {
  mkdirSync(OUT_DIR, { recursive: true });

  const client = makeClient();
  try {
    const sdk = new Stitch(client);
    const project = sdk.project(PROJECT_ID);
    const screen = await project.getScreen(SCREEN_ID);
    const htmlUrl = await screen.getHtml();
    const imageUrl = await screen.getImage();

    const urlsPayload = {
      projectId: PROJECT_ID,
      screenId: SCREEN_ID,
      htmlUrl,
      imageUrl,
      fetchedAt: new Date().toISOString(),
    };
    writeFileSync(
      join(OUT_DIR, "download_urls.json"),
      `${JSON.stringify(urlsPayload, null, 2)}\n`,
      "utf8",
    );

    const htmlPath = join(OUT_DIR, "screen.html");
    const imagePath = join(OUT_DIR, "screen.png");

    console.error("Downloading HTML…");
    curlDownload(htmlUrl, htmlPath);
    console.error("Downloading screenshot…");
    curlDownload(imageUrl, imagePath);

    console.error(`Done. Files in:\n${OUT_DIR}`);
  } finally {
    await client.close();
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
