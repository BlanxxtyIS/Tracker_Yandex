import UIKit

import UIKit

struct Box {
    let number: Int
    let height: Int
    let width: Int
    let length: Int
    let weight: Int
    let canRotate: Bool // Добавляем флаг для разрешения переворота
}

struct Shelf {
    let index: Int // Новый параметр - индекс полки
    let length: Int
    let width: Int
    let height: Int
    let maxWeight: Int
    var remainingSpace: (length: Int, width: Int, height: Int) // Оставшееся пространство на полке
    var currentWeight: Int // Текущий вес на полке
}

func sortBoxes(_ boxes: [Box]) -> [Box] {
    return boxes.sorted { $0.height * $0.width * $0.length > $1.height * $1.width * $1.lenght }
}

let boxes = [
    Box(number: 0, height: 5, width: 5, length: 5, weight: 5, canRotate: false),
    Box(number: 1, height: 5, width: 5, length: 10, weight: 5, canRotate: false),
    Box(number: 2, height: 10, width: 5, length: 5, weight: 5, canRotate: true),
]

let sortedBox = sortBoxes(boxes)
print(sortedBox)

func distributeBoxes(_ boxes: [Box], shelves: [Shelf]) -> [Shelf] {
    var dp: [[[Int]]] = Array(repeating: Array(repeating: Array(repeating: 0, count: 100), count: 100), count: 100)
    
    func recursiveDistribute(_ boxIndex: Int, _ shelfIndex: Int, _ remainingSpace: (length: Int, width: Int, height: Int), _ currentWeight: Int) -> Int {
        if boxIndex == boxes.count || shelfIndex == shelves.count {
            return 0
        }
        
        if dp[boxIndex][shelfIndex][currentWeight] != 0 {
            return dp[boxIndex][shelfIndex][currentWeight]
        }
        
        var result = recursiveDistribute(boxIndex + 1, shelfIndex, shelves[shelfIndex].remainingSpace, currentWeight)
        
        if boxes[boxIndex].height <= remainingSpace.height &&
           boxes[boxIndex].width <= remainingSpace.width &&
           boxes[boxIndex].length <= remainingSpace.length &&
           boxes[boxIndex].weight + currentWeight <= shelves[shelfIndex].maxWeight {
            
            let newRemainingSpace = (
                length: remainingSpace.length - boxes[boxIndex].length,
                width: remainingSpace.width - boxes[boxIndex].width,
                height: remainingSpace.height - boxes[boxIndex].height
            )
            
            let newCurrentWeight = currentWeight + boxes[boxIndex].weight
            
            let withCurrentBox = 1 + recursiveDistribute(boxIndex + 1, shelfIndex, newRemainingSpace, newCurrentWeight)
            let withoutCurrentBox = recursiveDistribute(boxIndex + 1, shelfIndex, shelves[shelfIndex].remainingSpace, currentWeight)
            
            result = max(withCurrentBox, withoutCurrentBox)
        }
        
        dp[boxIndex][shelfIndex][currentWeight] = result
        return result
    }
    
    for i in 0..<shelves.count {
        dp[boxes.count][i][0] = 0
    }
    
    let totalBoxes = recursiveDistribute(0, 0, shelves[0].remainingSpace, 0)
    
    print("Total boxes that fit on shelves: \(totalBoxes)")
    
    return shelves
}

let shelves = [
    Shelf(index: 0, length: 15, width: 10, height: 10, maxWeight: 20, remainingSpace: (length: 15, width: 10, height: 10), currentWeight: 0),
    Shelf(index: 1, length: 10, width: 10, height: 5, maxWeight: 15, remainingSpace: (length: 10, width: 10, height: 5), currentWeight: 0)
]

let shelvesWithBoxes = distributeBoxes(sortedBox, shelves: shelves)
print(shelvesWithBoxes)
