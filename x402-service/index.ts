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
 * Environment variables
 */
const avmAddress = process.env.AVM_ADDRESS;
const marketApiKey = process.env.MARKET_API_KEY;

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

/*
 * Algorand TestNet x402 network.
 */
const ALGORAND_TESTNET =
  "algorand:SGO1GKSzyE7IEPItTxCByw9x8FmnrCDexi9/cOUJOiI=";

/*
 * TestNet USDC ASA.
 */
const USDC_TESTNET_ASA_ID = "10458941";

/*
 * Hosted GoPlausible facilitator.
 */
const facilitatorClient =
  new HTTPFacilitatorClient({
    url: facilitatorUrl,
  });

/*
 * x402 Resource Server
 */
const resourceServer =
  new x402ResourceServer(
    facilitatorClient
  ).register(
    ALGORAND_TESTNET,
    new ExactAvmScheme()
  );

/*
 * Bazaar discovery metadata.
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
 * x402 protected route.
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
 * Real Market Intelligence API
 *
 * Data provider:
 * Alpha Vantage
 */
app.get(
  "/api/market-intelligence",
  async (c) => {

    const symbol =
      c.req
        .query("symbol")
        ?.toUpperCase() ||
      "AAPL";

    console.log(
      `Market data requested for ${symbol}`
    );

    try {

      /*
       * Alpha Vantage GLOBAL_QUOTE API.
       */
      const url =
        "https://www.alphavantage.co/query" +
        "?function=GLOBAL_QUOTE" +
        `&symbol=${encodeURIComponent(symbol)}` +
        `&apikey=${encodeURIComponent(marketApiKey)}`;

      console.log(
        `Fetching real market data for ${symbol}...`
      );

      const response =
        await fetch(url);

      if (!response.ok) {

        console.error(
          "Alpha Vantage HTTP error:",
          response.status
        );

        return c.json(
          {
            error:
              "Market data provider returned an error",
          },
          502
        );
      }

      const data =
        await response.json();

      /*
       * Alpha Vantage can return an
       * informational message when the
       * request limit is reached.
       */
      if (
        data.Note ||
        data.Information
      ) {

        console.error(
          "Alpha Vantage API message:",
          data.Note ||
          data.Information
        );

        return c.json(
          {
            error:
              "Market data API limit or access restriction",

            provider:
              "Alpha Vantage",
          },
          429
        );
      }

      /*
       * Extract Global Quote.
       */
      const quote =
        data["Global Quote"];

      if (
        !quote ||
        !quote["05. price"]
      ) {

        return c.json(
          {
            error:
              `No market data found for ${symbol}`,

            symbol,
          },
          404
        );
      }

      /*
       * Extract real market values.
       */
      const price =
        Number(
          quote["05. price"]
        );

      const changePercent =
        Number(
          String(
            quote["10. change percent"]
          ).replace("%", "")
        );

      const previousClose =
        Number(
          quote["08. previous close"]
        );

      const volume =
        Number(
          quote["06. volume"]
        );

      /*
       * Return real OneVest data.
       */
      return c.json({

        service:
          "OneVest Market Intelligence",

        market: {

          symbol,

          price,

          currency:
            "USD",

          changePercent,

          previousClose,

          volume,

          latestTradingDay:
            quote[
              "07. latest trading day"
            ],

          timestamp:
            new Date().toISOString(),
        },

        source:
          "Alpha Vantage",

        message:
          "Real market intelligence successfully accessed after x402 payment.",
      });

    } catch (error) {

      console.error(
        "Market data error:",
        error
      );

      return c.json(
        {
          error:
            "Unable to retrieve market data",
        },
        500
      );
    }
  }
);

/*
 * Health check.
 *
 * This endpoint is NOT paid.
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
        "Alpha Vantage",
    });
  }
);

/*
 * Root endpoint.
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

        "/api/market-intelligence?symbol=AAPL",

        "/api/market-intelligence?symbol=TSLA",

        "/api/market-intelligence?symbol=NVDA",
      ],
    });
  }
);

/*
 * Start server.
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
      "Market data provider: Alpha Vantage"
    );

    console.log(
      "Facilitator:",
      facilitatorUrl
    );
  }
);