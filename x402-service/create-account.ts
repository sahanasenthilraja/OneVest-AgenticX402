import algosdk from "algosdk";

const account = algosdk.generateAccount();

const address = account.addr.toString();

console.log("=================================");
console.log("OneVest Service Account");
console.log("=================================");
console.log("Address:", address);
console.log("=================================");
console.log("SAVE THE MNEMONIC SECURELY.");
console.log("DO NOT COMMIT IT TO GIT.");
console.log("=================================");