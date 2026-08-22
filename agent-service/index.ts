import { config } from "dotenv";
import algosdk from "algosdk";

import { askOneVestAI } from "./onevest-ai.js";

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
import { cors } from "hono/cors";

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
    "Missing AGENT_MNEMONIC in .env",
  );
}

// ============================================================
// ALGORAND MNEMONIC -> BASE64 PRIVATE KEY
// ============================================================

function mnemonicToPrivateKeyBase64(
  mnemonic: string,
): string {
  const account =
    algosdk.mnemonicToSecretKey(
      mnemonic,
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
    "base64",
  );
}

// ============================================================
// CREATE x402 SIGNER
// ============================================================

const privateKeyBase64 =
  mnemonicToPrivateKeyBase64(
    MNEMONIC,
  );

const avmSigner =
  toClientAvmSigner(
    privateKeyBase64,
  );

// ============================================================
// STARTUP
// ============================================================

console.log(
  "=================================",
);

console.log(
  "OneVest x402 + AI Agent API",
);

console.log(
  "=================================",
);

console.log(
  "Agent payer:",
  avmSigner.address,
);

console.log(
  "x402 service:",
  SERVICE_URL,
);

console.log(
  "Agent API port:",
  PORT,
);

console.log(
  "Groq AI:",
  "Enabled",
);

// ============================================================
// x402 CLIENT
// ============================================================

const client =
  new x402Client();

client.register(
  ALGORAND_TESTNET_CAIP2,
  new ExactAvmScheme(
    avmSigner,
  ),
);

const fetchWithPayment =
  wrapFetchWithPayment(
    fetch,
    client,
  );

// ============================================================
// HONO APP
// ============================================================

const app =
  new Hono();

app.use(
  "*",
  cors({
    origin: "*",
    allowMethods: [
      "GET",
      "POST",
      "OPTIONS",
    ],
    allowHeaders: [
      "Content-Type",
    ],
  }),
);

// ============================================================
// HEALTH ENDPOINT
// ============================================================

app.get(
  "/health",
  (c) => {
    return c.json({
      status: "ok",

      service:
        "OneVest x402 + AI Agent",

      network:
        "Algorand TestNet",

      x402Service:
        SERVICE_URL,

      payer:
        avmSigner.address,

      port:
        PORT,

      groq:
        "enabled",

      premiumIntelligence:
        "enabled",
    });
  },
);

// ============================================================
// BASIC AI CHAT
// ============================================================

app.post(
  "/api/ai/chat",
  async (c) => {
    try {
      const body =
        await c.req.json();

      const message =
        typeof body?.message === "string"
          ? body.message.trim()
          : "";

      if (!message) {
        return c.json(
          {
            success: false,
            error: "Missing message",
          },
          400,
        );
      }

      console.log("");
      console.log(
        "=================================",
      );
      console.log(
        "OneVest AI request",
      );
      console.log(
        "Message:",
        message,
      );
      console.log(
        "=================================",
      );

      const answer =
        await askOneVestAI(
          message,
        );

      console.log(
        "Groq response received.",
      );

      return c.json({
        success: true,

        model:
  "openai/gpt-oss-20b",

        answer,
      });
    } catch (error) {
      console.error(
        "OneVest AI error:",
        error,
      );

      return c.json(
        {
          success: false,

          error:
            "AI request failed",

          details:
            error instanceof Error
              ? error.message
              : String(error),
        },
        500,
      );
    }
  },
);

