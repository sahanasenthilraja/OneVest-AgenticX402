import { config } from "dotenv";
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
// GROQ CONFIGURATION
// ============================================================

const GROQ_API_KEY = process.env.GROQ_API_KEY;

const GROQ_URL =
  "https://api.groq.com/openai/v1/chat/completions";

const GROQ_MODEL =
  "openai/gpt-oss-20b";

if (!GROQ_API_KEY) {
  throw new Error(
    "GROQ_API_KEY is missing from .env",
  );
}

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
// TYPES
// ============================================================

type ToolCall = {
  id: string;
  type: "function";
  function: {
    name: string;
    arguments: string;
  };
};

type GroqMessage = {
  role:
    | "system"
    | "user"
    | "assistant"
    | "tool";

  content?: string | null;

  tool_calls?: ToolCall[];

  tool_call_id?: string;
};

// ============================================================
// SYSTEM PROMPT
// ============================================================

const SYSTEM_PROMPT = `
You are OneVest AI, an intelligent personal finance assistant.

Your responsibilities:

- Help users understand investments.
- Explain financial concepts clearly.
- Explain diversification, risk and asset allocation.
- Analyze portfolio information when provided.
- Give useful educational financial insights.
- Use live market intelligence whenever current market
  information is required.
- Never invent current stock prices or market data.
- Never claim certainty about future market movements.
- Never guarantee investment returns.
- Clearly distinguish educational information from
  professional financial advice.
- Keep answers concise, clear and useful.
- Use Indian Rupees (INR) when the market data is in INR.

IMPORTANT MARKET RULE:

When the user asks about:
- current stock price
- current market conditions
- recent stock performance
- latest stock information
- current stock analysis
- market outlook
- risk of a particular stock
- momentum
- volatility
- premium market intelligence
- "should I buy/sell/hold" based on current data

you MUST use the get_market_intelligence tool.

Do not invent market data.

When the tool returns market intelligence, base your
answer on the returned data.

You may summarize:
- current price
- previous close
- change
- change percentage
- verdict
- confidence
- momentum
- volatility
- risk
- market summary
- risk radar
- scenarios
- watch items
- next best action
- thesis triggers

For general educational questions such as:
"What is diversification?"
"What is a mutual fund?"
"What is a SIP?"
"What is asset allocation?"

you normally do NOT need the market intelligence tool.

Never guarantee profit.
Never provide certainty about future prices.
`;

// ============================================================
// MARKET INTELLIGENCE TOOL
// ============================================================

const marketIntelligenceTool = {
  type: "function",

  function: {
    name: "get_market_intelligence",

    description:
      "Gets premium live market intelligence for a stock. " +
      "Use this for current stock prices, recent stock " +
      "performance, market analysis, risk, momentum, " +
      "volatility, outlook, or any question requiring " +
      "current market information.",

    parameters: {
      type: "object",

      properties: {
        symbol: {
          type: "string",

          description:
            "Stock ticker symbol. Examples: " +
            "TCS.NS, INFY.NS, RELIANCE.NS, " +
            "HDFCBANK.NS, AAPL, MSFT.",
        },
      },

      required: [
        "symbol",
      ],

      additionalProperties: false,
    },
  },
};

// ============================================================
// EXECUTE MARKET INTELLIGENCE TOOL
// ============================================================

