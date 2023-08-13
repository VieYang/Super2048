import styles from 'styles/Home.module.scss'
import { ThemeToggleList } from 'components/Theme'
import { useState } from 'react'
import {
  Address,
  // useNetwork,
  // useSwitchNetwork,
  useAccount,
  // useBalance,
  useContractRead,
  useContractWrite,
  usePrepareContractWrite,
} from 'wagmi'
import ConnectWallet from 'components/Connect/ConnectWallet'
// import { ConnectButton } from '@rainbow-me/rainbowkit'
// import { useConnectModal, useAccountModal, useChainModal } from '@rainbow-me/rainbowkit'
import { useSignMessage } from 'wagmi'

import Link from 'next/link'
import GameBoard from '../components/GameBoard'
import { app } from 'appConfig'
import { super2048Abi } from 'abis/super2048Abi'

export default function Home() {
  return (
    <div className={styles.container}>
      <Header />
      <Main />
      <Footer />
    </div>
  )
}

function Header() {
  return (
    <header className={styles.header}>
      <div className="items-left flex">{app.title}</div>

      <ConnectWallet />
    </header>
  )
}

function Main() {
  const { address, isConnected, connector } = useAccount()
  // const { chain, chains } = useNetwork()
  // const { isLoading: isNetworkLoading, pendingChainId, switchNetwork } = useSwitchNetwork()
  // const { data: balance, isLoading: isBalanceLoading } = useBalance({
  //   address: address,
  // })
  // const { openConnectModal } = useConnectModal()
  // const { openAccountModal } = useAccountModal()
  // const { openChainModal } = useChainModal()

  const contractAddress = process.env.NEXT_PUBLIC_CONTRACT_ADDRESS as Address;

  const { data: gridData, isLoading: gridIsLoading } = useContractRead({
    address: contractAddress,
    abi: super2048Abi,
    functionName: 'getGrid',
    args: [address],
    watch: true,
    staleTime: 3_000,
  })

  const isEmpty = () => {
    if (!gridData) return true
    let allZeros: boolean = (gridData as number[]).every(value => value == 0)
    // let allZeros: boolean = boardData.every(value => value === 0);
    if (allZeros) {
      return true
    }
    return false
  }

  const { config: startGameConfig } = usePrepareContractWrite({
    address: contractAddress,
    abi: super2048Abi,
    functionName: 'startGame',
  })
  const { write: startGameWrite } = useContractWrite(startGameConfig)

  // TODO: can't fix this
  const { config: moveUpConfig } = usePrepareContractWrite({
    address: contractAddress,
    abi: super2048Abi,
    functionName: 'move',
    args: [0],
    gas: 222_222,
  })
  const { write: moveUpWrite } = useContractWrite(moveUpConfig)

  const { config: moveDownConfig } = usePrepareContractWrite({
    address: contractAddress,
    abi: super2048Abi,
    functionName: 'move',
    args: [1],
    gas: 222_222,
  })
  const { write: moveDownWrite } = useContractWrite(moveDownConfig)

  const { config: moveLeftConfig } = usePrepareContractWrite({
    address: contractAddress,
    abi: super2048Abi,
    functionName: 'move',
    args: [2],
    gas: 222_222,
  })
  const { write: moveLeftWrite } = useContractWrite(moveLeftConfig)

  const { config: moveRightConfig } = usePrepareContractWrite({
    address: contractAddress,
    abi: super2048Abi,
    functionName: 'move',
    args: [3],
    gas: 222_222,
  })
  const { write: moveRightWrite } = useContractWrite(moveRightConfig)

  const canMint = () => {
    if (!gridData) return false;
    let i = 0;
    for (i = 0; i < 16; i++) {
      if (gridData[i] >= 2048) return true;
    }
    return false
  }

  const { config: mintConfig } = usePrepareContractWrite({
    address: contractAddress,
    abi: super2048Abi,
    functionName: 'mint',
  })
  const { write: mintWite } = useContractWrite(mintConfig)

  return (
    <main className={styles.main + ' space-y-6'}>
      <div className="flex flex-col items-center justify-center bg-gray-100">
        {isEmpty() ? (
          <div className="relative">
            <GameBoard gridData={gridData as number[]} />
            <div className="absolute inset-0 flex items-center justify-center bg-gray-500 opacity-50">
              <button
                onClick={() => {
                  isConnected ? startGameWrite?.() : ''
                }}
                className="rounded-full bg-blue-500 px-20 py-5 font-bold text-white hover:bg-blue-700"
              >
                Start Game
              </button>
              {/* <button onClick={() => startGame()} className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-5 px-20 rounded-full">Start Game</button> */}
            </div>
          </div>
        ) : (
          <GameBoard gridData={gridData as number[]} />
        )}
        {/* <GameBoard board={board}/> */}
        <div className="mt-4 flex items-center">
          <button onClick={() => moveLeftWrite?.()} className="m-2 rounded bg-blue-500 px-4 py-2 text-white">
            ⬅️
          </button>

          <div className="flex flex-col">
            <button onClick={() => moveUpWrite?.()} className="m-2 rounded bg-blue-500 px-4 py-2 text-white">
              ⬆️
            </button>
            <button onClick={() => moveDownWrite?.()} className="m-2 rounded bg-blue-500 px-4 py-2 text-white">
              ⬇️
            </button>
          </div>

          <button onClick={() => moveRightWrite?.()} className="m-2 rounded bg-blue-500 px-4 py-2 text-white">
            ➡️
          </button>
        </div>
        <div className="mt-4 flex items-center">
          {canMint() ? (
            <button onClick={() => mintWite?.()} className="m-2 rounded bg-yellow-500 px-10 py-2 text-white">
              Mint
            </button>
          ) : (
            <button disabled className="m-2 rounded bg-gray-500 px-10 py-2 text-white">
              Mint
            </button>
          )}
        </div>
      </div>
    </main>
  )
}

function SignMsg() {
  const [msg, setMsg] = useState('Dapp Starter')
  const { data, isError, isLoading, isSuccess, signMessage } = useSignMessage({
    message: msg,
  })
  const signMsg = () => {
    if (msg) {
      signMessage()
    }
  }

  return (
    <>
      <p>
        <input value={msg} onChange={e => setMsg(e.target.value)} className="rounded-lg p-1" />
        <button
          disabled={isLoading}
          onClick={() => signMsg()}
          className="ml-1 rounded-lg bg-blue-500 px-2 py-1 text-white transition-all duration-150 hover:scale-105"
        >
          Sign
        </button>
      </p>
      <p>
        {isSuccess && <span>Signature: {data}</span>}
        {isError && <span>Error signing message</span>}
      </p>
    </>
  )
}

function Footer() {
  return (
    <footer className={styles.footer}>
      <div>
        <ThemeToggleList />
      </div>
      <Link href="https://ethglobal.com/showcase/super2048-3hvmz">About</Link>
    </footer>
  )
}
