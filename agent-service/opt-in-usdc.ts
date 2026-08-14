import { config } from "dotenv";
import algosdk from "algosdk";

config();

console.log("Starting USDC opt-in...");

const mnemonic = process.env.AGENT_MNEMONIC;

if (!mnemonic) {
  throw new Error("AGENT_MNEMONIC is missing from .env");
}

const USDC_ASA_ID = 10458941;

const account = algosdk.mnemonicToSecretKey(mnemonic);

console.log("Agent address:", account.addr);

const algod = new algosdk.Algodv2(
  "",
  "https://testnet-api.algonode.cloud",
  ""
);

console.log("Getting transaction parameters...");

const params = await algod.getTransactionParams().do();

console.log("Creating opt-in transaction...");

const txn =
  algosdk.makeAssetTransferTxnWithSuggestedParamsFromObject({
    sender: account.addr,
    receiver: account.addr,
    amount: 0,
    assetIndex: USDC_ASA_ID,
    suggestedParams: params,
  });

console.log("Signing transaction...");

const signedTxn = txn.signTxn(account.sk);

console.log("Submitting transaction...");

const result = await algod
  .sendRawTransaction(signedTxn)
  .do();

console.log("Transaction ID:", result.txid);

console.log("Waiting for confirmation...");

const confirmation = await algosdk.waitForConfirmation(
  algod,
  result.txid,
  4
);

console.log(
  "Confirmed round:",
  confirmation.confirmedRound
);

console.log("USDC opt-in completed successfully!");