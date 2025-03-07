# Remove-JpCareerApp
通常削除できない日本キャリアアプリをまとめて消去することができます。（海外キャリアは未対応）

このスクリプトを実行するだけで簡単にクリーンなAndroid環境が作れます

ただしシステムアプリ等一部アプリは削除することができませんのでご注意ください…

## 削除対象となるアプリ
パッケージ名に`docomo`, `ntt`, `auone`, `rakuten`, `kddi`, `softbank`が含まれているアプリが対象となります

## 依存関係
`adb`コマンドが必要です。基本的にAndroid SDKを導入することで利用できます
Debian系GNU/Linux環境では`adb`パッケージを導入することでも利用できます:
```bash
sudo apt update
sudo apt install adb
```

## 実行する前に（免責事項）
アプリデータは完全に消去されるためキャリアからのサポートが受けられなくなる可能性があります。

このスクリプトを実行したことによる故障や損害について開発者は責任を負いかねます

## 実行の仕方
1. Android端末のUSBデバッグを有効にしパソコンへ接続します
2. パソコンのターミナルでappremove.shを実行します
   例: `bash appremove.sh`

   複数のAndroid端末が接続されている場合、対象となる端末を選ぶよう求められます。
   求められた場合、端末名(or シリアル番号 or IPアドレス)を入力してください

   (環境変数`DEVICE`をセットすることで対象となる端末を選ぶこともできます。例: `DEVICE=emulator-5554 ./appremove.sh`)
3. 表示されたアプリ一覧に問題がなければ「Y」を入力します

![実行サンプル](Docs/removeapp.png)
