# Initial public repository preparation

日付: 2026-10-02 (Asia/Tokyo)。ユーザーの指示に基づきPUBLICで作成。

Repository: [MiiGoto/reaction-wheel-pendulum](https://github.com/MiiGoto/reaction-wheel-pendulum)

- 認証済みCLIで同名repositoryが存在しないことを確認してから作成。
- visibility `PUBLIC` をCLI/APIで確認。local branchは `main`。
- `origin` は上記repositoryのHTTPS URL。credentialを含まない。
- GitHub CLIをchecksum検証したportable toolとしてrepository外に配置し、既存PATH/global Git設定は変更しない。
- Commit identityは公開GitHub usernameとnoreply email。個人メールを含めない。

## Pre-push review

`git status`、`git diff`、`git diff --staged`と全未公開commitのcontent/author metadataを確認。公開対象は本プロジェクト用に作成したMarkdown、gitignore、概念KiCad project/schematicのみ。

| Category | Result |
| --- | --- |
| API keys / tokens / passwords | signature/credential assignment検査と内容reviewで実credentialなし |
| SSH/private keys | key header検査・拡張子reviewでなし |
| Personal information | 個人メール・住所・電話・user home絶対path・raw Git設定なし |
| Machine-specific secrets | credential store、認証ファイル、local tools、IDE workspace、raw環境ログを含めない |
| Private repository URLs | なし。外部リンクはST公式資料、KiCad schema、当repositoryの公開URL |
| Proprietary / unknown-license third-party files | なし。vendor PDF/SDK/HAL、installed templates、tool binariesを追跡していない |
| KiCad caches/backups/generated outputs | gitignoreで除外し、代表pathのcheck-ignoreも確認 |
| Primary KiCad files | `.kicad_pro` と `.kicad_sch` を追跡 |

自動pattern検査は手動内容reviewの補助であり、未知のsecretを必ず発見する保証ではない。pushに含む全commitを検査し、検出があれば公開を止める。

pushはforceを使用せず `main` の通常pushのみ。完了時にremote `refs/heads/main` とlocal HEADの一致、upstream追跡、cleanなworking treeを確認する。後続変更も同じ公開前検査を行う。

## Scope at initial publication

環境調査、要求・前提・architecture・I/O需要表・電源tree・bring-up計画、KiCad概念初期化まで。実回路・PCB・firmware executable・simulation結果は未作成。ERCの範囲と公式資料確認の限界は `validation.md`、`sources.md` に記録。
