var Ejercicio3 = artifacts.require("Ejercicio3");

// Don't remove these lines
const fs = require('fs') // https://nodejs.dev/learn/the-nodejs-fs-module
const path = require("path") // https://nodejs.dev/learn/nodejs-file-paths
const Keccak = require('sha3'); // Install: https://www.npmjs.com/package/sha3
const yaml = require('js-yaml'); // Install: https://www.npmjs.com/package/js-yaml

// Variables
// TO DO 
const _name = 'UOC Token';
const _description = 'UOC Token Blockchain PAC2';
const _symbol = 'UOC';
const _proposer = 'silvia';
const _proposer_account = '0x94F07C98E8e66D4299EFbE544bdcCFFcFca1c791';
const _amount_of_issuance = 100000000000;
const _user_tokens = 10000;
const _trade_timer = 7200;
const _configuration_timer = 7200;

// Don't remove this line
const prose = yaml.load(fs.readFileSync(path.resolve(__dirname, 'contract_prose_template.yaml'), 'utf8'));

// Set contract parameters
function calculateProseHash(account) {
        // TO DO
        prose['name'] = _name
	prose['description'] = _description
	prose['symbol'] = _symbol
	prose['proposer'] = _proposer
	prose['proposer_account'] = _proposer_account
	prose['amount_of_issuance'] = _amount_of_issuance
	prose['user_tokens'] = _user_tokens
	prose['trade_timer'] = _trade_timer
	prose['configuration_timer'] = _configuration_timer

        // Don't remove these lines
        let yamlStr = yaml.dump(prose, { lineWidth: -1 });
        prose_hash = Keccak.Keccak(256).update(yamlStr).digest('hex');
        fs.writeFileSync(path.resolve(__dirname + '/../', 'contract_prose.yaml'), yaml.dump(prose, { lineWidth: -1 }));
        return "0x" + prose_hash;
}

async function performMigration(deployer, network, accounts) {
  await deployer.deploy(Ejercicio3, _name, _symbol, _amount_of_issuance, calculateProseHash(_proposer_account), _user_tokens, _trade_timer, _configuration_timer);
  fs.renameSync(path.resolve(__dirname + '/../contract_prose.yaml'), 'contract_prose_' + calculateProseHash(_proposer_account) + '.yaml'); 
}

module.exports = function(deployer, network, accounts) {
  deployer
    .then(() => performMigration(deployer, network, accounts))
    .catch(error => {
      console.log(error);
      process.exit(1);
    });
};
