import { config } from "dotenv";
import { Hono } from "hono";
import { serve } from "@hono/node-server";
import { cors } from "hono/cors";

import {
  paymentMiddleware,
  x402ResourceServer,
} from "@x402-avm/hono";

import {
  HTTPFacilitatorClient,
} from "@x402-avm/core/server";

import {
  ExactAvmScheme,
} from "@x402-avm/avm/exact/server";

import {
  declareDiscoveryExtension,
} from "@x402-avm/extensions";

config();

const app = new Hono();

/* ============================================================
 * CORS
 * ============================================================ */

app.use(
  "*",
  cors({
    origin: "*",
    allowMethods: [
      "GET",
      "POST",
      "PUT",
      "DELETE",
      "OPTIONS",
    ],
    allowHeaders: [
      "Content-Type",
      "Authorization",
    ],
  }),
);

/* ============================================================
 * ENVIRONMENT
 * ============================================================ */

const avmAddress = process.env.AVM_ADDRESS;
const groqApiKey = process.env.GROQ_API_KEY;
const alphaVantageApiKey =
  process.env.ALPHA_VANTAGE_API_KEY;

const facilitatorUrl =
  process.env.FACILITATOR_URL ||
  "https://facilitator.goplausible.xyz";

if (!avmAddress) {
  console.error("Missing AVM_ADDRESS in .env");
  process.exit(1);
}

if (!groqApiKey) {
  console.error("Missing GROQ_API_KEY in .env");
  process.exit(1);
}

if (!alphaVantageApiKey) {
  console.warn(
    "ALPHA_VANTAGE_API_KEY is missing. Historical context will be unavailable.",
  );
}

/* ============================================================
 * ALGORAND TESTNET / x402
 * ============================================================ */

const ALGORAND_TESTNET =
  "algorand:SGO1GKSzyE7IEPItTxCByw9x8FmnrCDexi9/cOUJOiI=";

const USDC_TESTNET_ASA_ID = "10458941";

const facilitatorClient =
  new HTTPFacilitatorClient({
    url: facilitatorUrl,
  });

const resourceServer =
  new x402ResourceServer(
    facilitatorClient,
  ).register(
    ALGORAND_TESTNET,
    new ExactAvmScheme(),
  );

/* ============================================================
 * DISCOVERY METADATA
 * ============================================================ */

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

/* ============================================================
 * GENERIC HELPERS
 * ============================================================ */

function clampScore(
  value: unknown,
  fallback = 50,
): number {
  const numberValue = Number(value);

  if (!Number.isFinite(numberValue)) {
    return fallback;
  }

  return Math.max(
    0,
    Math.min(100, Math.round(numberValue)),
  );
}

function cleanJsonText(text: string): string {
  let cleaned = text.trim();

  if (cleaned.startsWith("```")) {
    cleaned = cleaned
      .replace(/^```(?:json)?\s*/i, "")
      .replace(/\s*```$/i, "")
      .trim();
  }

  return cleaned;
}

function parseAiJson(text: string): any {
  const cleaned = cleanJsonText(text);

  try {
    return JSON.parse(cleaned);
  } catch {
    const start = cleaned.indexOf("{");
    const end = cleaned.lastIndexOf("}");

    if (start >= 0 && end > start) {
      return JSON.parse(
        cleaned.slice(start, end + 1),
      );
    }

    throw new Error(
      "Groq returned invalid JSON.",
    );
  }
}

async function fetchWithTimeout(
  url: string,
  init?: RequestInit,
  timeoutMs = 30_000,
): Promise<Response> {
  return fetch(url, {
    ...init,
    signal:
      init?.signal ??
      AbortSignal.timeout(timeoutMs),
  });
}

/* ============================================================
 * GROQ
 * ============================================================ */

const GROQ_URL =
  "https://api.groq.com/openai/v1/chat/completions";

const GROQ_MODEL = "openai/gpt-oss-20b";

