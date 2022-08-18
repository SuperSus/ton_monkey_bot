const tonMnemonic = require("tonweb-mnemonic");
const TonWeb = require("tonweb");

async function main() {
  // mnemonic to key pair
  const mnemonic = "rail sound peasant garment bounce trigger true abuse arctic gravity ribbon ocean absurd okay blue remove neck cash reflect sleep hen portion gossip arrow";
  const mnemonicArray = mnemonic.split(" ");
  const keyPair = await tonMnemonic.mnemonicToKeyPair(mnemonicArray);
  console.log("public key:", Buffer.from(keyPair.publicKey).toString('hex'));
  
  // list available wallet versions
  const tonweb = new TonWeb(new TonWeb.HttpProvider("https://toncenter.com/api/v2/jsonRPC"));
  console.log("wallet versions:", Object.keys(tonweb.wallet.all).toString());
  
  // instance of wallet V4 r2 (from the list printed above)
  const WalletClass = tonweb.wallet.all["v4R2"];
  const wallet = new WalletClass(tonweb.provider, { publicKey: keyPair.publicKey });
  const address = await wallet.getAddress();
  console.log("address:", address.toString(true, true, true));
  const seqno = await wallet.methods.seqno().call();
  console.log("seqno:", seqno);
  await sleep(1500); // avoid throttling by toncenter.com
  const balance = await tonweb.getBalance(address);
  console.log("balance:", TonWeb.utils.fromNano(balance));
}

main();

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}
