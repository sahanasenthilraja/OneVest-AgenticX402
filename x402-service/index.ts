import { config } from "dotenv";
import { Hono } from "hono";
import { serve } from "@hono/node-server";

import {
  paymentMiddleware,
  x402ResourceServer,
} from "@x402-avm/hono";

import { HTTPFacilitatorClient } from "@x402-avm/core/server";

import { ExactAvmScheme } from "@x402-avm/avm/exact/server";

import {
  declareDiscoveryExtension,
} from "@x402-avm/extensions";

config();

const app = new Hono();

/*
 * ============================================================
 * Environment variables
 * ============================================================
 */

const avmAddress = process.env.AVM_ADDRESS;
const marketApiKey = process.env.MARKET_API_KEY;
const geminiApiKey = process.env.GEMINI_API_KEY;

const facilitatorUrl =
  process.env.FACILITATOR_URL ||
  "https://facilitator.goplausible.xyz";


if (!avmAddress) {
  console.error("Missing AVM_ADDRESS in .env");
  process.exit(1);
}

if (!marketApiKey) {
  console.error("Missing MARKET_API_KEY in .env");
  process.exit(1);
}

if (!geminiApiKey) {
  console.error("Missing GEMINI_API_KEY in .env");
  process.exit(1);
}

/*
 * ============================================================
 * Algorand TestNet x402 network
 * ============================================================
 */

const ALGORAND_TESTNET =
  "algorand:SGO1GKSzyE7IEPItTxCByw9x8FmnrCDexi9/cOUJOiI=";

/*
 * ============================================================
 * TestNet USDC ASA
 * ============================================================
 */

const USDC_TESTNET_ASA_ID = "10458941";

/*
 * ============================================================
 * Hosted GoPlausible facilitator
 * ============================================================
 */

const facilitatorClient =
  new HTTPFacilitatorClient({
    url: facilitatorUrl,
  });

/*
 * ============================================================
 * x402 Resource Server
 * ============================================================
 */

const resourceServer =
  new x402ResourceServer(
    facilitatorClient
  ).register(
    ALGORAND_TESTNET,
    new ExactAvmScheme()
  );

/*
 * ============================================================
 * Bazaar discovery metadata
 * ============================================================
 */

const marketDiscovery =
  declareDiscoveryExtension({
    input: {
      symbol: "AAPL",
    },

    output: {
      example: {
        service:
          "OneVest Market Intelligence",

        market: {
          symbol: "AAPL",
          price: 215.3,
          currency: "USD",
          changePercent: 1.42,
        },
      },
    },
  });

/*
 * ============================================================
 * x402 protected route
 *
 * Client requests:
 *
 * GET /api/market-intelligence
 *
 * Server responds:
 *
 * 402 Payment Required
 *
 * Agent then automatically creates and
 * signs the Algorand USDC payment.
 * ============================================================
 */

app.use(
  paymentMiddleware(
    {
      "GET /api/market-intelligence": {
        accepts: {
          scheme: "exact",

          price: "$0.005",

          network:
            ALGORAND_TESTNET,

          payTo:
            avmAddress,

          extra: {
            asset:
              USDC_TESTNET_ASA_ID,
          },
        },

        description:
          "OneVest Market Intelligence service",

        mimeType:
          "application/json",

        extensions:
          marketDiscovery,
      },
    },

    resourceServer
  )
);

/*
 * ============================================================
 * Real Market Intelligence API
 *
 * Data provider:
 * Yahoo Finance
 *
 * This route remains protected by the x402 paymentMiddleware
 * configured above.
 * ============================================================
 */

