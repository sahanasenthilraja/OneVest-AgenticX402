import { config } from "dotenv";
import algosdk from "algosdk";

import {
  x402Client,
  x402HTTPClient,
} from "@x402-avm/core/client";

import {
  toClientAvmSigner,
  ExactAvmScheme,
  ALGORAND_TESTNET_CAIP2,
} from "@x402-avm/avm";

import { wrapFetchWithPayment } from "@x402-avm/fetch";

import { Hono } from "hono";
import { serve } from "@hono/node-server";

config();

const SERVICE_URL =
  process.env.X402_SERVICE_URL ||
  "http://localhost:4021";

const MNEMONIC = process.env.AGENT_MNEMONIC;

if (!MNEMONIC) {
  throw new Error("Missing AGENT_MNEMONIC in .env");
}

const PORT = Number(process.env.AGENT_PORT || 4020);

/*
 * Convert Algorand mnemonic to Base64 private key.
 */
function mnemonicToPrivateKeyBase64(
  mnemonic: string
): string {
  const account = algosdk.mnemonicToSecretKey(mnemonic);

  const seed = account.sk.slice(0, 32);
  const publicKey = account.sk.slice(32, 64);

  const privateKey = Buffer.concat([
    Buffer.from(seed),
    Buffer.from(publicKey),
  ]);

  return privateKey.toString("base64");
}

/*
 * Create the Algorand x402 signer.
 */
const privateKeyBase64 =
  mnemonicToPrivateKeyBase64(MNEMONIC);

const avmSigner =
  toClientAvmSigner(privateKeyBase64);

console.log("=================================");
console.log("OneVest x402 Agent API");
console.log("=================================");
console.log("Agent payer:", avmSigner.address);
console.log("x402 service:", SERVICE_URL);
console.log("Agent API port:", PORT);

/*
 * Create x402 client.
 */
const client = new x402Client();

client.register(
  ALGORAND_TESTNET_CAIP2,
  new ExactAvmScheme(avmSigner)
);

/*
 * Wrap fetch with automatic x402 payment handling.
 */
const fetchWithPayment =
  wrapFetchWithPayment(
    fetch,
    client
  );

/*
 * Create HTTP API.
 */
const app = new Hono();

/*
 * Health endpoint.
 */
app.get("/health", (c) => {
  return c.json({
    status: "ok",
    service: "OneVest x402 Agent",
    network: "Algorand TestNet",
    x402Service: SERVICE_URL,
    payer: avmSigner.address,
  });
});

/*
 * Market intelligence endpoint.
 *
 * Flutter calls:
 *
 * GET /api/market-intelligence?symbol=AAPL
 *
 * The agent then:
 *
 * 1. Requests the paid x402 endpoint
 * 2. Receives HTTP 402
 * 3. Creates the Algorand USDC payment
 * 4. Signs the transaction
 * 5. Sends the payment proof
 * 6. Retries the request
 * 7. Returns the real market data
 */
app.get("/api/market-intelligence", async (c) => {
  try {
    const symbol =
      c.req.query("symbol")?.trim().toUpperCase();

    if (!symbol) {
      return c.json(
        {
          success: false,
          error: "Missing symbol",
          example:
            "/api/market-intelligence?symbol=AAPL",
        },
        400
      );
    }

    console.log("");
    console.log("=================================");
    console.log("Market intelligence request");
    console.log("Symbol:", symbol);
    console.log("=================================");

    const url =
      `${SERVICE_URL}/api/market-intelligence?symbol=${encodeURIComponent(symbol)}`;

    console.log("Requesting paid service...");

    const response =
      await fetchWithPayment(
        url,
        {
          method: "GET",
        }
      );

    console.log("x402 service HTTP status:", response.status);

    if (!response.ok) {
      const body =
        await response.text();

      console.error(
        "x402 request failed:",
        body
      );

      return c.json(
        {
          success: false,
          error: "x402 payment/request failed",
          status: response.status,
          details: body,
        },
        502
      );
    }

    /*
     * Read x402 settlement information.
     */
    let payment: unknown = null;

    try {
      payment =
        new x402HTTPClient(client)
          .getPaymentSettleResponse(
            (name) =>
              response.headers.get(name)
          );
    } catch {
      console.log(
        "Payment settlement header was not returned."
      );
    }

    /*
     * Read actual market intelligence.
     */
    const data =
      await response.json();

    console.log("");
    console.log("Payment settled successfully.");

    console.log(
      "Market intelligence:",
      JSON.stringify(data, null, 2)
    );

    return c.json({
      success: true,
      payment,
      data,
    });

  } catch (error) {
    console.error(
      "Agent error:",
      error
    );

    return c.json(
      {
        success: false,
        error: "Agent request failed",
        details:
          error instanceof Error
            ? error.message
            : String(error),
      },
      500
    );
  }
});

/*
 * Start HTTP server.
 */
serve(
  {
    fetch: app.fetch,
    port: PORT,
  },
  (info) => {
    console.log("");
    console.log("=================================");
    console.log(
      `OneVest Agent API running on http://localhost:${info.port}`
    );
    console.log("=================================");
  }
);