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

config();

const SERVICE_URL =
  process.env.X402_SERVICE_URL ||
  "http://localhost:4021";

const MNEMONIC = process.env.AGENT_MNEMONIC;

if (!MNEMONIC) {
  throw new Error("Missing AGENT_MNEMONIC in .env");
}

/*
 * Convert Algorand mnemonic → Base64 private key.
 *
 * toClientAvmSigner() expects:
 * 32-byte Ed25519 seed + 32-byte public key
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

async function main(): Promise<void> {
  console.log("=================================");
  console.log("OneVest x402 Agent");
  console.log("=================================");

  /*
   * Convert mnemonic → Base64 private key
   */
  const privateKeyBase64 =
    mnemonicToPrivateKeyBase64(MNEMONIC!);

  /*
   * Create Algorand x402 signer
   */
  const avmSigner =
    toClientAvmSigner(privateKeyBase64);

  console.log("Agent payer:", avmSigner.address);
  console.log("Target:", SERVICE_URL);

  /*
   * Create x402 client
   */
  const client = new x402Client();

  /*
   * Register Algorand TestNet
   */
  client.register(
    ALGORAND_TESTNET_CAIP2,
    new ExactAvmScheme(avmSigner)
  );

  /*
   * Wrap fetch with x402 payment handling.
   *
   * Flow:
   *   Request
   *      ↓
   *   HTTP 402
   *      ↓
   *   Read payment requirements
   *      ↓
   *   Create Algorand USDC payment
   *      ↓
   *   Sign transaction
   *      ↓
   *   Submit payment proof
   *      ↓
   *   Retry request
   *      ↓
   *   Receive market data
   */
  const fetchWithPayment =
    wrapFetchWithPayment(
      fetch,
      client
    );

  const url =
    `${SERVICE_URL}/api/market-intelligence?symbol=AAPL`;

  console.log("");
  console.log("Requesting market intelligence...");

  const response =
    await fetchWithPayment(
      url,
      {
        method: "GET",
      }
    );

  console.log("");
  console.log("HTTP status:", response.status);

  /*
   * Successful paid request
   */
  if (response.ok) {
    console.log("");
    console.log("Payment settled successfully.");

    /*
     * Read x402 settlement response
     */
    try {
      const paymentResponse =
        new x402HTTPClient(client)
          .getPaymentSettleResponse(
            (name) =>
              response.headers.get(name)
          );

      console.log("");
      console.log("Payment response:");
      console.log(
        JSON.stringify(
          paymentResponse,
          null,
          2
        )
      );
    } catch {
      console.log(
        "Payment settlement header was not returned."
      );
    }

    /*
     * Read actual OneVest market data
     */
    const data =
      await response.json();

    console.log("");
    console.log("Market intelligence:");
    console.log(
      JSON.stringify(
        data,
        null,
        2
      )
    );

    console.log("");
    console.log("=================================");
    console.log("x402 PAYMENT SUCCESSFUL!");
    console.log("=================================");
  } else {
    /*
     * Payment/request failed
     */
    const body =
      await response.text();

    console.log("");
    console.log("No payment settled.");
    console.log("Response:");
    console.log(body);
  }
}

main().catch((error) => {
  console.error("");
  console.error("Agent error:");
  console.error(error);

  process.exit(1);
});