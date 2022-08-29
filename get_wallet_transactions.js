const TonWeb = require("tonweb");

async function main() {
  const [addressStr, apiKey] = process.argv.slice(2, 4);
  const address = new TonWeb.utils.Address(addressStr);
  const tonweb = new TonWeb(new TonWeb.HttpProvider('https://toncenter.com/api/v2/jsonRPC', { apiKey: apiKey }));

  const transactions = await tonweb.getTransactions(address);
  result = transactions.map((tx) => {
    const msgObject = tx.in_msg;
    const message = msgObject?.msg_data?.['@type'] == 'msg.dataText' ? msgObject?.message : null;
    const amount = msgObject?.value;
    const sourceAddress = tx.in_msg?.source?.account_address || tx.out_msgs[0]?.source || tx.in_msg?.source;

    return Object.freeze({ amount, message, sourceAddress });
  });
  console.log(JSON.stringify(result));
}

main();