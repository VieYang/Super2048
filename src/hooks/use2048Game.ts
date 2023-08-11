import { useState, useCallback } from 'react'

const use2048Game = () => {
  const addRandomTile = (board: number[][]) => {
    const availableSlots = []
    for (let i = 0; i < 4; i++) {
      for (let j = 0; j < 4; j++) {
        if (board[i][j] === 0) {
          availableSlots.push({ i, j })
        }
      }
    }

    if (availableSlots.length) {
      const randomSlot = availableSlots[Math.floor(Math.random() * availableSlots.length)]
      board[randomSlot.i][randomSlot.j] = Math.random() < 0.9 ? 1 : 2
    }
  }

  const initializeBoard = (): number[][] => {
    const newBoard = Array(4)
      .fill(null)
      .map(() => Array(4).fill(0))
    addRandomTile(newBoard)
    addRandomTile(newBoard)
    return newBoard
  }

  const [board, setBoard] = useState<number[][]>(initializeBoard)

  const handleMove = useCallback(
    (direction: 'UP' | 'DOWN' | 'LEFT' | 'RIGHT') => {
      let newBoard = [...board]

      const slideRow = (row: number[]): [number[], boolean] => {
        let oldRow = [...row]
        let newRow = row.filter(val => val)
        while (newRow.length < 4) {
          newRow.push(0)
        }
        for (let i = 2; i >= 0; i--) {
          if (newRow[i] === newRow[i + 1] && newRow[i] !== 0) {
            newRow[i] *= 2
            newRow.splice(i + 1, 1)
            newRow.push(0)
          }
        }
        return [newRow, JSON.stringify(oldRow) !== JSON.stringify(newRow)]
      }

      let hasChanged = false
      switch (direction) {
        case 'LEFT':
          for (let i = 0; i < 4; i++) {
            let [newRow, rowChanged] = slideRow(newBoard[i])
            newBoard[i] = newRow
            hasChanged = hasChanged || rowChanged
          }
          break
        case 'RIGHT':
          for (let i = 0; i < 4; i++) {
            let [newRow, rowChanged] = slideRow(newBoard[i].reverse())
            newBoard[i] = newRow.reverse()
            hasChanged = hasChanged || rowChanged
          }
          break
        case 'UP':
          newBoard = rotateMatrixClockwise(newBoard)
          for (let i = 0; i < 4; i++) {
            let [newRow, rowChanged] = slideRow(newBoard[i])
            newBoard[i] = newRow
            hasChanged = hasChanged || rowChanged
          }
          newBoard = rotateMatrixCounterClockwise(newBoard)
          break
        case 'DOWN':
          newBoard = rotateMatrixCounterClockwise(newBoard)
          for (let i = 0; i < 4; i++) {
            let [newRow, rowChanged] = slideRow(newBoard[i])
            newBoard[i] = newRow
            hasChanged = hasChanged || rowChanged
          }
          newBoard = rotateMatrixClockwise(newBoard)
          break
      }

      if (hasChanged) {
        addRandomTile(newBoard)
        setBoard(newBoard)
      }
    },
    [board]
  )

  const slideAndCombineRow = (row: number[]): number[] => {
    let newRow = row.filter(val => val)
    while (newRow.length < 4) {
      newRow.push(0)
    }
    for (let i = 2; i >= 0; i--) {
      if (newRow[i] === newRow[i + 1] && newRow[i] !== 0) {
        newRow[i] *= 2
        newRow.splice(i + 1, 1)
        newRow.push(0)
      }
    }
    return newRow
  }

  const rotateMatrixClockwise = (matrix: number[][]): number[][] => {
    const result = []
    for (let col = 0; col < matrix.length; col++) {
      const newRow = []
      for (let row = matrix.length - 1; row >= 0; row--) {
        newRow.push(matrix[row][col])
      }
      result.push(newRow)
    }
    return result
  }

  const rotateMatrixCounterClockwise = (matrix: number[][]): number[][] => {
    const result = []
    for (let col = matrix.length - 1; col >= 0; col--) {
      const newRow = []
      for (let row = 0; row < matrix.length; row++) {
        newRow.push(matrix[row][col])
      }
      result.push(newRow)
    }
    return result
  }

  return {
    board,
    handleMove,
  }
}

export default use2048Game
