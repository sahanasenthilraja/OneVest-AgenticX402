import { config } from "dotenv";
import { GoogleGenAI, Type } from "@google/genai";
import algosdk from "algosdk";

import {
  x402Client,
} from "@x402-avm/core/client";

import {
  toClientAvmSigner,
  ExactAvmScheme,
  ALGORAND_TESTNET_CAIP2,
} from "@x402-avm/avm";

import {
  wrapFetchWithPayment,
} from "@x402-avm/fetch";
config();

// ============================================================
// GEMINI CONFIGURATION
// ============================================================

const apiKey = process.env.GEMINI_API_KEY;

if (!apiKey) {
  throw new Error("GEMINI_API_KEY is missing from .env");
}

const ai = new GoogleGenAI({
  apiKey,
});
// ============================================================
// x402 PAYMENT CONFIGURATION
// ============================================================

const agentMnemonic =
  process.env.AGENT_MNEMONIC;

if (!agentMnemonic) {
  throw new Error(
    "AGENT_MNEMONIC is missing from .env",
  );
}

const agentAccount =
  algosdk.mnemonicToSecretKey(
    agentMnemonic,
  );

const privateKeyBase64 =
  Buffer.from(
    agentAccount.sk,
  ).toString("base64");

const avmSigner =
  toClientAvmSigner(
    privateKeyBase64,
  );

const x402ClientInstance =
  new x402Client();

x402ClientInstance.register(
  ALGORAND_TESTNET_CAIP2,
  new ExactAvmScheme(
    avmSigner,
  ),
);

const fetchWithPayment =
  wrapFetchWithPayment(
    fetch,
    x402ClientInstance,
);

// ============================================================
// ONEVEST MARKET INTELLIGENCE TOOL
// ============================================================
//
// This is the first real tool available to the AI agent.
//
// Gemini can decide:
// "I need market intelligence for AAPL."
//
// Then our backend executes this function.
//
// The function calls your existing x402 endpoint:
// /api/market-intelligence
//
// That endpoint handles the x402 payment flow.
//

const marketIntelligenceTool = {
  name: "get_market_intelligence",

  description:
    "Gets premium market intelligence for a stock symbol. " +
    "Use this when the user asks about current market conditions, " +
    "market intelligence, stock analysis, or recent information " +
    "about a specific stock. Do not use this for general financial " +
    "concept explanations that do not require live market data.",

  parameters: {
    type: Type.OBJECT,

    properties: {
      symbol: {
        type: Type.STRING,

        description:
          "The stock ticker symbol, for example AAPL, MSFT, " +
          "GOOGL, TSLA, or NVDA.",
      },
    },

    required: ["symbol"],
  },
};

// ============================================================
// EXECUTE MARKET INTELLIGENCE TOOL
// ============================================================

async function getMarketIntelligence(
  symbol: string,
): Promise<unknown> {
  const normalizedSymbol =
    symbol.trim().toUpperCase();

  console.log("");
  console.log(
    "=================================",
  );

  console.log(
    "AI TOOL CALL: get_market_intelligence",
  );

  console.log(
    "Symbol:",
    normalizedSymbol,
  );

  console.log(
    "=================================",
  );

  // ----------------------------------------------------------
  // Your existing OneVest x402 agent endpoint
  // ----------------------------------------------------------

  const agentUrl =
    process.env.AGENT_PUBLIC_URL ||
    "http://localhost:4020";

  const url =
    `${agentUrl}/api/market-intelligence?symbol=${encodeURIComponent(
      normalizedSymbol,
    )}`;

  console.log(
    "Calling OneVest market intelligence endpoint:",
    url,
  );

  // ----------------------------------------------------------
  // Call the existing x402-powered endpoint
  // ----------------------------------------------------------
const response =
  await fetchWithPayment(
    url,
    {
      method: "GET",
    },
  );

  const body =
    await response.text();

  console.log(
    "Market intelligence status:",
    response.status,
  );

  if (!response.ok) {
    throw new Error(
      `Market intelligence request failed (${response.status}): ${body}`,
    );
  }

  try {
    return JSON.parse(body);
  } catch {
    return {
      rawResponse: body,
    };
  }
}

// ============================================================
// ASK ONEVEST AI
// ============================================================

