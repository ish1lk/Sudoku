import SwiftUI
import Foundation

enum Difficulty {
    case easy, medium, hard
}

class SudokuModel: ObservableObject {
    @Published var grid: [[Int]] // Текущая головоломка с вырезами
    @Published var difficulty: Difficulty // Уровень сложности
    private var solution: [[Int]] // Решение (постоянное)
    
    private var savedEmptyCells: [Difficulty: [(Int, Int)]] = [
        .easy: [],
        .medium: [],
        .hard: []
    ]
    
    // Инициализация с установкой сложности
    init(difficulty: Difficulty = .medium) {
        self.difficulty = difficulty
        self.grid = Array(repeating: Array(repeating: 0, count: 9), count: 9)
        self.solution = Array(repeating: Array(repeating: 0, count: 9), count: 9)
        generateSolvedGrid() // Генерация решения
        generatePuzzle() // Генерация головоломки с вырезами
    }
    
    // Генерация базового решённого судоку
    private func generateSolvedGrid() {
        var solvedGrid = Array(repeating: Array(repeating: 0, count: 9), count: 9)
        fillGrid(&solvedGrid)
        self.solution = solvedGrid
    }
    
    // Рекурсивная функция для заполнения сетки случайными числами
    private func fillGrid(_ grid: inout [[Int]]) -> Bool {
        for row in 0..<9 {
            for col in 0..<9 {
                if grid[row][col] == 0 {
                    let availableNumbers = getAvailableNumbers(row: row, col: col, grid: grid)
                    for num in availableNumbers.shuffled() {
                        grid[row][col] = num
                        if fillGrid(&grid) {
                            return true
                        }
                        grid[row][col] = 0
                    }
                    return false
                }
            }
        }
        return true
    }

    // Получение доступных чисел для данной клетки
    private func getAvailableNumbers(row: Int, col: Int, grid: [[Int]]) -> [Int] {
        var availableNumbers = Set(1...9)

        for i in 0..<9 {
            availableNumbers.remove(grid[row][i])
            availableNumbers.remove(grid[i][col])
        }

        let startRow = (row / 3) * 3
        let startCol = (col / 3) * 3
        for i in startRow..<startRow+3 {
            for j in startCol..<startCol+3 {
                availableNumbers.remove(grid[i][j])
            }
        }

        return Array(availableNumbers)
    }

    // Генерация головоломки с вырезами в зависимости от уровня сложности
    // Генерация головоломки с вырезами в зависимости от уровня сложности
    func generatePuzzle() {
        // Инициализация новой сетки из решения
        var newGrid = solution
        
        // Проверка, есть ли уже сохранённые пустые клетки для текущего уровня сложности
        if savedEmptyCells[difficulty]?.isEmpty == true {
            // Определяем количество пустых клеток в зависимости от сложности
            let difficultyLevel: Int
            switch difficulty {
            case .easy:
                difficultyLevel = 30  // Легкий: меньше пустых клеток
            case .medium:
                difficultyLevel = 45  // Средний: умеренное количество пустых клеток
            case .hard:
                difficultyLevel = 55  // Сложный: больше пустых клеток
            }
            
            // Заполняем список всех клеток
            var emptyCells: [(Int, Int)] = []
            for row in 0..<9 {
                for col in 0..<9 {
                    emptyCells.append((row, col))
                }
            }
            
            emptyCells.shuffle() // Перемешиваем список клеток для случайного выбора
            
            // Сохраняем пустые клетки для данного уровня сложности
            savedEmptyCells[difficulty] = Array(emptyCells.prefix(difficultyLevel))
        }
        
        // Убираем числа из сетки для создания головоломки
        if let emptyCells = savedEmptyCells[difficulty] {
            for (row, col) in emptyCells {
                newGrid[row][col] = 0 // Убираем число
            }
        }
        
        // Обновляем сетку
        self.grid = newGrid
    }

    // Метод для генерации новой головоломки при смене сложности
    func refreshPuzzle() {
        generatePuzzle() // Перегенерируем головоломку с вырезами для нового уровня сложности
    }

    // Подсказка, возвращающая число для клетки
    func getHint() -> (row: Int, col: Int, value: Int)? {
        for row in 0..<9 {
            for col in 0..<9 {
                if grid[row][col] == 0 {
                    return (row, col, solution[row][col])
                }
            }
        }
        return nil
    }

    // Проверка правильности решения
    func isValid() -> Bool {
        for row in 0..<9 {
            for col in 0..<9 {
                if grid[row][col] != 0 && grid[row][col] != solution[row][col] {
                    return false
                }
            }
        }
        return true
    }

    // Печать решения судоку в консоль
    func printSolution() -> String {
        var result = "Решение судоку:\n"
        for row in 0..<9 {
            let line = solution[row].map { "\($0)" }.joined(separator: " ")
            result += line + "\n"
        }
        return result
    }
    
    // Новый метод для генерации нового судоку с вырезами и случайным распределением пустых клеток
    func generateNewPuzzle() {
        // Генерация нового решённого судоку
        generateSolvedGrid()
        
        // Генерация новой головоломки с вырезами для текущего уровня сложности
        var newGrid = solution  // Копируем решенное судоку
        
        // Определяем количество пустых клеток в зависимости от сложности
        let difficultyLevel: Int
        switch difficulty {
        case .easy:
            difficultyLevel = 30  // Легкий: меньше пустых клеток
        case .medium:
            difficultyLevel = 45  // Средний: умеренное количество пустых клеток
        case .hard:
            difficultyLevel = 55  // Сложный: больше пустых клеток
        }
        
        // Создаем список всех клеток
        var emptyCells: [(Int, Int)] = []
        for row in 0..<9 {
            for col in 0..<9 {
                emptyCells.append((row, col))
            }
        }
        
        // Перемешиваем список клеток для случайного выбора
        emptyCells.shuffle()
        
        // Очищаем клетки для генерации пустых клеток
        for i in 0..<difficultyLevel {
            let (row, col) = emptyCells[i]
            newGrid[row][col] = 0  // Убираем число
        }
        
        // Обновляем сетку
        self.grid = newGrid
    }

}



