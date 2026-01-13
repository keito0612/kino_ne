# kino-ne (キノネ) 🌳

**kino-ne** は、日々の記録をシンプルに残せるメモアプリです。
最大の特徴は、メモを書くたびにアプリ内の「森」が少しずつ豊かになっていくこと。
あなたの思考や記録が、視覚的な彩りとなって積み重なっていきます。



## ✨ 主な機能

- **シンプル・メモ**: 無駄を削ぎ落としたインターフェースで、素早く日々の出来事を記録できます。
- **森の成長システム**: メモの投稿や継続に応じて、ホーム画面の森林が少しずつ成長します。記録の積み重ねを直感的に感じることができます。
- **セキュアな保管**: パスコードロック機能を搭載。大切なメモを他人に覗かれる心配はありません。
- **iCloud 同期 & バックアップ**: iCloud連携により、複数のiOSデバイス間でのデータ同期や、万が一の際のデータ復旧が簡単に行えます。
- **完全ローカル管理**: SQLiteを使用し、データは基本的にデバイス内に保存されるため、オフラインでも軽快に動作します。

## 🛠 技術スタック

- **Framework**: [Flutter](https://flutter.dev/)
- **State Management**: [Riverpod (hooks_riverpod)](https://riverpod.dev/)
- **Database**: [sqflite](https://pub.dev/packages/sqflite) (SQLite)
- **Cloud Storage**: [CloudKit / iCloud](https://developer.apple.com/icloud/)
- **Security**: [flutter_screen_lock](https://pub.dev/packages/flutter_screen_lock)
- **Architecture**: MVVM + Repository

## 📖 使い方

1. **記録する**: 日々の気づきや日記をメモとして残します。
2. **振り返る**: 過去のメモをリストで確認できます。
3. **育つ**: メモが増えるにつれ、アプリの背景にある「森」が賑やかになっていく変化を楽しめます。