async function callGroq(
  prompt: string,
  jsonMode = false,
): Promise<string> {
  let lastError: unknown = null;

  for (let attempt = 1; attempt <= 3; attempt++) {
    try {
      console.log(
        `Groq request attempt ${attempt}/3...`,
      );

      const body: Record<string, unknown> = {
        model: GROQ_MODEL,
        messages: [
          {
            role: "user",
            content: prompt,
          },
        ],
        temperature: 0.2,
      };

      if (jsonMode) {
        body.response_format = {
          type: "json_object",
        };
      }

      const response =
        await fetchWithTimeout(
          GROQ_URL,
          {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
              Authorization:
                `Bearer ${groqApiKey}`,
            },
            body: JSON.stringify(body),
          },
          30_000,
        );

      const data: any =
        await response.json();

      console.log(
        `Groq HTTP status: ${response.status}`,
      );

      if (!response.ok) {
        const message =
          data?.error?.message ||
          `Groq request failed with HTTP ${response.status}`;

        if (
          response.status === 429 &&
          attempt < 3
        ) {
          const delay = 1500 * attempt;

          console.warn(
            `${message}. Retrying in ${delay}ms...`,
          );

          await new Promise((resolve) =>
            setTimeout(resolve, delay),
          );

          continue;
        }

        throw new Error(message);
      }

      const content =
        data?.choices?.[0]?.message?.content;

      if (
        typeof content !== "string" ||
        content.trim().length === 0
      ) {
        throw new Error(
          "Groq returned an empty response.",
        );
      }

      return content.trim();
    } catch (error) {
      lastError = error;

      console.error(
        `Groq attempt ${attempt}/3 failed:`,
        error,
      );

      if (attempt < 3) {
        await new Promise((resolve) =>
          setTimeout(
            resolve,
            1500 * attempt,
          ),
        );
      }
    }
  }

  throw new Error(
    lastError instanceof Error
      ? lastError.message
      : "Groq request failed.",
  );
}

/* ============================================================
 * YAHOO FINANCE
 * Yahoo Finance = LIVE MARKET DATA
 * ============================================================ */

async function getYahooQuote(
  symbol: string,
) {
  const url =
    `https://query1.finance.yahoo.com/v8/finance/chart/${encodeURIComponent(symbol)}` +
    "?interval=1m&range=1d";

  const response =
    await fetchWithTimeout(
      url,
      undefined,
      20_000,
    );

  if (!response.ok) {
    throw new Error(
      `Yahoo Finance returned HTTP ${response.status}`,
    );
  }

  const data: any =
    await response.json();

  const result =
    data.chart?.result?.[0];

  if (!result?.meta) {
    throw new Error(
      `No Yahoo Finance data found for ${symbol}`,
    );
  }

  const meta = result.meta;

  const price =
    Number(meta.regularMarketPrice);

  const previousCloseRaw =
    Number(meta.previousClose);

  if (!Number.isFinite(price)) {
    throw new Error(
      `Invalid Yahoo Finance price for ${symbol}`,
    );
  }

  const previousClose =
    Number.isFinite(previousCloseRaw)
      ? previousCloseRaw
      : null;

  const change =
    previousClose !== null
      ? price - previousClose
      : 0;

  const changePercent =
    previousClose !== null &&
    previousClose !== 0
      ? (change / previousClose) * 100
      : 0;

  return {
    symbol,
    price,
    previousClose,
    change,
    changePercent,
    currency:
      meta.currency ?? "USD",
    exchange:
      meta.exchangeName ??
      meta.fullExchangeName ??
      null,
    instrumentType:
      meta.instrumentType ?? null,
    marketTime:
      meta.regularMarketTime
        ? new Date(
            meta.regularMarketTime * 1000,
          ).toISOString()
        : null,
    updatedAt:
      new Date().toISOString(),
  };
}

