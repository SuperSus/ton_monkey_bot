const TonWeb = require("tonweb");

async function main() {
  const args = process.argv.slice(2);
  console.log(args);

  const tonweb = new TonWeb(new TonWeb.HttpProvider("https://toncenter.com/api/v2/jsonRPC"));
  const address = new TonWeb.utils.Address('EQBXzXqo1PUb6dScSObhnLaU-9x6p0v_We7Aei9xfUaBxfzB')
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

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}
