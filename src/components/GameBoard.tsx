import React from 'react'

const GameBoard: React.FC<{ gridData: number[]}> = ({ gridData }) => {
  console.log("gridData: ", gridData);

  let board = Array(4).fill(null).map(() => Array(4).fill(1))
  if (gridData) {
    let i = 0;
    board = Array(4).fill(null).map(() => Array(4).fill(0).
      map(() => gridData[i++]))
  }

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
          {/* {cellValue ? cellValue: ''} */}
          {cellValue ? `${cellValue}` : ''}
          </div>
        ))
      )}
    </div>
  )
}

export default GameBoard