/* ============================================================
 * GOLD
 * Yahoo GC=F = USD/troy ounce
 * OneVest = INR/10 grams
 * ============================================================ */

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
    fetchWithTimeout(
      goldUrl,
      undefined,
      20_000,
    ),
    fetchWithTimeout(
      usdInrUrl,
      undefined,
      20_000,
    ),
  ]);

  if (!goldResponse.ok) {
    throw new Error(
      `Gold provider returned HTTP ${goldResponse.status}`,
    );
  }

  if (!usdInrResponse.ok) {
    throw new Error(
      `USD/INR provider returned HTTP ${usdInrResponse.status}`,
    );
  }

  const goldData: any =
    await goldResponse.json();

  const usdInrData: any =
    await usdInrResponse.json();

  const goldResult =
    goldData.chart?.result?.[0];

  const usdInrResult =
    usdInrData.chart?.result?.[0];

  if (!goldResult?.meta) {
    throw new Error(
      "No gold market data found",
    );
  }

  if (!usdInrResult?.meta) {
    throw new Error(
      "No USD/INR exchange rate found",
    );
  }

  const goldMeta = goldResult.meta;
  const usdInrMeta = usdInrResult.meta;

  const goldPriceUsd =
    Number(
      goldMeta.regularMarketPrice,
    );

  const goldPreviousUsd =
    Number(goldMeta.previousClose);

  const usdInr =
    Number(
      usdInrMeta.regularMarketPrice,
    );

  if (
    !Number.isFinite(goldPriceUsd) ||
    !Number.isFinite(goldPreviousUsd) ||
    !Number.isFinite(usdInr) ||
    usdInr <= 0
  ) {
    throw new Error(
      "Invalid gold or USD/INR market data",
    );
  }

  const gramsPerTroyOunce =
    31.1034768;

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
    price: priceInrPer10g,
    previousClose:
      previousCloseInrPer10g,
    change,
    changePercent,
    currency: "INR",
    unit: "10g",
    marketTime:
      goldMeta.regularMarketTime
        ? new Date(
            goldMeta.regularMarketTime * 1000,
          ).toISOString()
        : null,
    updatedAt:
      new Date().toISOString(),
  };
}

/* ============================================================
 * ALPHA VANTAGE TYPES
 * ============================================================ */

type AlphaVantageSnapshot = {
  symbol: string;
  providerSymbol: string;
  latestClose: number | null;
  previousClose: number | null;
  changePercent: number | null;
  fiveDayReturn: number | null;
  twentyDayReturn: number | null;
  sma20: number | null;
  distanceFromSma20Percent:
    number | null;
  recentHigh: number | null;
  recentLow: number | null;
  averageVolume20: number | null;
  latestVolume: number | null;
  dataDate: string | null;
  source: string;
};

const alphaCache =
  new Map<
    string,
    {
      expiresAt: number;
      data: AlphaVantageSnapshot;
    }
  >();

const ALPHA_CACHE_MS =
  5 * 60_000;

/* ============================================================
 * ALPHA VANTAGE HISTORICAL DATA
 * ============================================================ */

