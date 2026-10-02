# Local development environment survey

調査日: 2026-10-02 (Asia/Tokyo)。公開版にはユーザーホームの絶対パス、個人メール、認証情報、ローカル設定の原文を含めない。

| Item | Observed result | Action / limitation |
| --- | --- | --- |
| OS | Windows NT 10.0.26200.0、64-bit環境 | ローカルPowerShellで調査 |
| Git | 2.44.0.windows.1、Program Files/Git/cmd | 使用可能 |
| GitHub CLI | 当初PATH/標準配置に見つからず。公式portable版2.102.0を用意 | GitHub release checksumとSHA256一致。repository外のlocal toolsに保管 |
| gh authentication | 初期調査では未ログイン。その後MiiGotoでlogin成功、HTTPS/keyring | ユーザーが対話認証を完了。raw tokenは表示/公開しない。`publication.md`参照 |
| KiCad GUI | 10.0.6 (file metadata)、9.0系もinstalled | 10.0系を今回のprojectに使用 |
| kicad-cli | 10.0.6、9.0.4 | PATH未登録。絶対パスで実行し既存PATHを変更しない |
| KiCad installation | `C:/Program Files/KiCad/10.0/`、`C:/Program Files/KiCad/9.0/` | CLIは各 `bin/kicad-cli.exe` |
| STM32CubeIDE | 1.15.1、1.10.1のdirectoryが存在 | 1.15.1はINI/build IDとtoolchainを確認。実target build未実施 |
| ARM C/C++ compiler | GNU Tools for STM32 12.3.rel1、arm-none-eabi-gcc / g++ 12.3.1 | CubeIDE 1.15.1同梱。両version出力確認。PATH未登録 |
| STM32CubeProgrammer | standalone 2.17.0、CubeIDE同梱CLIも存在 | standalone CLIのversion出力確認。実機接続未実施 |
| Python (installed) | Program Files/Python39/python.exe: 3.9.10 | PATH未登録。numpy/scipy/matplotlib等はこの環境には未導入 |
| Python (Codex bundled runtime) | 3.12.14、numpy/Pillow/pypdf利用可能 | scipy/matplotlibは未導入。project venvは未作成 |
| Host C/C++ compiler | gcc/g++/clang/clはPATH上に見つからず | Visual Studio関連directoryあり。host build環境は未確定 |
| Hardware | Nucleo、B-G431B-ESC1はユーザー提示の評価候補 | 現物型番・revision・接続は未確認 |

## Existing Git configuration and preservation

- 作業親フォルダには初回commit前の `master` repositoryが存在し、remoteはなく、既存のtracked/untracked user filesはなかった。
- 指定名 `reaction-wheel-pendulum/` に独立したrepositoryを `git init -b main` で作成。親の `.git` は変更しない。
- 既存global設定にはuser identity、default branch master、autocrlf、Git Credential Manager等があった。値の原文や個人メールは公開しない。
- このprojectだけでpublic GitHub noreply identityと `core.autocrlf=false` を設定。global設定・PATHを変更しない。
- サンドボックスと実ユーザーのownership差によりGitの安全確認が発生した。各呼出しだけに `-c safe.directory=<project>` を付け、global例外を追加しない。
- サンドボックス内のKiCadはユーザー設定/registryへのアクセスエラーを表示したため、検証は通常ユーザー権限で行う。環境エラーをERC違反と混同しない。

## Next environment work

評価ボードを確定しCubeIDEでbuild・SWD接続を検証する。simulationには専用venvと必要な依存versionを用意する。今回、既存ツール更新・global設定変更・SDK導入は行っていない。
