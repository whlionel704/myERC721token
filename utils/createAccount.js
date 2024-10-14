const web3 = require('web3');
const account = web3.eth.accounts.create();
console.log(account.address);
console.log()