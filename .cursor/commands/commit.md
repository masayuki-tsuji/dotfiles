## 役割

ファイルの差分をコミットするもの

## 詳細

現状の差分に合ったconventional commitのメッセージを添えてcommitしてください。

コマンドは以下を利用してください。

```bash
git commit --no-verify -m <message>
```

## メッセージルール

1. feat, chore, fixなどのprefixを必ずつけること
2. コミットメッセージは英語で記載すること

## 禁止(Bad Case)

- `git reset`の使用は禁止
- `git rebase`の使用は禁止
