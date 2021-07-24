# swift-reversi-run

Swift で書かれたリバーシの AI を対戦させるためのプログラムです。

## 遊び方

### AI のコードを書く

まずは戦わせる AI のコードを書きます。

#### 入出力

AI のプログラムには標準入力で盤面が渡されます。盤面のフォーマットは次の通りです。

```
--------
--------
--------
---ox---
---xo---
--------
--------
--------
```

`x` は黒のディスクが、 `o` は白のディスクが置かれていることを表します。`-` は何も置かれていないセルです。

これを入力として手を考え、 AI のコードはどこにディスクを置くべきかを判断し、標準出力でディスクを置くセルの座標を返します。

```
3 2
```

座標は、左上が `0 0` 、右上が `7 0` 、右下が `7 7` です。

入力される盤面の値は、必ず自分が黒だとして与えられます。もし自分が白のときには盤面の黒・白をひっくり返して、自分が黒であるかのように変換された盤面が与えられます。そのため、自分が黒か白かによってロジックを変更する必要はなく、常に自分は黒という前提で AI のコードを書くことができます。

パスの場合は自動的にパスされるので、打てる手がない盤面が入力として渡されることはありません。

ディスクを置くことができないセルの座標を返した場合やプログラムがクラッシュした場合、出力のフォーマットが正しくない場合は、無条件に負けとなります。

#### コードの形式

1 ファイルの Swift ファイルである必要があります。 Swift Package Manager 等は利用することができません。ライブラリを利用する場合は、ファイルの中に当該 API のコードをコピーする必要があります。

#### リバーシライブラリ

リバーシのルールを実装するのは大変なので、コピー & ペーストで利用できるリバーシのライブラリを用意しています。

- [Samples/library.swift](Samples/library.swift)

以下、基本的な API を紹介します。

##### `Disk`

`Disk` はディスクを表す型で、 `.dark` が黒を、 `.light` が白を表します。 

```swift
enum Disk: Hashable {
    case dark
    case light
}
```

##### `Board`

`Board` はリバーシの盤を表す型です。

```swift
var board = Board(width: 8, height: 8)
```

上記の場合は幅 8 、高さ 8 の 64 マスのセルを持ちます。各セルは `Disk?` 型で表され、ディスクが置かれていない場合は `nil` となります。

`subscript` を使ってセルにアクセスすることができます。

```swift
let x: Int = 2
let y: Int = 3

let cell = board[x, y]
board[x, y] = .dark
```

盤上に置かれているディスクの枚数を数えるには `count` メソッドを使います。

```swift
let count: Int = board.count(of: dark)
```

今の局面で可能な手を `Array` で得るには `validMoves` メソッドを使います。 `validMoves` が返す手の中から一つを選べば、打つことのできないセルに打ってしまうことは起こりません。

```swift
let moves: [(x: Int, y: Int)] = board.validMoves(for: .dark)
```

標準入力から `Board` インスタンスを作るには `boardFromStdin` メソッドを使います。

```swift
let board: Board = .boardFromStdin()
```

##### サンプル

このライブラリを使えば簡単にリバーシの AI のプログラムを作ることができます。たとえば、今打てる手からランダムに一つを選んで打つプログラムのコードは次の通りです。

```swift
// 標準入力から現在の Board を読み込み
let board: Board = .boardFromStdin()

// ランダムに手を選択
let move = board.validMoves(for: .dark).randomElement()!

// 選んだ手を出力
print(move.x, move.y)
```

実際にはライブラリのコードもコピー & ペーストする必要があるため、コードの全体は次のようになります。

- [Samples/level-1.swift](Samples/level-1.swift)

### 実行方法

#### ビルド

リポジトリを `git clone` し、リポジトリのルートディレクトリで次のコマンドを実行して下さい。

```
swift build -c release
```

#### 実行

ビルドされた `swift-reversi-run` コマンドを使って、 AI のコード同士を対戦させることができます。  `swift-reversi-run` には次のように、対戦させる AI のコードのパスを渡します。

```
swift-reversi-run <ai-swift-file-1> <ai-swift-file-2>
```

`swift build -c release` でビルドした場合、 `.build/release/swift-reversi-run` にビルドされたバイナリが作られます。この場合、次のようにして実行することができます。

```
.build/release/swift-reversi-run path/to/ai1.swift path/to/ai2.swift
```

❗ `<ai-swift-file-1>` および `<ai-swift-file-2>` には任意のコードを渡すことが可能なため注意して下さい。必ず AI のコードが安全であることを確認してから実行して下さい。たとえば、 AI のコードに `~/.ssh` ディレクトリから秘密鍵を盗み出すような処理が含まれていたとしても実行されてしまいます。自分で書いた安全なコード以外は実行しないことを推奨します。 **`swift-reversi-run` を利用することを通して利用者が被ったいかなる損害についても、 `swift-reversi-run` の作者は一切の責任を負いません。**

## ライセンス

MIT
