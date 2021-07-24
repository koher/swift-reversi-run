# swift-reversi-run

Swift で書かれたリバーシの AI を対戦させるためのプログラムです。

## ビルド

リポジトリを `git clone` し、リポジトリのルートディレクトリで次のコマンドを実行して下さい。

```
swift build -c release
```

## 実行

`swift-reversi-run` コマンドには次の形式で二つの引数を与えます。

```
swift-reversi-run <ai-swift-file-1> <ai-swift-file-2>
```

`swift build -c release` でビルドした場合、 `.build/release/swift-reversi-run` にビルドされたバイナリがあるので、次のようにして実行します。

```
.build/release/swift-reversi-run path/to/ai1.swift path/to/ai2.swift
```

❗ `<ai-swift-file-1>` および `<ai-swift-file-2>` には任意のコードを渡すことが可能なため注意して下さい。必ず AI のコードが安全であることを確認してから実行して下さい。たとえば、 AI のコードに `~/.ssh` ディレクトリから秘密鍵を盗み出すような処理が含まれていたとしても実行されてしまいます。自分で書いた安全なコード以外は実行しないことを推奨します。 **`swift-reversi-run` を利用することを通して利用者が被ったいかなる損害についても、 `swift-reversi-run` の作者は一切の責任を負いません。**

## ライセンス

MIT
