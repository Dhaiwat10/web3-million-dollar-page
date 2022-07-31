import { useNetwork } from 'wagmi';
import { NETWORK_ID } from '@/config';
import { ConnectButton } from '@rainbow-me/rainbowkit';
import { Pixel } from '@/components/Pixel';
import { useMemo } from 'react';

export default function Home() {
  return (
    <div className='p-10'>
      <h1 className='font-bold text-3xl'>Million Dollar Homepage</h1>
      <ConnectButton />
      <div className='grid grid-cols-4 gap-4'>
        <Pixel tokenId='1' />
        <Pixel tokenId='2' />
        <Pixel tokenId='3' />
        <Pixel tokenId='4' />
        <Pixel tokenId='5' />
      </div>
    </div>
  );
}
