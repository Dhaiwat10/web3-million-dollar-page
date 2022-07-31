import { contractConfig } from '@/config';
import { useContractRead } from 'wagmi';

export const useImgURI = (tokenId: string | number) => {
  const res = useContractRead({
    ...contractConfig,
    functionName: 'tokenURI',
    args: [tokenId],
  });

  return res;
};
