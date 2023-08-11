import GameBoard from '../components/GameBoard'
import use2048Game from '../hooks/use2048Game'

export default function Home() {
  const { board, handleMove } = use2048Game()

  return (
    <div className="flex min-h-screen flex-col items-center justify-center bg-gray-100">
      <GameBoard board={board} />
      <div className="mt-4">
        <button onClick={() => handleMove('UP')} className="m-2 rounded bg-blue-500 px-4 py-2 text-white">
          UP
        </button>
        <div className="flex">
          <button onClick={() => handleMove('LEFT')} className="m-2 rounded bg-blue-500 px-4 py-2 text-white">
            LEFT
          </button>
          <button onClick={() => handleMove('RIGHT')} className="m-2 rounded bg-blue-500 px-4 py-2 text-white">
            RIGHT
          </button>
        </div>
        <button onClick={() => handleMove('DOWN')} className="m-2 rounded bg-blue-500 px-4 py-2 text-white">
          DOWN
        </button>
      </div>
    </div>
  )
}
