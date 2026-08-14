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

// ============================================================
// CONFIGURATION
// ============================================================

const SERVICE_URL =
  process.env.X402_SERVICE_URL ||
  "http://localhost:4021";

const MNEMONIC =
  process.env.AGENT_MNEMONIC;

const PORT =
  Number(process.env.AGENT_PORT || 4020);

if (!MNEMONIC) {
  throw new Error(
    "Missing AGENT_MNEMONIC in .env"
  );
}

// ============================================================
// CONVERT ALGORAND MNEMONIC
// TO BASE64 PRIVATE KEY
// ============================================================

function mnemonicToPrivateKeyBase64(
  mnemonic: string
): string {
  const account =
    algosdk.mnemonicToSecretKey(
      mnemonic
    );

  const seed =
    account.sk.slice(0, 32);

  const publicKey =
    account.sk.slice(32, 64);

  const privateKey =
    Buffer.concat([
      Buffer.from(seed),
      Buffer.from(publicKey),
    ]);

  return privateKey.toString(
    "base64"
  );
}

// ============================================================
// CREATE ALGORAND x402 SIGNER
// ============================================================

const privateKeyBase64 =
  mnemonicToPrivateKeyBase64(
    MNEMONIC
  );

const avmSigner =
  toClientAvmSigner(
    privateKeyBase64
  );

// ============================================================
// STARTUP INFORMATION
// ============================================================

console.log(
  "================================="
);

console.log(
  "OneVest x402 Agent API"
);

console.log(
  "================================="
);

console.log(
  "Agent payer:",
  avmSigner.address
);

console.log(
  "x402 service:",
  SERVICE_URL
);

console.log(
  "Agent API port:",
  PORT
);

// ============================================================
// CREATE x402 CLIENT
// ============================================================

const client =
  new x402Client();

// ============================================================
// REGISTER ALGORAND TESTNET
// ============================================================

client.register(
  ALGORAND_TESTNET_CAIP2,
  new ExactAvmScheme(
    avmSigner
  )
);

// ============================================================
// WRAP FETCH WITH AUTOMATIC x402
// PAYMENT HANDLING
// ============================================================

const fetchWithPayment =
  wrapFetchWithPayment(
    fetch,
    client
  );

// ============================================================
// CREATE HONO HTTP API
// ============================================================

const app =
  new Hono();

// ============================================================
// HEALTH ENDPOINT
// ============================================================

app.get(
  "/health",
  (c) => {
    return c.json({
      status: "ok",

      service:
        "OneVest x402 Agent",

      network:
        "Algorand TestNet",

      x402Service:
        SERVICE_URL,

      payer:
        avmSigner.address,

      port:
        PORT,
    });
  }
);

// ============================================================
// MARKET INTELLIGENCE ENDPOINT
// ============================================================
//
// Flutter calls:
//
// GET /api/market-intelligence?symbol=AAPL
//
// The agent:
//
// 1. Requests the paid x402 endpoint
// 2. Receives HTTP 402
// 3. Reads payment requirements
// 4. Creates Algorand USDC payment
// 5. Signs transaction
// 6. Sends payment proof
// 7. Payment settles
// 8. Retries the request
// 9. Receives premium market data
// 10. Returns the result to Flutter
//
// ============================================================

app.get(
  "/api/market-intelligence",
  async (c) => {
    try {
      // --------------------------------------------------------
      // GET SYMBOL
      // --------------------------------------------------------

      const symbol =
        c.req
          .query("symbol")
          ?.trim()
          .toUpperCase();

      if (!symbol) {
        return c.json(
          {
            success: false,

            error:
              "Missing symbol",

            example:
              "/api/market-intelligence?symbol=AAPL",
          },

          400
        );
      }

      // --------------------------------------------------------
      // LOG REQUEST
      // --------------------------------------------------------

      console.log("");

      console.log(
        "================================="
      );

      console.log(
        "Market intelligence request"
      );

      console.log(
        "Symbol:",
        symbol
      );

      console.log(
        "================================="
      );

      // --------------------------------------------------------
      // PAID x402 SERVICE URL
      // --------------------------------------------------------

      const url =
        `${SERVICE_URL}/api/market-intelligence?symbol=${encodeURIComponent(symbol)}`;

      console.log(
        "Requesting paid service..."
      );

      // --------------------------------------------------------
      // REQUEST x402 SERVICE
      // --------------------------------------------------------

      const response =
        await fetchWithPayment(
          url,
          {
            method: "GET",
          }
        );

      console.log(
        "x402 service HTTP status:",
        response.status
      );

      // --------------------------------------------------------
      // HANDLE FAILED PAYMENT / REQUEST
      // --------------------------------------------------------

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

            error:
              "x402 payment/request failed",

            status:
              response.status,

            details:
              body,
          },

          502
        );
      }

      // --------------------------------------------------------
      // READ x402 SETTLEMENT RESPONSE
      // --------------------------------------------------------

      let payment:
        unknown = null;

      try {
        payment =
          new x402HTTPClient(
            client
          ).getPaymentSettleResponse(
            (name) =>
              response.headers.get(
                name
              )
          );
      } catch {
        console.log(
          "Payment settlement header was not returned."
        );
      }

      // --------------------------------------------------------
      // READ PREMIUM MARKET DATA
      // --------------------------------------------------------

      const data =
        await response.json();

      console.log("");

      console.log(
        "Payment settled successfully."
      );

      console.log(
        "Market intelligence:",
        JSON.stringify(
          data,
          null,
          2
        )
      );

      // --------------------------------------------------------
      // RETURN RESULT TO FLUTTER
      // --------------------------------------------------------

      return c.json({
        success: true,

        payment,

        data,
      });

    } catch (error) {
      // --------------------------------------------------------
      // HANDLE AGENT ERROR
      // --------------------------------------------------------

      console.error(
        "Agent error:",
        error
      );

      return c.json(
        {
          success: false,

          error:
            "Agent request failed",

          details:
            error instanceof Error
              ? error.message
              : String(error),
        },

        500
      );
    }
  }
);

// ============================================================
// START HTTP SERVER
// ============================================================
//
// IMPORTANT:
//
// hostname: "0.0.0.0"
//
// allows the Android emulator to reach:
//
// http://10.0.2.2:4020
//
// instead of only allowing:
//
// http://localhost:4020
//
// ============================================================

serve(
  {
    fetch:
      app.fetch,

    port:
      PORT,

    hostname:
      "0.0.0.0",
  },

  (info) => {
    console.log("");

    console.log(
      "================================="
    );

    console.log(
      `OneVest Agent API running on http://localhost:${info.port}`
    );

    console.log(
      `Android emulator endpoint: http://10.0.2.2:${info.port}`
    );

    console.log(
      "================================="
    );
  }
);