app.get(
  "/api/market-intelligence",
  async (c) => {
    try {
      const symbol =
        c.req
          .query("symbol")
          ?.trim()
          .toUpperCase();

      if (!symbol) {
        return c.json(
          {
            success: false,
            error: "Missing symbol",
          },
          400
        );
      }

      console.log("");
      console.log("=================================");
      console.log("Paid Market Intelligence Request");
      console.log(`Symbol: ${symbol}`);
      console.log("=================================");

      const url =
        `https://query1.finance.yahoo.com/v8/finance/chart/${encodeURIComponent(symbol)}` +
        "?interval=1m&range=1d";

      console.log(
        `Fetching real Yahoo market data for ${symbol}...`
      );

      const response =
        await fetch(url);

      console.log(
        `Yahoo Finance HTTP status: ${response.status}`
      );

      if (!response.ok) {
        console.error(
          `Yahoo Finance returned HTTP ${response.status}`
        );

        return c.json(
          {
            success: false,
            error:
              `Market provider returned HTTP ${response.status}`,
            symbol,
          },
          502
        );
      }

      const data =
        await response.json();

      const result =
        data.chart?.result?.[0];

      if (!result) {
        console.error(
          `No Yahoo market data found for ${symbol}`
        );

        return c.json(
          {
            success: false,
            error:
              `No market data found for ${symbol}`,
            symbol,
          },
          404
        );
      }

      const meta =
        result.meta;

      const price =
        Number(
          meta.regularMarketPrice
        );

      const previousClose =
        Number(
          meta.previousClose
        );

      if (!Number.isFinite(price)) {
        return c.json(
          {
            success: false,
            error:
              `Invalid market price for ${symbol}`,
            symbol,
          },
          502
        );
      }

      const validPreviousClose =
        Number.isFinite(previousClose)
          ? previousClose
          : null;

      const change =
        validPreviousClose !== null
          ? price - validPreviousClose
          : 0;

      const changePercent =
        validPreviousClose !== null &&
          validPreviousClose !== 0
          ? (change / validPreviousClose) * 100
          : 0;

      const market = {
        symbol,
        price,
        previousClose:
          validPreviousClose,
        change,
        changePercent,
        currency:
          meta.currency ?? "USD",
        exchange:
          meta.exchangeName ??
          meta.fullExchangeName ??
          null,
        instrumentType:
          meta.instrumentType ??
          null,
        marketTime:
          meta.regularMarketTime
            ? new Date(
              meta.regularMarketTime * 1000
            ).toISOString()
            : null,
        updatedAt:
          new Date().toISOString(),
      };

      console.log(
        "Real market data retrieved:"
      );

      console.log(
        JSON.stringify(
          market,
          null,
          2
        )
      );

      return c.json({
        success: true,
        service:
          "OneVest Market Intelligence",
        market,
        source:
          "Yahoo Finance market data",
        message:
          "Real market intelligence successfully accessed after x402 payment.",
      });

    } catch (error) {
      console.error("AI endpoint error:", error);

      return c.json(
        {
          success: false,
          message: "AI endpoint error.",
          error: error instanceof Error
              ? error.message
              : String(error),
        },
        500,
      );
    }
  }
);

/*
 * ============================================================
 * Helper:
 *
 * Convert Yahoo Finance Gold futures price
 *
 * GC=F is:
 * USD per troy ounce
 *
 * We convert it to:
 * INR per 10 grams
 *
 * 1 troy ounce = 31.1034768 grams
 * ============================================================
 */

