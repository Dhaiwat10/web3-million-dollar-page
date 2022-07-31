import { UseContractConfig } from 'wagmi/dist/declarations/src/hooks/contracts/useContract';
import abiFile from './contracts/hardhat_contracts.json';

export const NETWORK_ID = 31337 as number;
export const NETWORK_NAME = 'localhost' as string;

export const contractConfig: UseContractConfig = {
  addressOrName: '0x5FbDB2315678afecb367f032d93F642f64180aa3',
  // @ts-expect-error
  contractInterface: abiFile[NETWORK_ID][0].contracts.MillionDollarNFT.abi,
};
