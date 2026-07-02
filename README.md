# Network Monitor

## アプリ概要

Network Monitor は、macOS のメニューバーに常駐し、現在のネットワーク状態をすばやく確認・コピーできる軽量アプリです。グローバル IP、ローカル IP、接続方式、プロキシ、VPN、DNS をひとつのメニューから確認できます。

本リリースは `v1.0.0` です。

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
- 手動更新ボタン
- Dock に表示されない常駐アプリ動作

## 動作環境

- macOS 13 Ventura 以降
- Xcode 15 以降推奨
- Swift 5.9 以降
- インターネット接続（グローバル IP 取得時）

## 使用技術

- Swift
- SwiftUI
- MenuBarExtra
- Network framework
- SystemConfiguration framework
- AppKit（クリップボード操作、アプリ終了、Dock 非表示制御）
- Swift Package Manager

## ディレクトリ構成

```text
NetworkMonitor
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

## ビルド方法

### Xcode でビルドする方法

1. Xcode を起動します。
2. `File`（ファイル） > `Open...`（開く）から、このリポジトリの `Package.swift` を開きます。
3. スキームで `MenuBarNetworkMonitor` を選択します。
4. 実行先に `My Mac` を選択します。
5. `Product`（製品） > `Build`（ビルド）を実行します。

### コマンドラインでビルドする方法

```bash
swift build
```

リリース構成でビルドする場合は以下を実行します。

```bash
swift build -c release
```

## 起動方法

### 初回起動方法

Xcode から起動する場合は、`Product`（製品） > `Run`（実行）を実行します。

コマンドラインから起動する場合は以下を実行します。

```bash
swift run MenuBarNetworkMonitor
```

リリースビルド済みバイナリを直接起動する場合は以下を実行します。

```bash
.build/release/MenuBarNetworkMonitor
```

### メニューバーへの表示方法

起動すると macOS のメニューバーにネットワーク状態が表示されます。表示例は以下です。

- `🌐 Wi-Fi / 203.0.113.10`
- `🌐 Ethernet / 203.0.113.10`
- `🔒 VPN / 203.0.113.10`
- `🌐 Proxy / 203.0.113.10`
- `⚠️ Offline`

メニューバー項目をクリックすると詳細画面が開き、各情報の確認・コピー・更新ができます。

### Dock に表示されない仕様

このアプリはメニューバー常駐アプリのため、Dock には表示されません。`LSUIElement` と起動時の accessory activation policy により、通常のウィンドウアプリではなく常駐アプリとして動作します。

### アプリ終了方法

メニューバー項目をクリックし、詳細画面下部の `アプリを終了` ボタンを押してください。

## 権限について

- ネットワークアクセス: グローバル IP アドレス取得のため、外部サービス（`api.ipify.org`、`ipv4.icanhazip.com`、`checkip.amazonaws.com`）へ HTTPS アクセスします。
- ローカルネットワーク: LAN 内の機器探索は行いません。通常は追加のローカルネットワーク権限を要求しません。
- システム設定読み取り: プロキシ設定、DNS 設定、ネットワークインターフェース情報を読み取ります。管理者権限は不要です。
- クリップボード: コピー機能で macOS の一般ペーストボードへ文字列を書き込みます。

## 動作確認項目

`v1.0.0` では以下の観点で確認します。

- アプリが起動すること
- メニューバーに状態が表示されること
- オンライン状態が表示されること
- オフライン状態が表示されること
- Wi-Fi 接続が表示されること
- Ethernet 接続が表示されること
- グローバル IP が取得できること
- ローカル IP が取得できること
- プロキシ状態が取得できること
- VPN 状態が取得できること
- コピー機能が動作すること
- 更新ボタンで再取得できること

## 今後追加予定の機能

- 設定画面の追加
- 更新間隔のカスタマイズ
- IPv6 アドレス表示
- 複数ネットワークインターフェースの詳細表示
- 通知機能（IP 変更、VPN 切断など）
- アプリ配布用の `.app` パッケージ化と署名手順の整備
- 自動起動設定

## リリース情報

- バージョン: `v1.0.0`
- リリース種別: MVP
- 目的: 日常利用できる macOS メニューバー常駐ネットワークモニター