async function getGoldPriceInrPer10g() {
  const goldUrl =
    `https://query1.finance.yahoo.com/v8/finance/chart/${encodeURIComponent("GC=F")}` +
    "?interval=1m&range=1d";

  const usdInrUrl =
    `https://query1.finance.yahoo.com/v8/finance/chart/${encodeURIComponent("USDINR=X")}` +
    "?interval=1m&range=1d";

  const [
    goldResponse,
    usdInrResponse,
  ] = await Promise.all([
    fetch(goldUrl),
    fetch(usdInrUrl),
  ]);

  if (!goldResponse.ok) {
    throw new Error(
      `Gold market provider returned HTTP ${goldResponse.status}`
    );
  }

  if (!usdInrResponse.ok) {
    throw new Error(
      `USD/INR provider returned HTTP ${usdInrResponse.status}`
    );
  }

  const goldData =
    await goldResponse.json();

  const usdInrData =
    await usdInrResponse.json();

  const goldResult =
    goldData.chart?.result?.[0];

  const usdInrResult =
    usdInrData.chart?.result?.[0];

  if (!goldResult) {
    throw new Error(
      "No gold market data found"
    );
  }

  if (!usdInrResult) {
    throw new Error(
      "No USD/INR exchange rate found"
    );
  }

  const goldMeta =
    goldResult.meta;

  const usdInrMeta =
    usdInrResult.meta;

  const goldPriceUsd =
    Number(
      goldMeta.regularMarketPrice
    );

  const goldPreviousUsd =
    Number(
      goldMeta.previousClose
    );

  const usdInr =
    Number(
      usdInrMeta.regularMarketPrice
    );

  if (
    !Number.isFinite(goldPriceUsd) ||
    !Number.isFinite(goldPreviousUsd) ||
    !Number.isFinite(usdInr) ||
    usdInr <= 0
  ) {
    throw new Error(
      "Invalid gold or USD/INR market data"
    );
  }

  /*
   * 1 troy ounce = 31.1034768 grams
   */

  const gramsPerTroyOunce =
    31.1034768;

  /*
   * USD/troy oz
   * × USDINR
   * × (10 / 31.1034768)
   *
   * = INR/10g
   */

  const priceInrPer10g =
    goldPriceUsd *
    usdInr *
    (10 / gramsPerTroyOunce);

  const previousCloseInrPer10g =
    goldPreviousUsd *
    usdInr *
    (10 / gramsPerTroyOunce);

  const change =
    priceInrPer10g -
    previousCloseInrPer10g;

  const changePercent =
    previousCloseInrPer10g !== 0
      ? (change /
        previousCloseInrPer10g) *
      100
      : 0;

  return {
    price:
      priceInrPer10g,

    previousClose:
      previousCloseInrPer10g,

    change,

    changePercent,

    currency:
      "INR",

    unit:
      "10g",

    marketTime:
      goldMeta.regularMarketTime
        ? new Date(
          goldMeta.regularMarketTime *
          1000
        ).toISOString()
        : null,

    updatedAt:
      new Date().toISOString(),
  };
}

/*
 * ============================================================
 * LIVE MARKET DATA
 *
 * Yahoo Finance public market feed
 *
 * NIFTY 50  -> ^NSEI
 * SENSEX    -> ^BSESN
 * Gold      -> GC=F + USDINR=X
 * Bitcoin   -> BTC-INR
 * Ethereum  -> ETH-INR
 * ============================================================
 */

app.get(
  "/api/live-market",
  async (c) => {
    try {
      const symbols = [
        {
          name:
            "NIFTY 50",

          yahoo:
            "%5ENSEI",

          currency:
            "INR",
        },

        {
          name:
            "SENSEX",

          yahoo:
            "%5EBSESN",

          currency:
            "INR",
        },

        {
          name:
            "Gold",

          yahoo:
            "GC=F",

          currency:
            "INR",
        },

        {
          name:
            "Bitcoin",

          yahoo:
            "BTC-INR",

          currency:
            "INR",
        },

        {
          name:
            "Ethereum",

          yahoo:
            "ETH-INR",

          currency:
            "INR",
        },
      ];

      const results = [];

      for (const item of symbols) {

        /*
         * Gold needs special handling because
         * Yahoo gives GC=F in USD/troy ounce.
         */

        if (item.yahoo === "GC=F") {
          const gold =
            await getGoldPriceInrPer10g();

          results.push({
            name:
              item.name,

            price:
              gold.price,

            previousClose:
              gold.previousClose,

            change:
              gold.change,

            changePercent:
              gold.changePercent,

            currency:
              "INR",

            unit:
              "10g",

            marketTime:
              gold.marketTime,
          });

          continue;
        }

        const url =
          `https://query1.finance.yahoo.com/v8/finance/chart/${item.yahoo}` +
          "?interval=1m&range=1d";

        const response =
          await fetch(url);

        if (!response.ok) {
          throw new Error(
            `Market API returned HTTP ${response.status}`
          );
        }

        const data =
          await response.json();

        const result =
          data.chart?.result?.[0];

        if (!result) {
          throw new Error(
            `No market data returned for ${item.name}`
          );
        }

        const meta =
          result.meta;

        const price =
          Number(
            meta.regularMarketPrice
          );

        const previousClose =
          Number(
            meta.previousClose
          );

        const change =
          price -
          previousClose;

        const changePercent =
          previousClose !== 0
            ? (change /
              previousClose) *
            100
            : 0;

        results.push({
          name:
            item.name,

          price,

          previousClose,

          change,

          changePercent,

          currency:
            item.currency,

          marketTime:
            meta.regularMarketTime
              ? new Date(
                meta.regularMarketTime *
                1000
              ).toISOString()
              : null,
        });
      }

      return c.json({
        success:
          true,

        source:
          "Yahoo Finance market data",

        updatedAt:
          new Date().toISOString(),

        markets:
          results,
      });

    } catch (error) {
      console.error(
        "Live market error:",
        error
      );

      return c.json(
        {
          success:
            false,

          error:
            "Unable to retrieve live market data",

          details:
            error instanceof Error
              ? error.message
              : String(error),
        },
        502
      );
    }
  }
);

