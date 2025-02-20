#!/usr/bin/env -S deno run -A

import { parseArgs } from "jsr:@std/cli/parse-args";
import $ from "jsr:@david/dax";


// Define usage message and style
const USAGE = "Usage: release [-h|--help] [-e|--execute] [version]";

// Parse command-line arguments
const args = parseArgs(Deno.args, { boolean: ["h", "help", "e", "execute"], alias: { h: "help", e: "execute" }, unknown: (arg) => arg });
if (args.help) console.log(USAGE), Deno.exit(0);

// Test formatting
let version = args._.pop()?.toString();
console.log("Version: " + version + ", " + typeof version);
if (version && !version?.match(/^[0-9]+\.[0-9]+\.[0-9]+$/)) console.error("❌ Version '" + version + "' is not a semantic full tag (i.e. X.X.X)"), Deno.exit(1);

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
console.info("%c\nSTART TESTS\n"+("-".repeat(80)), "color: white");
const test = await $`deno task test`.noThrow(1);
console.info("%c"+("=".repeat(80)+"\nEND TESTS\n"), "color: white");
if (test.code !== 0) console.error("❌ Not all tests passed"), Deno.exit(1);

// If no argument was passed, we will patch the version
version = version ?? `${major}.${minor}.${patch + 1}`;
console.info("🆚 version '" + previous + "' -> '" + version + "'");

// Create notes
const date = new Date().toISOString().substring(0,10)
const notes = `### ${version} / ` + date + "\n" + log.map((l) => "- " + l).join("\n");

// Releasing
if (args.execute) {
  console.info("🚀 Releasing version '" + version + "' (fetch before, rebase after)...");
  await $`git fetch`;
  await $`gh release create ${version} --title ${version} --notes ${notes}`;
  await $`git pull --rebase`;
} else {
  console.info("\n");
  console.info("%c"+notes, "color: white");
  console.info("\n" + USAGE);
}