export async function askOneVestAI(
  message: string,
): Promise<string> {

  // ==========================================================
  // SYSTEM INSTRUCTIONS
  // ==========================================================

  const systemInstruction = `
You are OneVest AI, an intelligent personal finance assistant.

Your role:

- Help users understand investments.
- Explain financial concepts clearly.
- Analyze portfolio information when provided.
- Explain diversification, risk and asset allocation.
- Give personalized educational insights.
- Use market intelligence when current market information is needed.
- Never invent current stock prices or market data.
- When the user asks for current/recent market intelligence about
  a specific stock, use the get_market_intelligence tool.
- Clearly explain when information comes from market intelligence.
- Be concise and easy to understand.
- Never guarantee investment returns.
- Never claim certainty about future market movements.
- Clearly distinguish educational information from professional
  financial advice.

IMPORTANT TOOL RULE:

Use get_market_intelligence when the user asks for things such as:

- current market intelligence
- recent market information
- current stock analysis
- latest information about a stock
- market outlook for a specific stock
- analysis that requires current market data

For general educational questions such as:

"What is diversification?"

"What is a mutual fund?"

"What is a SIP?"

"What is asset allocation?"

you normally do NOT need the market intelligence tool.

When using market intelligence, base your answer on the tool
result rather than inventing data.

Never guarantee profit or investment returns.
`;

  // ==========================================================
  // FIRST GEMINI REQUEST
  // ==========================================================

  const contents: any[] = [
    {
      role: "user",

      parts: [
        {
          text:
            `${systemInstruction}\n\n` +
            `User question:\n${message}`,
        },
      ],
    },
  ];

  const configOptions = {
    tools: [
      {
        functionDeclarations: [
          marketIntelligenceTool,
        ],
      },
    ],
  };

  console.log("");
  console.log(
    "=================================",
  );

  console.log(
    "ONEVEST AI REQUEST",
  );

  console.log(
    "User:",
    message,
  );

  console.log(
    "=================================",
  );

  const response =
    await ai.models.generateContent({
      model: "gemini-3.6-flash",

      contents,

      config: configOptions,
    });

  // ==========================================================
  // CHECK FOR TOOL CALL
  // ==========================================================

  const functionCalls =
    response.functionCalls ?? [];

  // ----------------------------------------------------------
  // NO TOOL NEEDED
  // ----------------------------------------------------------

  if (functionCalls.length === 0) {
    console.log(
      "AI answered without using a tool.",
    );

    return (
      response.text ??
      "I couldn't generate a response right now."
    );
  }

  // ==========================================================
  // EXECUTE TOOL CALLS
  // ==========================================================

  for (const functionCall of functionCalls) {

    console.log("");
    console.log(
      "AI requested tool:",
      functionCall.name,
    );

    console.log(
      "Arguments:",
      JSON.stringify(
        functionCall.args,
      ),
    );

    // --------------------------------------------------------
    // MARKET INTELLIGENCE
    // --------------------------------------------------------

    if (
      functionCall.name ===
      "get_market_intelligence"
    ) {

      const args =
        (functionCall.args ?? {}) as {
          symbol?: string;
        };

      const symbol =
        args.symbol;

      if (
        !symbol ||
        typeof symbol !== "string"
      ) {
        throw new Error(
          "Gemini requested market intelligence without a valid symbol.",
        );
      }

      // ------------------------------------------------------
      // EXECUTE THE ACTUAL TOOL
      // ------------------------------------------------------

      const result =
        await getMarketIntelligence(
          symbol,
        );

      console.log("");
      console.log(
        "Tool result received.",
      );

      console.log(
        JSON.stringify(
          result,
          null,
          2,
        ),
      );

      // ------------------------------------------------------
      // SEND TOOL RESULT BACK TO GEMINI
      // ------------------------------------------------------

      contents.push(
        response.candidates?.[0]?.content,
      );

      contents.push({
        role: "user",

        parts: [
          {
            functionResponse: {
              name:
                functionCall.name,

              response: {
                result,
              },

              id:
                functionCall.id,
            },
          },
        ],
      });

      // ------------------------------------------------------
      // FINAL GEMINI RESPONSE
      // ------------------------------------------------------

      const finalResponse =
        await ai.models.generateContent({
          model:
            "gemini-3.6-flash",

          contents,

          config:
            configOptions,
        });

      return (
        finalResponse.text ??
        "I received the market intelligence but couldn't generate the final explanation."
      );
    }
  }

  return (
    response.text ??
    "I couldn't generate a response right now."
  );
}