/*
 * ============================================================
 * CURRENT MARKET PRICE
 *
 * Used by the Portfolio screen.
 *
 * Examples:
 *
 * GET /api/market-price?symbol=RELIANCE.NS
 * GET /api/market-price?symbol=TCS.NS
 * GET /api/market-price?symbol=BTC-INR
 * GET /api/market-price?symbol=ETH-INR
 * GET /api/market-price?symbol=GC=F
 * ============================================================
 */

app.get(
  "/api/market-price",
  async (c) => {
    try {
      const symbol =
        c.req
          .query("symbol")
          ?.trim()
          .toUpperCase();

      if (!symbol) {
        return c.json(
          {
            success:
              false,

            error:
              "Missing symbol",
          },
          400
        );
      }

      console.log(
        `Fetching current market price for ${symbol}`
      );

      /*
       * ========================================================
       * GOLD
       *
       * GC=F from Yahoo Finance is:
       *
       * USD per troy ounce
       *
       * Convert to:
       *
       * INR per 10 grams
       * ========================================================
       */

      if (symbol === "GC=F") {

        const gold =
          await getGoldPriceInrPer10g();

        return c.json({
          success:
            true,

          market: {
            symbol:
              "GC=F",

            price:
              gold.price,

            previousClose:
              gold.previousClose,

            change:
              gold.change,

            changePercent:
              gold.changePercent,

            currency:
              "INR",

            unit:
              "10g",

            marketTime:
              gold.marketTime,

            updatedAt:
              gold.updatedAt,
          },

          source:
            "Yahoo Finance market data + USD/INR conversion",
        });
      }

      /*
       * ========================================================
       * ALL OTHER ASSETS
       *
       * Stocks:
       * RELIANCE.NS
       * TCS.NS
       *
       * Crypto:
       * BTC-INR
       * ETH-INR
       * ========================================================
       */

      const url =
        `https://query1.finance.yahoo.com/v8/finance/chart/${encodeURIComponent(symbol)}` +
        "?interval=1m&range=1d";

      const response =
        await fetch(url);

      if (!response.ok) {
        return c.json(
          {
            success:
              false,

            error:
              `Market provider returned HTTP ${response.status}`,

            symbol,
          },
          502
        );
      }

      const data =
        await response.json();

      const result =
        data.chart?.result?.[0];

      if (!result) {
        return c.json(
          {
            success:
              false,

            error:
              `No market data found for ${symbol}`,

            symbol,
          },
          404
        );
      }

      const meta =
        result.meta;

      const price =
        Number(
          meta.regularMarketPrice
        );

      const previousClose =
        Number(
          meta.previousClose
        );

      const change =
        price -
        previousClose;

      const changePercent =
        previousClose !== 0
          ? (change /
            previousClose) *
          100
          : 0;

      return c.json({
        success:
          true,

        market: {
          symbol,

          price,

          previousClose,

          change,

          changePercent,

          currency:
            meta.currency ??
            "USD",

          marketTime:
            meta.regularMarketTime
              ? new Date(
                meta.regularMarketTime *
                1000
              ).toISOString()
              : null,

          updatedAt:
            new Date().toISOString(),
        },

        source:
          "Yahoo Finance market data",
      });

    } catch (error) {
      console.error(
        "Market price error:",
        error
      );

      return c.json(
        {
          success:
            false,

          error:
            "Unable to retrieve market price",

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

/*
 * ============================================================
 * Health check
 *
 * This endpoint is NOT paid.
 * ============================================================
 */

app.get(
  "/health",
  (c) => {
    return c.json({
      status:
        "ok",

      service:
        "OneVest x402",

      network:
        "Algorand TestNet",

      marketDataProvider:
        "Yahoo Finance",
    });
  }
);

/*
 * ============================================================
 * Root endpoint
 * ============================================================
 */

app.get(
  "/",
  (c) => {
    return c.json({
      service:
        "OneVest x402",

      status:
        "running",

      endpoints: [
        "/health",

        "/api/live-market",

        "/api/market-price?symbol=RELIANCE.NS",

        "/api/market-price?symbol=TCS.NS",

        "/api/market-price?symbol=BTC-INR",

        "/api/market-price?symbol=ETH-INR",

        "/api/market-price?symbol=GC=F",

        "/api/market-intelligence?symbol=AAPL",

        "/api/market-intelligence?symbol=TSLA",

        "/api/market-intelligence?symbol=NVDA",
      ],
    });
  }
);
// ============================================================
// GEMINI AI ASSISTANT
// ============================================================

app.post("/api/ai", async (c) => {
  try {
    const body = await c.req.json();

    const question =
      typeof body?.question === "string"
        ? body.question.trim()
        : "";

    const prompt =
      typeof body?.prompt === "string"
        ? body.prompt.trim()
        : "";

    if (!question) {
      return c.json(
        {
          success: false,
          message: "Question is required.",
        },
        400,
      );
    }

    const finalPrompt = prompt || `
You are OneVest AI, an intelligent investment assistant.

Rules:
- Answer only finance and investment related questions.
- Keep answers short (3-6 lines).
- Be beginner friendly.
- If asked something unrelated, politely say you only answer investment questions.
- Give practical suggestions wherever possible.

User Question:
${question}
`;

    console.log("AI request received");

    const geminiResponse = await fetch(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.6-flash:generateContent",
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-goog-api-key": geminiApiKey!,
        },
        body: JSON.stringify({
          contents: [
            {
              parts: [
                {
                  text: finalPrompt,
                },
              ],
            },
          ],
        }),
      },
    );

    const geminiData = await geminiResponse.json();

    console.log(
      "Gemini API status:",
      geminiResponse.status,
    );

    if (!geminiResponse.ok) {
      console.error(
        "Gemini API error:",
        JSON.stringify(geminiData),
      );

      return c.json(
        {
          success: false,
          message: "Gemini API request failed.",
          status: geminiResponse.status,
          error:
            geminiData?.error?.message ??
            "Unknown Gemini API error.",
        },
        502,
      );
    }

    const answer =
      geminiData?.candidates?.[0]?.content?.parts?.[0]?.text;

    if (
      typeof answer !== "string" ||
      answer.trim().length === 0
    ) {
      console.error(
        "Gemini returned no text:",
        JSON.stringify(geminiData),
      );

      return c.json(
        {
          success: false,
          message: "Gemini returned an empty response.",
        },
        502,
      );
    }

    console.log("AI response generated successfully");

    return c.json({
      success: true,
      answer: answer.trim(),
    });
  } catch (error) {
    console.error(
      "AI endpoint error:",
      error,
    );

    return c.json(
      {
        success: false,
        message: "AI service is currently unavailable.",
      },
      500,
    );
  }
});
/*
 * ============================================================
 * Start server
 * ============================================================
 */

serve(
  {
    fetch:
      app.fetch,

    port:
      4021,
  },

  () => {
    console.log(
      "OneVest x402 service running at http://localhost:4021"
    );

    console.log(
      "Market data provider: Yahoo Finance"
    );

    console.log(
      "Facilitator:",
      facilitatorUrl
    );
  }
);