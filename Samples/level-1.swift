// 標準入力から現在の Board を読み込み
let board: Board = .boardFromStdin()

// ランダムに手を選択
let move = board.validMoves(for: .dark).randomElement()!

// 選んだ手を出力
print(move.x, move.y)





// ===== 以下ライブラリ =====
enum Disk: Hashable {
    case dark
    case light
}

extension Disk {
    static var sides: [Disk] {
        [.dark, .light]
    }
    
    var flipped: Disk {
        switch self {
        case .dark: return .light
        case .light: return .dark
        }
    }
    
    mutating func flip() {
        self = flipped
    }
    
    static func random() -> Disk {
        Bool.random() ? .dark : .light
    }
    
    var symbol: String {
        switch self {
        case .dark:
            return "x"
        case .light:
            return "o"
        }
    }
}

struct Board {
    let width: Int
    let height: Int
    private var disks: [Disk?]
    
    init(width: Int, height: Int, disks: [Disk?]? = nil) {
        precondition(width >= 2, "`width` must be >= 2: \(width)")
        precondition(height >= 2, "`height` must be >= 2: \(height)")
        precondition(width.isMultiple(of: 2), "`width` must be an even number: \(width)")
        precondition(height.isMultiple(of: 2), "`height` must be an even number: \(height)")

        self.width = width
        self.height = height
        if let disks = disks {
            precondition(disks.count == width * height, "`disks.count` must be equal to `width * height`: disks.count = \(disks.count), width = \(width), height = \(height)")
            self.disks = disks
        } else {
            self.disks = [Disk?](repeating: nil, count: width * height)
            reset()
        }
    }
    
    private func diskIndexAt(x: Int, y: Int) -> Int? {
        guard xRange.contains(x) && yRange.contains(y) else { return nil }
        return y * width + x
    }
    
    subscript(x: Int, y: Int) -> Disk? {
        get { diskIndexAt(x: x, y: y).flatMap { i in disks[i] } }
        set {
            guard let index = diskIndexAt(x: x, y: y) else {
                preconditionFailure() // FIXME: Add a message.
            }
            disks[index] = newValue
        }
    }
}

extension Board {
    var xRange: Range<Int> {
        0 ..< width
    }
    var yRange: Range<Int> {
        0 ..< height
    }
    
    mutating func reset() {
        for y in  yRange {
            for x in xRange {
                self[x, y] = nil
            }
        }
        
        self[width / 2 - 1, height / 2 - 1] = .light
        self[width / 2,     height / 2 - 1] = .dark
        self[width / 2 - 1, height / 2    ] = .dark
        self[width / 2,     height / 2    ] = .light
    }
    
    func count(of disk: Disk) -> Int {
        return disks.lazy.filter { $0 == disk }.count
    }
    
    func sideWithMoreDisks() -> Disk? {
        let darkCount = count(of: .dark)
        let lightCount = count(of: .light)
        if darkCount == lightCount {
            return nil
        } else {
            return darkCount > lightCount ? .dark : .light
        }
    }
    
    func flipped() -> Board {
        var flipped = self
        flipped.flip()
        return flipped
    }
    
    mutating func flip() {
        for index in disks.indices {
            disks[index]?.flip()
        }
    }
    
    private func flippedDiskCoordinatesByPlacingDisk(_ disk: Disk, atX x: Int, y: Int) -> [(Int, Int)] {
        let directions = [
            (x: -1, y: -1),
            (x:  0, y: -1),
            (x:  1, y: -1),
            (x:  1, y:  0),
            (x:  1, y:  1),
            (x:  0, y:  1),
            (x: -1, y:  0),
            (x: -1, y:  1),
        ]
        
        guard self[x, y] == nil else {
            return []
        }
        
        var diskCoordinates: [(Int, Int)] = []
        
        for direction in directions {
            var x = x
            var y = y
            
            var diskCoordinatesInLine: [(Int, Int)] = []
            flipping: while true {
                x += direction.x
                y += direction.y
                
                switch (disk, self[x, y]) { // Uses tuples to make patterns exhaustive
                case (.dark, .some(.dark)), (.light, .some(.light)):
                    diskCoordinates.append(contentsOf: diskCoordinatesInLine)
                    break flipping
                case (.dark, .some(.light)), (.light, .some(.dark)):
                    diskCoordinatesInLine.append((x, y))
                case (_, .none):
                    break flipping
                }
            }
        }
        
        return diskCoordinates
    }
    
    func canPlaceDisk(_ disk: Disk, atX x: Int, y: Int) -> Bool {
        !flippedDiskCoordinatesByPlacingDisk(disk, atX: x, y: y).isEmpty
    }
    
    func validMoves(for side: Disk) -> [(x: Int, y: Int)] {
        var coordinates: [(Int, Int)] = []
        
        for y in yRange {
            for x in xRange {
                if canPlaceDisk(side, atX: x, y: y) {
                    coordinates.append((x, y))
                }
            }
        }
        
        return coordinates
    }
    
    func hasValidMoves(for side: Disk) -> Bool {
        for y in yRange {
            for x in xRange {
                if canPlaceDisk(side, atX: x, y: y) {
                    return true
                }
            }
        }
        
        return false
    }

    mutating func place(_ disk: Disk, atX x: Int, y: Int) throws {
        let diskCoordinates = flippedDiskCoordinatesByPlacingDisk(disk, atX: x, y: y)
        if diskCoordinates.isEmpty {
            throw DiskPlacementError(disk: disk, x: x, y: y)
        }
        self[x, y] = disk
        for (x, y) in diskCoordinates {
            self[x, y] = disk
        }
    }
    
    struct DiskPlacementError: Error {
        let disk: Disk
        let x: Int
        let y: Int
        
        init(disk: Disk, x: Int, y: Int) {
            self.disk = disk
            self.x = x
            self.y = y
        }
    }
    
    init(_ board :String) {
        let lines = board.split(separator: "\n")
        let height = lines.count
        let width = lines.first?.count ?? 0
        
        var disks: [Disk?] = []
        for line in lines {
            precondition(line.count == width, "Illegal format: \(board)")
            for diskCharacter in line {
                switch diskCharacter {
                case "x":
                    disks.append(.dark)
                case "o":
                    disks.append(.light)
                case "-":
                    disks.append(nil)
                default:
                    preconditionFailure("Illegal character: \(diskCharacter)")
                }
            }
        }
        
        self.init(width: width, height: height, disks: disks)
    }
}

extension Board: CustomStringConvertible, CustomDebugStringConvertible {
    var description: String {
        var result: String = ""
        for y in yRange {
            if y > 0 {
                result.append("\n")
            }
            for x in xRange {
                result.append(self[x, y]?.symbol ?? "-")
            }
        }
        return result
    }
    
    var debugDescription: String {
        description
    }
}

extension Board {
    static func boardFromStdin() -> Board {
        var string = ""
        for _ in 0 ..< 8 {
            let line = readLine()!
            string.append(line)
            string.append("\n")
        }
        return Board(string)
    }
}
