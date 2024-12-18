import SwiftUI

let gridSize = 9

struct SudokuView: View {
    @ObservedObject var model: SudokuModel
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack {
            // Выбор сложности
            Picker("Выберите сложность", selection: $model.difficulty) {
                Text("Легкий").tag(Difficulty.easy)
                Text("Средний").tag(Difficulty.medium)
                Text("Сложный").tag(Difficulty.hard)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .frame(maxWidth: .infinity)
            .onChange(of: model.difficulty) { _ in
                model.generatePuzzle() // Перегенерируем вырезы при смене сложности
            }
            
            // Сетка 9x9
            GridView(model: model)
                .padding()
            
            // Кнопка для проверки решения
            Button(action: {
                if model.isValid() {
                    alertMessage = "Решение верное!"
                } else {
                    alertMessage = "Решение неверное!"
                }
                showAlert = true
            }) {
                Text("Проверить решение")
            }
            
            // Кнопка для вывода решения
            Button(action: {
                alertMessage = model.printSolution()
                showAlert = true
            }) {
                Text("Вывести решение")
            }

            // Кнопка для подсказки
            Button(action: {
                if let hint = model.getHint() {
                    alertMessage = "Подсказка: Строка \(hint.row + 1), Колонка \(hint.col + 1), Значение \(hint.value)"
                }
                showAlert = true
            }) {
                Text("Получить подсказку")
            }
            
            // Кнопка "Обновить"
            Button(action: {
                model.generateNewPuzzle()  // Генерация новой головоломки с новым решением
            }) {
                Text("Обновить")
            }
        }
        .frame(width: 400, height: 500)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Сообщение"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

struct GridView: View {
    @ObservedObject var model: SudokuModel
    
    var body: some View {
        VStack {
            ForEach(0..<gridSize, id: \.self) { row in
                HStack {
                    ForEach(0..<gridSize, id: \.self) { col in
                        TextField("", value: $model.grid[row][col], formatter: NumberFormatter())
                            .frame(width: 40, height: 40)
                            .padding(5)
                            .background(Color.white)
                            .border(Color.black)
                            .multilineTextAlignment(.center)
                            .aspectRatio(1, contentMode: .fit)
                            .foregroundColor(textColorForCell(row: row, col: col))
                            .padding(.trailing, (col % 3 == 2 && col != 8) ? 16 : 0)
                            .padding(.bottom, (row % 3 == 2 && row != 8) ? 16 : 0)
                    }
                }
            }
        }
    }
    
    // Метод для определения цвета текста
    private func textColorForCell(row: Int, col: Int) -> Color {
        let value = model.grid[row][col]
        return value != 0 ? .blue : .white // Если значение не 0, цвет текста синий
    }
}

@main
struct SudokuAPP: App {
    var body: some Scene {
        WindowGroup {
            SudokuView(model: SudokuModel())
                .frame(width: 900, height: 800)
        }
    }
}


