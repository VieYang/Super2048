import React from 'react'

const GameBoard: React.FC<{ board: number[][] }> = ({ board }) => {
  if (!board) return null

  return (
    <div className="grid grid-cols-4 gap-4 rounded-xl bg-gray-300 p-4">
      {board.map((row, rowIndex) =>
        row.map((cellValue, cellIndex) => (
          <div
            key={`${rowIndex}-${cellIndex}`}
            className={`flex h-16 w-16 items-center justify-center rounded-lg ${
              cellValue ? 'bg-gray-500' : 'bg-gray-400'
            }`}
          >
            {cellValue ? cellValue : ''}
          </div>
        ))
      )}
    </div>
  )
}

export default GameBoard
