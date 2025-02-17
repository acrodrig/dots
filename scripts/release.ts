#!/usr/bin/env -S deno run -A

import $ from "jsr:@david/dax";

// Test formatting
let version = Deno.args[0];
if (version && !version?.match(/^[0-9]+\.[0-9]+\.[0-9]+$/)) console.error("❌ Version '" + version + "' is not semantic tag"), Deno.exit(1);

// Make sure there are no changes
const diff = await $`git diff --quiet`.noThrow(1);
if (diff.code !== 0) console.error("❌ Git local different than remote, need to commit?"), Deno.exit(1);

// Get the previous version
const previous = await $`git describe --tags --abbrev=0`.text();
const [ major, minor, patch ] = previous.split(".").map((n) => parseInt(n));

// Collecting log
console.info("🗒️  Collecting Notes");
const log = (await $`git log ${previous}..HEAD --oneline --no-decorate`.lines()).filter((l: string) => l.trim().length > 0);
if (log.length === 0) console.error("❌ There is nothing new to release"), Deno.exit(1);

// Test formatting
console.info("🎨 Checking formatting");
const fmt = await $`deno fmt --check --quiet`.noThrow(1);
if (fmt.code !== 0) console.error("❌ Code is not formatted"), Deno.exit(1);

// Running Tests
console.info("🧪 Running Tests");
const test = await $`deno task test`.noThrow(1);
if (test.code !== 0) console.error("❌ Not all tests passed"), Deno.exit(1);

// If no argument was passed, we will patch the version
version = version ?? `${major}.${minor}.${patch + 1}`;
console.info("🆚 version '" + previous + "' -> '" + version + "'");

// Fetch all remote branches to make sure comparison is correct
console.info("🔽 Fetching from remote");
await $`git fetch`;

// Releasing
console.info("🚀 Releasing version '" + version + "' ...");
const date = new Date().toISOString().substring(0,10)
const notes = `### ${version} / ` + date + "\n" + log.map((l) => "- " + l).join("\n");
await $`gh release create ${version} --title ${version} --notes ${notes}`;

// Pull rebase locally
console.info("🔽 Pulling from remote");
await $`git pull --rebase`;
