# create-web3 boilerplate [![Version](https://img.shields.io/npm/v/create-web3)](https://www.npmjs.com/package/create-web3) [![Downloads](https://img.shields.io/npm/dm/create-web3)](https://www.npmjs.com/package/create-web3)

A boilerplate for starting a web3 project.

This boilerplate quickly creates a mono repo with 2 environments, a Next JS environment for front-end and a Hardhat environment for writing, testing and deploying contracts.

#Set the number of accounts to 15 and their balance to 300 ETH

anvil --accounts 15 --balance 300

#deploy

forge create --rpc-url <your_rpc_url> --private-key <your_private_key> src/MyContract.sol:MyContract

#test contract.t.sol with gas report, verbose logging

forge test --gas-report -vvvvv




## Quick Start Notes

1.  Run `npx create-web3` to start install
2.  Run `yarn` or `npm install` to install all the dependencies
3.  Once installation is complete, `cd` into your app's directory and run `yarn chain` or `npm run chain` to start a local hardhat environment
4.  Open another terminal and `cd` into your app's directory
5.  Run `yarn deploy` or `npm run deploy` to deploy the example contract locally
6.  Run `yarn dev` or `npm run dev` to start your Next dev environment

## Technologies

This project is built with the following open source libraries, frameworks and languages.
| Tech | Description |
| --------------------------------------------- | ------------------------------------------------------------------ |
| [Next.js](https://nextjs.org/) | React Framework |
| [Hardhat](https://hardhat.org/) | Ethereum development environment |
| [hardhat-deploy](https://www.npmjs.com/package/hardhat-deploy) | A Hardhat Plugin For Replicable Deployments And Easy Testing |
| [WAGMI](https://wagmi.sh/) | A set of React Hooks for Web3 |

## Documentation

Please visit [create-web3.xyz](https://create-web3.xyz) to view the full documentation.

## Issues

If you find a bug or would like to request a feature, please visit [ISSUES](https://github.com/e-roy/create-web3/issues)
