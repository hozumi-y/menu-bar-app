# Network Monitor

macOS 向けのメニューバー常駐型ネットワークモニターです。

現在のネットワーク状態（接続状況、グローバル IP、ローカル IP、プロキシ、VPN、DNS など）を、メニューバーからワンクリックで確認できることを目的として開発しています。

> [!NOTE]
> **このプロジェクトは個人開発中です。**
>
> 実際の業務（Web 制作・サーバー運用・ネットワーク確認）で利用することを目的に開発しています。
>
> 日々利用しながら改善・機能追加を行っているため、未実装の機能や仕様変更、不具合が含まれる可能性があります。

---

## アプリ概要

Network Monitor は、macOS のメニューバーに常駐し、現在のネットワーク状態を素早く確認・コピーできる軽量アプリです。

Web 制作やサーバー運用では、以下のような確認を行う機会が多くあります。

- IP 制限がかかっているサイトへの接続確認
- VPN 接続状態の確認
- プロキシ設定の確認
- グローバル IP アドレスの確認

これまではターミナルやシステム設定を開いて確認していましたが、「もっと簡単に確認できるツールが欲しい」と感じ、このアプリを開発しました。

メニューバーから現在のネットワーク情報をすぐ確認できることをコンセプトに、日々改善を続けています。

現在のバージョンは **v1.0.0（MVP）** です。

---

## 主な機能

- メニューバー常駐表示
- オンライン / オフライン状態の表示
- Wi-Fi / Ethernet / その他ネットワーク種別の表示
- グローバル IP アドレス取得
- ローカル IP アドレス取得
- システムプロキシ設定の取得
- VPN インターフェース検出
- DNS サーバー表示
- グローバル IP、ローカル IP、ネットワーク情報全体のコピー
- 手動更新
- Dock に表示されない常駐アプリ

---

## 動作環境

- macOS 13 Ventura 以降
- Xcode 15 以降推奨
- Swift 5.9 以降
- インターネット接続（グローバル IP 取得時）

---

## 使用技術

- Swift
- SwiftUI
- MenuBarExtra
- Network framework
- SystemConfiguration framework
- AppKit
- Swift Package Manager

---

## ディレクトリ構成

```text
NetworkMonitor
├── MenuBarNetworkMonitor.xcodeproj
├── Package.swift
├── README.md
└── Sources
    └── MenuBarNetworkMonitor
        ├── App
        │   └── NetworkMonitorApp.swift
        ├── Assets
        ├── Models
        │   ├── NetworkInfo.swift
        │   ├── ProxyInfo.swift
        │   └── VPNInfo.swift
        ├── Services
        │   ├── ClipboardService.swift
        │   ├── DNSInfoService.swift
        │   ├── IPAddressService.swift
        │   ├── NetworkInfoService.swift
        │   ├── ProxyInfoService.swift
        │   └── VPNInfoService.swift
        ├── ViewModels
        │   └── NetworkStatusViewModel.swift
        ├── Views
        │   ├── ActionButtonsView.swift
        │   ├── MenuBarView.swift
        │   ├── NetworkDetailRow.swift
        │   └── NetworkSummaryView.swift
        └── Info.plist
```

---

## インストール方法

### Xcode から起動

1. `MenuBarNetworkMonitor.xcodeproj` を開きます。
2. スキームで **Network Monitor** を選択します。
3. 実行先に **My Mac** を選択します。
4. **⌘R** または **Product > Run** を実行します。

起動すると Dock には表示されず、メニューバーへ常駐します。

### `.app` として利用する

通常の macOS アプリとして利用する場合は、以下の流れで `.app` を書き出してください。

```text
XcodeでArchive
↓
.appを書き出し
↓
Applicationsフォルダへ移動
↓
FinderまたはLaunchpadから起動
↓
メニューバーに常駐
```

未署名または開発者署名のアプリとして書き出した場合、初回起動時に macOS の Gatekeeper 警告が表示されることがあります。信頼できる自分のビルドであることを確認したうえで、Finder の右クリックメニューから `開く` を選択してください。

---

## ビルド方法

Debug 構成でビルドする場合は以下を実行します。

```bash
xcodebuild -project MenuBarNetworkMonitor.xcodeproj -scheme "Network Monitor" -configuration Debug build
```

Release 構成でビルドする場合は以下を実行します。

```bash
xcodebuild -project MenuBarNetworkMonitor.xcodeproj -scheme "Network Monitor" -configuration Release build
```

Swift Package Manager でビルドする場合は以下を実行します。

```bash
swift build
```

リリース構成でビルドする場合は以下を実行します。

```bash
swift build -c release
```

---

## 使い方

アプリを起動すると、メニューバーに現在のネットワーク状態が表示されます。

表示例:

- `🌐 Wi-Fi / 203.0.113.10`
- `🌐 Ethernet / 203.0.113.10`
- `🔒 VPN / 203.0.113.10`
- `🌐 Proxy / 203.0.113.10`
- `⚠️ Offline`

メニューバーをクリックすると、以下の情報を確認できます。

- 接続状態
- 接続方式
- グローバル IP
- ローカル IP
- プロキシ情報
- VPN 情報
- DNS 情報
- 最終更新日時

また、以下のコピー操作も行えます。

- グローバル IP のコピー
- ローカル IP のコピー
- ネットワーク情報全体のコピー

アプリを終了する場合は、メニューバー項目をクリックし、詳細画面下部の `アプリを終了` ボタンを押してください。

### アプリの再起動

詳細画面下部の `アプリを再起動` ボタンを押すと、現在起動中の `.app` を新しいプロセスとして起動し、起動成功を確認してから現在のプロセスを終了します。起動に失敗した場合や、実行中のバンドルURLが `.app` を指していない場合は、現在のアプリを終了しません。

Xcode から **⌘R** で実行している場合は、実行環境やバンドルURLの状態によって再起動の挙動が不安定になることがあります。最終的な再起動動作は、Archive 後に書き出した `.app` を `/Applications` に配置し、Finder または Launchpad から起動した状態で確認してください。

---

## 権限について

このアプリでは以下を利用します。

- インターネットアクセス（グローバル IP 取得）
- システムネットワーク設定の読み取り
- クリップボードへの書き込み

管理者権限は不要です。

---

## 開発状況

🚧 **Active Development**

このプロジェクトは現在も開発を継続しています。

実際の業務で利用しながら改善を行っているため、仕様や UI は変更される場合があります。

個人開発のため、更新頻度は状況に応じて変わりますが、より使いやすいアプリを目指して継続的に開発を進めています。

---

## Roadmap

### v1.1

- [ ] 設定画面
- [ ] ログイン時の自動起動
- [ ] SSID 表示
- [ ] DNS 詳細表示

### v1.2

- [ ] Ping 測定
- [ ] 通信速度測定
- [ ] IPv6 アドレス表示
- [ ] IP アドレス変更履歴

### v2.0

- [ ] 通知機能
- [ ] ネットワーク診断
- [ ] メニューバー表示のカスタマイズ
- [ ] エクスポート機能

---

## 開発のきっかけ

Web 制作会社でサーバーやネットワーク周りの作業を行う中で、以下の情報を確認する機会が多くありました。

- 今どの IP アドレスで接続しているのか
- VPN は接続されているのか
- プロキシ設定は有効になっているのか

必要な情報を確認するために複数の画面を開く手間を減らし、「メニューバーからワンクリックで確認できるアプリ」を目指して開発しています。

---

## ライセンス

MIT License
