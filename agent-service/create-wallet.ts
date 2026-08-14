import algosdk from "algosdk";

const account = algosdk.generateAccount();

const address = algosdk.encodeAddress(account.addr.publicKey);

console.log("=================================");
console.log("OneVest Agent Payer Account");
console.log("=================================");
console.log("Address:");
console.log(address);
console.log("=================================");
console.log("Mnemonic:");
console.log(algosdk.secretKeyToMnemonic(account.sk));
console.log("=================================");
console.log("SAVE THE MNEMONIC SECURELY.");
console.log("DO NOT COMMIT IT TO GIT.");
console.log("=================================");