async function getAlphaVantageContext(
  symbol: string,
): Promise<AlphaVantageSnapshot | null> {
  if (!alphaVantageApiKey) {
    return null;
  }

  const cached =
    alphaCache.get(symbol);

  if (
    cached &&
    cached.expiresAt > Date.now()
  ) {
    console.log(
      `Alpha Vantage cache hit for ${symbol}`,
    );

    return cached.data;
  }

  let providerSymbol = symbol;

  if (symbol.endsWith(".NS")) {
    const base =
      symbol.slice(0, -3);

    providerSymbol =
      `${base}.BSE`;
  }

  const url =
    "https://www.alphavantage.co/query" +
    "?function=TIME_SERIES_DAILY" +
    `&symbol=${encodeURIComponent(providerSymbol)}` +
    "&outputsize=compact" +
    `&apikey=${encodeURIComponent(alphaVantageApiKey)}`;

  try {
    console.log(
      `Fetching Alpha Vantage history for ${providerSymbol}...`,
    );

    const response =
      await fetchWithTimeout(
        url,
        undefined,
        30_000,
      );

    if (!response.ok) {
      console.warn(
        `Alpha Vantage returned HTTP ${response.status}`,
      );

      return null;
    }

    const data: any =
      await response.json();

    if (
      data.Note ||
      data.Information
    ) {
      console.warn(
        "Alpha Vantage message:",
        data.Note ??
          data.Information,
      );

      return null;
    }

    const timeSeries =
      data["Time Series (Daily)"];

    if (
      !timeSeries ||
      typeof timeSeries !== "object"
    ) {
      console.warn(
        `No Alpha Vantage historical data found for ${providerSymbol}`,
      );

      return null;
    }

    const rows =
      Object.entries(timeSeries)
        .map(([date, raw]) => {
          const item =
            raw as Record<string, string>;

          return {
            date,
            open: Number(item["1. open"]),
            high: Number(item["2. high"]),
            low: Number(item["3. low"]),
            close: Number(item["4. close"]),
            volume: Number(item["5. volume"]),
          };
        })
        .filter((row) =>
          Number.isFinite(row.close),
        )
        .sort(
          (a, b) =>
            new Date(b.date).getTime() -
            new Date(a.date).getTime(),
        );

    if (rows.length === 0) {
      return null;
    }

    const latest = rows[0];
    const previous =
      rows[1] ?? null;

    const previousClose =
      previous?.close ?? null;

    const changePercent =
      previousClose !== null &&
      previousClose !== 0
        ? ((latest.close -
              previousClose) /
            previousClose) *
          100
        : null;

    const fiveDayReference =
      rows[4] ?? null;

    const fiveDayReturn =
      fiveDayReference &&
      fiveDayReference.close !== 0
        ? ((latest.close -
              fiveDayReference.close) /
            fiveDayReference.close) *
          100
        : null;

    const twentyDayReference =
      rows[19] ?? null;

    const twentyDayReturn =
      twentyDayReference &&
      twentyDayReference.close !== 0
        ? ((latest.close -
              twentyDayReference.close) /
            twentyDayReference.close) *
          100
        : null;

    const recentRows =
      rows.slice(
        0,
        Math.min(20, rows.length),
      );

    const sma20 =
      recentRows.length > 0
        ? recentRows.reduce(
            (sum, row) =>
              sum + row.close,
            0,
          ) / recentRows.length
        : null;

    const distanceFromSma20Percent =
      sma20 !== null &&
      sma20 !== 0
        ? ((latest.close - sma20) /
            sma20) *
          100
        : null;

    const recentHigh =
      recentRows.length > 0
        ? Math.max(
            ...recentRows.map(
              (row) => row.high,
            ),
          )
        : null;

    const recentLow =
      recentRows.length > 0
        ? Math.min(
            ...recentRows.map(
              (row) => row.low,
            ),
          )
        : null;

    const volumeRows =
      recentRows.filter((row) =>
        Number.isFinite(row.volume),
      );

    const averageVolume20 =
      volumeRows.length > 0
        ? volumeRows.reduce(
            (sum, row) =>
              sum + row.volume,
            0,
          ) / volumeRows.length
        : null;

    const latestVolume =
      Number.isFinite(latest.volume)
        ? latest.volume
        : null;

    const snapshot:
      AlphaVantageSnapshot = {
      symbol,
      providerSymbol,
      latestClose: latest.close,
      previousClose,
      changePercent,
      fiveDayReturn,
      twentyDayReturn,
      sma20,
      distanceFromSma20Percent,
      recentHigh,
      recentLow,
      averageVolume20,
      latestVolume,
      dataDate: latest.date,
      source:
        "Alpha Vantage historical market data",
    };

    alphaCache.set(
      symbol,
      {
        expiresAt:
          Date.now() +
          ALPHA_CACHE_MS,
        data: snapshot,
      },
    );

    console.log(
      `Alpha Vantage historical context loaded successfully for ${symbol} using ${providerSymbol}.`,
    );

    return snapshot;
  } catch (error) {
    console.warn(
      `Alpha Vantage request failed for ${providerSymbol}:`,
      error,
    );

    return null;
  }
}

/* ============================================================
 * x402 PREMIUM MARKET INTELLIGENCE
 * GET /api/market-intelligence?symbol=TCS.NS
 * Price: $0.005 USDC
 * ============================================================ */

app.use(
  paymentMiddleware(
    {
      "GET /api/market-intelligence": {
        accepts: {
          scheme: "exact",
          price: "$0.005",
          network: ALGORAND_TESTNET,
          payTo: avmAddress,
          extra: {
            asset: USDC_TESTNET_ASA_ID,
          },
        },
        description:
          "OneVest Market Intelligence service",
        mimeType:
          "application/json",
        extensions: {
          ...marketDiscovery,
        },
      },
    },
    resourceServer,
  ),
);

