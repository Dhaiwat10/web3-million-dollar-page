import { contractConfig } from '@/config';
import { useAccount, useContractWrite, usePrepareContractWrite } from 'wagmi';

interface IPixelProps {
  tokenId: string | number;
}

export const Pixel = ({ tokenId }: IPixelProps) => {
  const { address } = useAccount();

  const { config, error } = usePrepareContractWrite({
    ...contractConfig,
    functionName: 'mint',
    args: [address, tokenId],
  });

  const { writeAsync } = useContractWrite(config);

  const mint = async () => {
    if (error) {
      console.error(error);
      return alert(error.message);
    }
    if (!writeAsync) {
      console.error('writeAsync is not defined');
      return alert('writeAsync is not defined');
    }
    const tx = await writeAsync();
    const res = await tx.wait();
    console.log(res);
  };

  return (
    <div className='flex flex-col'>
      <img src='#' className='w-[100px] h-[100px] bg-slate-600' />
      <button
        className='mt-2 bg-blue-700 text-white px-4 py-1 rounded w-fit'
        onClick={mint}
      >
        Mint Pixel
      </button>
    </div>
  );
};