// ============================================================
// PREMIUM MARKET INTELLIGENCE
// ============================================================
//
// GET /api/market-intelligence?symbol=TCS.NS
//
// Flow:
//
// Flutter
//    ↓
// Agent :4020
//    ↓
// x402 payment
//    ↓
// x402 service :4021
//    ↓
// Real market data
//    ↓
// Premium intelligence
//    ↓
// Flutter
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
              "/api/market-intelligence?symbol=TCS.NS",
          },
          400,
        );
      }

      console.log("");
      console.log(
        "=================================",
      );
      console.log(
        "ONEVEST PREMIUM INTELLIGENCE",
      );
      console.log(
        "Symbol:",
        symbol,
      );
      console.log(
        "=================================",
      );

      // --------------------------------------------------------
      // PAID x402 URL
      // --------------------------------------------------------

      const url =
        `${SERVICE_URL}/api/market-intelligence?symbol=${encodeURIComponent(symbol)}`;

      console.log(
        "Requesting premium x402 service...",
      );

      // --------------------------------------------------------
      // AUTOMATIC x402 PAYMENT
      // --------------------------------------------------------

      let response: Response;

      try {
        response =
          await fetchWithPayment(
            url,
            {
              method: "GET",
            },
          );
      } catch (error) {
        console.error("");
        console.error(
          "=================================",
        );
        console.error(
          "x402 PAYMENT ERROR",
        );
        console.error(
          "=================================",
        );
        console.error(error);

        return c.json(
          {
            success: false,

            error:
              "Premium payment failed",

            details:
              error instanceof Error
                ? error.message
                : String(error),
          },
          502,
        );
      }

      console.log(
        "x402 service HTTP status:",
        response.status,
      );

      // --------------------------------------------------------
      // HANDLE FAILED REQUEST
      // --------------------------------------------------------

      if (!response.ok) {
        const body =
          await response.text();

        console.error(
          "x402 request failed:",
          body,
        );

        return c.json(
          {
            success: false,

            error:
              "x402 premium request failed",

            status:
              response.status,

            details:
              body,
          },
          502,
        );
      }

      // --------------------------------------------------------
      // PAYMENT SETTLEMENT
      // --------------------------------------------------------

      let payment:
        unknown = null;

      try {
        payment =
          new x402HTTPClient(
            client,
          ).getPaymentSettleResponse(
            (name) =>
              response.headers.get(
                name,
              ),
          );
      } catch {
        console.log(
          "Payment settlement header unavailable.",
        );
      }

      // --------------------------------------------------------
      // READ PREMIUM RESPONSE
      // --------------------------------------------------------

      const raw =
        await response.json();

      console.log("");
      console.log(
        "Premium response received.",
      );

      console.log(
        JSON.stringify(
          raw,
          null,
          2,
        ),
      );

      // --------------------------------------------------------
      // NORMALIZE MARKET OBJECT
      // --------------------------------------------------------

      const market =
        raw?.market ??
        raw?.data?.market ??
        raw?.data?.data?.market ??
        null;

      if (!market) {
        console.error(
          "No market object found.",
        );

        return c.json(
          {
            success: false,

            error:
              "Premium market data missing",

            payment,

            raw,
          },
          502,
        );
      }

      // --------------------------------------------------------
      // NORMALIZE INTELLIGENCE
      // --------------------------------------------------------

      const rawIntelligence =
        raw?.intelligence ??
        raw?.data?.intelligence ??
        raw?.data?.data?.intelligence ??
        null;

      // --------------------------------------------------------
      // PREMIUM INTELLIGENCE
      // --------------------------------------------------------

      const intelligence =
        rawIntelligence
          ? {
              verdict:
                rawIntelligence.verdict ??
                "Neutral",

              confidence:
                Number(
                  rawIntelligence.confidence ??
                    50,
                ),

              momentum:
                Number(
                  rawIntelligence.momentum ??
                    50,
                ),

              volatility:
                Number(
                  rawIntelligence.volatility ??
                    50,
                ),

              risk:
                rawIntelligence.risk ??
                "Moderate",

              marketSummary:
                rawIntelligence.marketSummary ??
                "Market conditions are being monitored.",

              whyItMatters:
                Array.isArray(
                  rawIntelligence.whyItMatters,
                )
                  ? rawIntelligence.whyItMatters
                  : [],

              riskRadar:
                Array.isArray(
                  rawIntelligence.riskRadar,
                )
                  ? rawIntelligence.riskRadar
                  : [],

              scenarios:
                Array.isArray(
                  rawIntelligence.scenarios,
                )
                  ? rawIntelligence.scenarios
                  : [],

              watchItems:
                Array.isArray(
                  rawIntelligence.watchItems,
                )
                  ? rawIntelligence.watchItems
                  : [],

              nextBestAction:
                rawIntelligence.nextBestAction ??
                {
                  title:
                    "Monitor",

                  reason:
                    "Continue monitoring market conditions.",
                },

              thesisTriggers:
                Array.isArray(
                  rawIntelligence.thesisTriggers,
                )
                  ? rawIntelligence.thesisTriggers
                  : [],
            }
          : {
              verdict:
                "Neutral",

              confidence: 50,

              momentum: 50,

              volatility: 50,

              risk:
                "Moderate",

              marketSummary:
                "Market conditions are being monitored.",

              whyItMatters: [],

              riskRadar: [],

              scenarios: [],

              watchItems: [],

              nextBestAction: {
                title:
                  "Monitor",

                reason:
                  "Continue monitoring market conditions.",
              },

              thesisTriggers: [],
            };

      // --------------------------------------------------------
      // ONEVEST SIGNAL CALCULATION
      // --------------------------------------------------------

      const confidence =
        _clamp(
          intelligence.confidence,
        );

      const momentum =
        _clamp(
          intelligence.momentum,
        );

      const volatility =
        _clamp(
          intelligence.volatility,
        );

      const stability =
        _clamp(
          100 - volatility,
        );

      const signalScore =
        _clamp(
          (confidence * 0.35) +
          (momentum * 0.40) +
          (stability * 0.25),
        );

      // --------------------------------------------------------
      // PREMIUM METADATA
      // --------------------------------------------------------

      const premium = {
        tier:
          "ONEVEST_PREMIUM",

        paymentProtected:
          true,

        x402Network:
          "Algorand TestNet",

        signalScore:
          Math.round(
            signalScore,
          ),

        confidence:
          Math.round(
            confidence,
          ),

        momentum:
          Math.round(
            momentum,
          ),

        stability:
          Math.round(
            stability,
          ),

        volatility:
          Math.round(
            volatility,
          ),

        engine:
          "OneVest AI Intelligence",

        dataSource:
          "Premium Market Data",

        generatedAt:
          new Date().toISOString(),
      };

      // --------------------------------------------------------
      // FINAL PREMIUM RESPONSE
      // --------------------------------------------------------

      return c.json({
        success:
          true,

        premium:
          true,

        service:
          "OneVest Premium Intelligence",

        symbol:
          symbol,

        payment:
          payment,

        market:
          market,

        intelligence:
          intelligence,

        premiumMetrics:
          premium,

        source:
          "OneVest x402 + AI",

        message:
          "Premium OneVest intelligence unlocked after x402 payment.",
      });
    } catch (error) {
      console.error("");
      console.error(
        "=================================",
      );
      console.error(
        "PREMIUM AGENT ERROR",
      );
      console.error(
        "=================================",
      );
      console.error(error);

      return c.json(
        {
          success: false,

          error:
            "Premium intelligence request failed",

          details:
            error instanceof Error
              ? error.message
              : String(error),
        },
        500,
      );
    }
  },
);

// ============================================================
// UTILITY
// ============================================================

function _clamp(
  value: number,
): number {
  if (!Number.isFinite(value)) {
    return 50;
  }

  return Math.max(
    0,
    Math.min(
      100,
      value,
    ),
  );
}

// ============================================================
// START SERVER
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
      "=================================",
    );

    console.log(
      `OneVest Agent API running on http://localhost:${info.port}`,
    );

    console.log(
      `Android emulator endpoint: http://10.0.2.2:${info.port}`,
    );

    console.log(
      "Premium Intelligence: ENABLED",
    );

    console.log(
      "=================================",
    );
  },
);