async function getMarketIntelligence(
  symbol: string,
): Promise<unknown> {

  const normalizedSymbol =
    symbol
      .trim()
      .toUpperCase();

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
  // IMPORTANT:
  // This calls the existing Agent endpoint.
  //
  // That endpoint already performs:
  //
  // Agent :4020
  //      ↓
  // x402 payment
  //      ↓
  // x402 service :4021
  //      ↓
  // Yahoo Finance
  //      ↓
  // Alpha Vantage
  //      ↓
  // Premium intelligence
  // ----------------------------------------------------------

  const agentUrl =
    process.env.AGENT_PUBLIC_URL ||
    "http://localhost:4020";

  const url =
    `${agentUrl}/api/market-intelligence?symbol=` +
    encodeURIComponent(
      normalizedSymbol,
    );

  console.log(
    "Calling OneVest market intelligence:",
    url,
  );

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
      `Market intelligence request failed ` +
      `(${response.status}): ${body}`,
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
// GROQ REQUEST
// ============================================================

async function callGroq(
  messages: GroqMessage[],
  useTools = true,
): Promise<any> {

  const body: Record<string, unknown> = {
    model: GROQ_MODEL,

    messages,

    temperature: 0.2,

    max_tokens: 1800,
  };

  if (useTools) {
    body.tools = [
      marketIntelligenceTool,
    ];

    body.tool_choice = "auto";
  }

  for (
    let attempt = 1;
    attempt <= 3;
    attempt++
  ) {

    try {

      console.log(
        `Groq request attempt ${attempt}/3...`,
      );

      const response =
        await fetch(
          GROQ_URL,
          {
            method: "POST",

            headers: {
              "Content-Type":
                "application/json",

              Authorization:
                `Bearer ${GROQ_API_KEY}`,
            },

            body:
              JSON.stringify(body),
          },
        );

      console.log(
        "Groq HTTP status:",
        response.status,
      );

      const text =
        await response.text();

      if (!response.ok) {

        console.error(
          "Groq API error:",
          text,
        );

        if (
          response.status === 429 &&
          attempt < 3
        ) {
          await new Promise(
            (resolve) =>
              setTimeout(
                resolve,
                2000 * attempt,
              ),
          );

          continue;
        }

        throw new Error(
          `Groq request failed ` +
          `with HTTP ${response.status}: ${text}`,
        );
      }

      let json: any;

      try {
        json = JSON.parse(text);
      } catch {
        throw new Error(
          "Groq returned invalid JSON.",
        );
      }

      const message =
        json?.choices?.[0]?.message;

      if (!message) {
        throw new Error(
          "Groq returned no message.",
        );
      }

      return message;

    } catch (error) {

      console.error(
        `Groq attempt ${attempt} failed:`,
        error,
      );

      if (attempt >= 3) {
        throw error;
      }

      await new Promise(
        (resolve) =>
          setTimeout(
            resolve,
            1000 * attempt,
          ),
      );
    }
  }

  throw new Error(
    "Groq request failed.",
  );
}

// ============================================================
// ASK ONEVEST AI
// ============================================================

export async function askOneVestAI(
  message: string,
): Promise<string> {

  console.log("");
  console.log(
    "=================================",
  );

  console.log(
    "ONEVEST GROQ AI REQUEST",
  );

  console.log(
    "User:",
    message,
  );

  console.log(
    "Model:",
    GROQ_MODEL,
  );

  console.log(
    "=================================",
  );

  // ==========================================================
  // FIRST GROQ REQUEST
  // ==========================================================

  const messages: GroqMessage[] = [

    {
      role: "system",
      content: SYSTEM_PROMPT,
    },

    {
      role: "user",
      content: message,
    },

  ];

  const firstResponse =
    await callGroq(
      messages,
      true,
    );

  // ==========================================================
  // CHECK FOR TOOL CALLS
  // ==========================================================

  const toolCalls =
    firstResponse.tool_calls ?? [];

  // ==========================================================
  // NORMAL AI RESPONSE
  // ==========================================================

  if (
    toolCalls.length === 0
  ) {

    console.log(
      "Groq answered without market tool.",
    );

    return (
      firstResponse.content ||
      "I couldn't generate a response right now."
    );
  }

  // ==========================================================
  // ADD GROQ ASSISTANT MESSAGE
  // ==========================================================

  messages.push({
    role: "assistant",
    content:
      firstResponse.content ?? null,
    tool_calls:
      toolCalls,
  });

  // ==========================================================
  // EXECUTE TOOL CALLS
  // ==========================================================

  for (
    const toolCall of toolCalls
  ) {

    console.log("");
    console.log(
      "Groq requested tool:",
      toolCall.function.name,
    );

    console.log(
      "Arguments:",
      toolCall.function.arguments,
    );

    // --------------------------------------------------------
    // MARKET INTELLIGENCE
    // --------------------------------------------------------

    if (
      toolCall.function.name ===
      "get_market_intelligence"
    ) {

      let args: {
        symbol?: string;
      };

      try {

        args =
          JSON.parse(
            toolCall.function.arguments ||
            "{}",
          );

      } catch {

        throw new Error(
          "Groq returned invalid tool arguments.",
        );
      }

      const symbol =
        args.symbol;

      if (
        !symbol ||
        typeof symbol !== "string"
      ) {

        throw new Error(
          "Groq requested market intelligence " +
          "without a valid symbol.",
        );
      }

      // ------------------------------------------------------
      // CALL PREMIUM x402 MARKET INTELLIGENCE
      // ------------------------------------------------------

      const result =
        await getMarketIntelligence(
          symbol,
        );

      console.log("");
      console.log(
        "Premium market intelligence received.",
      );

      console.log(
        JSON.stringify(
          result,
          null,
          2,
        ),
      );

      // ------------------------------------------------------
      // RETURN TOOL RESULT TO GROQ
      // ------------------------------------------------------

      messages.push({
        role: "tool",

        tool_call_id:
          toolCall.id,

        content:
          JSON.stringify(
            result,
          ),
      });
    }
  }

  // ==========================================================
  // FINAL GROQ RESPONSE
  // ==========================================================

  const finalResponse =
    await callGroq(
      messages,
      false,
    );

  console.log(
    "Groq final response received.",
  );

  return (
    finalResponse.content ||
    "I received the market intelligence but couldn't generate the final explanation."
  );
}

// ============================================================
// EXPORTS
// ============================================================

export {
  GROQ_MODEL,
};