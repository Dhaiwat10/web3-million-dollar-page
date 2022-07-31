import Head from 'next/head';
import { useConnect } from 'wagmi';

import { Connect, Disconnect, SwitchNetwork } from '../components/wallet';
import { Greeter } from '../components/contract/Greeter';

import { useNetwork } from 'wagmi';
import { NETWORK_ID } from '@/config';
import { ConnectButton } from '@rainbow-me/rainbowkit';

export default function Home() {
  return (
    <div className={''}>
      <ConnectButton />
    </div>
  );
}
