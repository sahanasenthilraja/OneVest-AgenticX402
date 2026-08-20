import { askOneVestAI } from "./onevest-ai.js";

async function main() {
  const answer = await askOneVestAI(
    "Give me the latest market intelligence for AAPL.",
  );

  console.log("\n========== ONEVEST AI ==========\n");
  console.log(answer);
  console.log("\n================================\n");
}

main().catch((error) => {
  console.error("AI test failed:", error);
  process.exit(1);
});