/* ============================================================
 * PREMIUM MARKET INTELLIGENCE ENDPOINT
 * ============================================================ */

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
            example:
              "/api/market-intelligence?symbol=TCS.NS",
          },
          400,
        );
      }

      console.log("");
      console.log(
        "========================================",
      );
      console.log(
        "PAID ONEVEST AI INTELLIGENCE",
      );
      console.log(`Symbol: ${symbol}`);
      console.log(
        "========================================",
      );

      /* 1. LIVE DATA */

      let market: any;

      try {
        market =
          await getYahooQuote(symbol);
      } catch (error) {
        console.error(
          "Yahoo Finance error:",
          error,
        );

        return c.json(
          {
            success: false,
            error:
              "Unable to retrieve live market data.",
            symbol,
          },
          502,
        );
      }

      /* 2. HISTORICAL DATA */

      let alphaVantage:
        | AlphaVantageSnapshot
        | null = null;

      try {
        alphaVantage =
          await getAlphaVantageContext(
            symbol,
          );
      } catch (error) {
        console.warn(
          "Alpha Vantage context failed:",
          error,
        );
      }

      /* 3. DIRECTION */

      const direction =
        market.changePercent > 0
          ? "positive"
          : market.changePercent < 0
            ? "negative"
            : "flat";

      /* 4. GROQ PROMPT */

      const aiPrompt = `
You are OneVest Intelligence, a premium AI financial analysis engine.

Analyze ONLY the supplied market data.

IMPORTANT RULES:
- This is financial market intelligence, not a guaranteed prediction.
- Never claim certainty.
- Do not provide a direct buy or sell command.
- Use Bullish, Neutral, or Bearish for sentiment.
- Do not fabricate news, earnings, financial statements, valuation metrics, or unsupported indicators.
- Use only the supplied Yahoo Finance and Alpha Vantage data.
- Yahoo Finance provides the current market snapshot.
- Alpha Vantage provides historical daily context.
- Alpha Vantage is not real-time.
- If Alpha Vantage is unavailable, ignore that section.
- Do not invent missing values.
- OneVest scores are interpretation scores, not official indicators.
- Return ONLY valid JSON.
- Do not use markdown or code fences.

CURRENT LIVE MARKET DATA:
Symbol: ${symbol}
Price: ${market.price}
Previous Close: ${market.previousClose}
Change: ${market.change}
Change Percent: ${market.changePercent}
Currency: ${market.currency}
Exchange: ${market.exchange}
Instrument Type: ${market.instrumentType}
Current Direction: ${direction}

ALPHA VANTAGE HISTORICAL CONTEXT:
${JSON.stringify(alphaVantage, null, 2)}

Use historical data to:
- Identify whether recent movement supports or contradicts current direction.
- Consider the 5-day return when available.
- Consider the 20-day return when available.
- Consider SMA20 when available.
- Consider distance from SMA20 when available.
- Consider recent high and low when available.
- Consider volume context when available.
- Never treat these values as guaranteed predictions.

Return EXACTLY this JSON structure:
{
  "verdict": "Bullish | Neutral | Bearish",
  "confidence": 0,
  "momentum": 0,
  "volatility": 0,
  "risk": "Low | Moderate | High",
  "whyItMatters": [
    "string",
    "string",
    "string"
  ],
  "marketSummary": "string",
  "riskRadar": [
    {
      "name": "Price Momentum",
      "level": "Low | Moderate | High",
      "explanation": "string"
    },
    {
      "name": "Short-Term Volatility",
      "level": "Low | Moderate | High",
      "explanation": "string"
    },
    {
      "name": "Downside Risk",
      "level": "Low | Moderate | High",
      "explanation": "string"
    }
  ],
  "scenarios": [
    {
      "movement": -10,
      "description": "string"
    },
    {
      "movement": -5,
      "description": "string"
    },
    {
      "movement": 5,
      "description": "string"
    },
    {
      "movement": 10,
      "description": "string"
    }
  ],
  "watchItems": [
    "string",
    "string",
    "string"
  ],
  "nextBestAction": {
    "title": "Monitor | Review | Research",
    "reason": "string"
  },
  "thesisTriggers": [
    {
      "type": "positive",
      "trigger": "string",
      "explanation": "string"
    },
    {
      "type": "neutral",
      "trigger": "string",
      "explanation": "string"
    },
    {
      "type": "negative",
      "trigger": "string",
      "explanation": "string"
    }
  ]
}

NUMERIC RULES:
- confidence must be 0-100.
- momentum must be 0-100.
- volatility must be 0-100.
- Keep all numeric scores between 0 and 100.
- Positive current movement may support higher momentum.
- Negative current movement may support lower momentum.
- Near-zero current movement should generally support Neutral sentiment.
- Historical context may modify the interpretation.
- Never treat one daily movement as proof of a long-term trend.

SCENARIO RULES:
- Scenarios are hypothetical examples only.
- They are NOT forecasts.
- Do not claim that the price will reach these levels.
- Use the current price to calculate approximate hypothetical movements.
- Clearly communicate uncertainty.

THESIS TRIGGER RULES:
- Provide exactly 3 triggers.
- One positive trigger.
- One neutral trigger.
- One negative trigger.
- Use only supplied market information.
`;

      /* 5. CALL GROQ */

      let aiText: string;

      try {
        aiText =
          await callGroq(
            aiPrompt,
            true,
          );
      } catch (error) {
        console.error(
          "Premium Groq error:",
          error,
        );

        return c.json(
          {
            success: false,
            error:
              "Premium AI analysis failed.",
            provider: "Groq AI",
            details:
              error instanceof Error
                ? error.message
                : String(error),
          },
          502,
        );
      }

      /* 6. PARSE AI RESPONSE */

      let intelligence: any;

      try {
        intelligence =
          parseAiJson(aiText);
      } catch (error) {
        console.error(
          "Invalid Groq JSON:",
          aiText,
        );

        return c.json(
          {
            success: false,
            error:
              "Premium AI returned an invalid analysis.",
            provider: "Groq AI",
            details:
              error instanceof Error
                ? error.message
                : String(error),
          },
          502,
        );
      }

      /* 7. NORMALIZE AI RESPONSE */

      const verdict =
        intelligence?.verdict ===
          "Bullish" ||
        intelligence?.verdict ===
          "Bearish"
          ? intelligence.verdict
          : "Neutral";

      const risk =
        [
          "Low",
          "Moderate",
          "High",
        ].includes(
          intelligence?.risk,
        )
          ? intelligence.risk
          : "Moderate";

      const riskRadar =
        Array.isArray(
          intelligence?.riskRadar,
        )
          ? intelligence.riskRadar
              .slice(0, 3)
              .map((item: any) => ({
                name:
                  typeof item?.name ===
                  "string"
                    ? item.name
                    : "Risk",
                level:
                  [
                    "Low",
                    "Moderate",
                    "High",
                  ].includes(
                    item?.level,
                  )
                    ? item.level
                    : "Moderate",
                explanation:
                  typeof item?.explanation ===
                  "string"
                    ? item.explanation
                    : "Risk is being monitored.",
              }))
          : [];

      const scenarios =
        Array.isArray(
          intelligence?.scenarios,
        )
          ? intelligence.scenarios
              .slice(0, 4)
              .map((item: any) => ({
                movement:
                  Number.isFinite(
                    Number(item?.movement),
                  )
                    ? Number(item.movement)
                    : 0,
                description:
                  typeof item?.description ===
                  "string"
                    ? item.description
                    : "Hypothetical market scenario.",
              }))
          : [];

      const thesisTriggers =
        Array.isArray(
          intelligence?.thesisTriggers,
        )
          ? intelligence.thesisTriggers
              .slice(0, 3)
              .map((item: any) => ({
                type:
                  [
                    "positive",
                    "neutral",
                    "negative",
                  ].includes(item?.type)
                    ? item.type
                    : "neutral",
                trigger:
                  typeof item?.trigger ===
                  "string"
                    ? item.trigger
                    : "Monitor market conditions.",
                explanation:
                  typeof item?.explanation ===
                  "string"
                    ? item.explanation
                    : "Continue monitoring the market.",
              }))
          : [];

      intelligence = {
        verdict,
        confidence:
          clampScore(
            intelligence?.confidence,
            50,
          ),
        momentum:
          clampScore(
            intelligence?.momentum,
            50,
          ),
        volatility:
          clampScore(
            intelligence?.volatility,
            50,
          ),
        risk,
        whyItMatters:
          Array.isArray(
            intelligence?.whyItMatters,
          )
            ? intelligence.whyItMatters
                .slice(0, 3)
                .map(String)
            : [],
        marketSummary:
          typeof intelligence?.marketSummary ===
          "string"
            ? intelligence.marketSummary
            : "Market conditions are being monitored.",
        riskRadar,
        scenarios,
        watchItems:
          Array.isArray(
            intelligence?.watchItems,
          )
            ? intelligence.watchItems
                .slice(0, 3)
                .map(String)
            : [],
        nextBestAction:
          intelligence?.nextBestAction &&
          typeof intelligence.nextBestAction ===
            "object"
            ? {
                title:
                  [
                    "Monitor",
                    "Review",
                    "Research",
                  ].includes(
                    intelligence
                      .nextBestAction
                      .title,
                  )
                    ? intelligence
                        .nextBestAction
                        .title
                    : "Monitor",
                reason:
                  typeof intelligence
                    .nextBestAction
                    .reason ===
                  "string"
                    ? intelligence
                        .nextBestAction
                        .reason
                    : "Continue monitoring market conditions.",
              }
            : {
                title: "Monitor",
                reason:
                  "Continue monitoring market conditions.",
              },
        thesisTriggers,
      };

      /* 8. PREMIUM METRICS */

      const confidence =
        intelligence.confidence;

      const momentum =
        intelligence.momentum;

      const volatility =
        intelligence.volatility;

      const stability =
        100 - volatility;

      const signalScore =
        Math.round(
          (
            confidence +
            momentum +
            stability
          ) / 3,
        );

      /* 9. PREMIUM RESPONSE */

      console.log(
        "Premium intelligence generated successfully.",
      );

      return c.json({
        success: true,
        service:
          "OneVest Premium Market Intelligence",
        premium: true,
        paymentProtected: true,

        payment: {
          scheme: "exact",
          network: "Algorand TestNet",
          asset: "USDC TestNet",
          price: "$0.005",
        },

        market,

        dataSources: {
          liveMarket:
            "Yahoo Finance",
          historicalContext:
            alphaVantage
              ? "Alpha Vantage"
              : "Unavailable",
          aiEngine: "Groq AI",
          aggregation:
            "OneVest Multi-Source Intelligence Engine",
        },

        alphaVantage,
        intelligence,

        premiumMetrics: {
          tier: "ONEVEST_PREMIUM",
          signalScore,
          confidence,
          momentum,
          stability,
          volatility,
          engine:
            "OneVest AI Intelligence",
          liveDataSource:
            "Yahoo Finance",
          historicalDataSource:
            alphaVantage
              ? "Alpha Vantage"
              : "Unavailable",
          aiProvider: "Groq AI",
          x402Network:
            "Algorand TestNet",
          paymentProtected: true,
          generatedAt:
            new Date().toISOString(),
        },

        source:
          "OneVest x402 + Yahoo Finance + Alpha Vantage + Groq",

        generatedAt:
          new Date().toISOString(),

        message:
          "Premium multi-source OneVest intelligence unlocked after x402 payment.",
      });
    } catch (error) {
      console.error(
        "Premium intelligence error:",
        error,
      );

      return c.json(
        {
          success: false,
          error:
            "Premium market intelligence is currently unavailable.",
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

/* ============================================================
 * LIVE MARKET DASHBOARD
 * ============================================================ */

app.get(
  "/api/live-market",
  async (c) => {
    try {
      const symbols = [
        {
          name: "NIFTY 50",
          yahoo: "^NSEI",
          currency: "INR",
        },
        {
          name: "SENSEX",
          yahoo: "^BSESN",
          currency: "INR",
        },
        {
          name: "Gold",
          yahoo: "GC=F",
          currency: "INR",
        },
        {
          name: "Bitcoin",
          yahoo: "BTC-INR",
          currency: "INR",
        },
        {
          name: "Ethereum",
          yahoo: "ETH-INR",
          currency: "INR",
        },
      ];

      const results: any[] = [];

      for (const item of symbols) {
        try {
          if (item.yahoo === "GC=F") {
            const gold =
              await getGoldPriceInrPer10g();

            results.push({
              name: item.name,
              price: gold.price,
              previousClose:
                gold.previousClose,
              change: gold.change,
              changePercent:
                gold.changePercent,
              currency: "INR",
              unit: "10g",
              marketTime:
                gold.marketTime,
            });

            continue;
          }

          const quote =
            await getYahooQuote(
              item.yahoo,
            );

          results.push({
            name: item.name,
            price: quote.price,
            previousClose:
              quote.previousClose,
            change: quote.change,
            changePercent:
              quote.changePercent,
            currency: item.currency,
            marketTime:
              quote.marketTime,
          });
        } catch (error) {
          console.warn(
            `Failed to load ${item.name}:`,
            error,
          );

          results.push({
            name: item.name,
            price: null,
            previousClose: null,
            change: null,
            changePercent: null,
            currency: item.currency,
            marketTime: null,
            error:
              "Market data unavailable",
          });
        }
      }

      return c.json({
        success: true,
        source:
          "Yahoo Finance market data",
        updatedAt:
          new Date().toISOString(),
        markets: results,
      });
    } catch (error) {
      console.error(
        "Live market error:",
        error,
      );

      return c.json(
        {
          success: false,
          error:
            "Unable to retrieve live market data",
          details:
            error instanceof Error
              ? error.message
              : String(error),
        },
        502,
      );
    }
  },
);

/* ============================================================
 * CURRENT MARKET PRICE
 * Used by Portfolio screen.
 * ============================================================ */

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
            success: false,
            error: "Missing symbol",
          },
          400,
        );
      }

      console.log(
        `Fetching current market price for ${symbol}`,
      );

      if (symbol === "GC=F") {
        const gold =
          await getGoldPriceInrPer10g();

        return c.json({
          success: true,
          market: {
            symbol: "GC=F",
            price: gold.price,
            previousClose:
              gold.previousClose,
            change: gold.change,
            changePercent:
              gold.changePercent,
            currency: "INR",
            unit: "10g",
            marketTime:
              gold.marketTime,
            updatedAt:
              gold.updatedAt,
          },
          source:
            "Yahoo Finance market data + USD/INR conversion",
        });
      }

      const market =
        await getYahooQuote(symbol);

      return c.json({
        success: true,
        market,
        source:
          "Yahoo Finance market data",
      });
    } catch (error) {
      console.error(
        "Market price error:",
        error,
      );

      return c.json(
        {
          success: false,
          error:
            "Unable to retrieve market price",
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

/* ============================================================
 * HEALTH CHECK
 * ============================================================ */

app.get(
  "/health",
  (c) => {
    return c.json({
      status: "ok",
      service: "OneVest x402",
      network:
        "Algorand TestNet",
      liveMarketProvider:
        "Yahoo Finance",
      historicalDataProvider:
        alphaVantageApiKey
          ? "Alpha Vantage"
          : "Unavailable",
      aiProvider: "Groq AI",
      aiModel: GROQ_MODEL,
      payment: "x402",
    });
  },
);

/* ============================================================
 * ROOT ENDPOINT
 * ============================================================ */

app.get(
  "/",
  (c) => {
    return c.json({
      service: "OneVest x402",
      status: "running",
      network:
        "Algorand TestNet",

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
        "/api/market-intelligence?symbol=TCS.NS",
        "/api/ai",
      ],
    });
  },
);

/* ============================================================
 * ONEVEST AI ASSISTANT
 * Separate from paid premium endpoint.
 * Uses Groq instead of Gemini.
 * ============================================================ */

app.post(
  "/api/ai",
  async (c) => {
    try {
      const body =
        await c.req.json();

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
            message:
              "Question is required.",
          },
          400,
        );
      }

      const finalPrompt =
        prompt ||
        `
You are OneVest AI, an intelligent investment assistant.

Rules:
- Answer only finance and investment related questions.
- Keep answers short and beginner friendly.
- Do not provide guaranteed predictions.
- Do not give a direct buy or sell command.
- If asked something unrelated, politely say you only answer investment questions.
- Give practical educational suggestions where possible.
- Clearly distinguish facts from general educational guidance.
- Never fabricate live prices, news, earnings, or financial data.

User Question:
${question}
`;

      console.log(
        "OneVest AI request received",
      );

      let answer: string;

      try {
        answer =
          await callGroq(
            finalPrompt,
            false,
          );
      } catch (error) {
        console.error(
          "Groq AI assistant error:",
          error,
        );

        return c.json(
          {
            success: false,
            message:
              "Groq AI request failed.",
            provider: "Groq AI",
            error:
              error instanceof Error
                ? error.message
                : String(error),
          },
          502,
        );
      }

      console.log(
        "OneVest AI response generated successfully",
      );

      return c.json({
        success: true,
        provider: "Groq AI",
        model: GROQ_MODEL,
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
          message:
            "AI service is currently unavailable.",
          provider: "Groq AI",
        },
        500,
      );
    }
  },
);

/* ============================================================
 * START SERVER
 * ============================================================ */

serve(
  {
    fetch: app.fetch,
    port: 4021,
  },
  () => {
    console.log(
      "========================================",
    );

    console.log(
      "OneVest x402 service running at http://localhost:4021",
    );

    console.log(
      "Network: Algorand TestNet",
    );

    console.log(
      "Live market: Yahoo Finance",
    );

    console.log(
      "Historical context: Alpha Vantage",
    );

    console.log(
      `AI engine: Groq AI (${GROQ_MODEL})`,
    );

    console.log(
      "Facilitator:",
      facilitatorUrl,
    );

    console.log(
      "========================================",
    );
  },
);