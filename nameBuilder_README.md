# nameBuilder
- 最終更新 2017/6/10
- nameBuilder_v1.ms 準拠


## スクリプト概要
- 選択したオブジェクトをリネーム
- 命名ルールに基づくリネーム処理


---

# 命名ルール
- __オブジェクト名__ _____ __Type__ _____ __Resolution__ _____ __Revision__
- セパレータはアンダーバー "_____" を使用
- Type, Resolution, Revision (管理文字列) は最大１個しか持てない（0 or 1）
- 管理文字列 + 整数　は管理文字列と判断 ( コピーしたオブジェクト対応 )
  - Type, Resolution の場合は 整数は削除
- 管理文字列に属さない文字列は、オブジェクト名文字列と判断
- オブジェクト名文字列は、管理文字列より前に配置 ( 是非を検証中 )

## Type管理文字列
__for Modeling__

| strings | Description
| - | - |
| Hpr | ヘルパー
| Root | ルート
| Mdl | 完成モデル
| Obj | 作業用モデル
| Guid | モデリング用ガイド
| Shape | ライン・シェイプ・パス

## Resolution管理文字列
- High
- Low

## Revision管理文字列
- Rev + ３桁の整数
  - ex. _Rev001_

---

## 内部処理
1. オブジェクトの名前を取得
- オブジェクト名をアンダーバ－ "_____" で区切り、単語に分ける。
- 区切った単語の種類を順にチェック
- チェック結果を __nameStr__ へ格納
  - 格納データは __#( 単語の順番 ( Integer ), 単語 ( Strings ) )__
- __nameStr__ を元にリネーム処理

---

## Struct : _nameStr_


| properties | Description
| - | - |
| baseName | 名前配列を格納<br>名前は複数保持可能なので、２重配列データ
| type | Type 管理文字列を格納
| res | Resolution 管理文字列を格納
| rev | Revision 管理文字列を格納<br> #( 位置 ( _Integer_ ), Revision ( _Integer_ ) )
| count | 単語数を格納 ( _Integer_ )


---

## Functions

| function | Input | Output | Description
| - | - | - | - |
| renameSelected |  | | 現在選択中の オブジェクトに対し __checkSentence__ を実行
| checkSentence | Node | nameStr | オブジェクトの名前を "_" で分割し、各単語に対し __checkWord__ を実行
| checkWord | Strings | Integer | 単語が 管理文字列かチェック<br> 正規表現を用いているので、 _findItem_ は未使用
| replaceStr | nameStr | nameStr | 指定した管理文字列を文字列に置換
| removeStr |  nameStr | nameStr |指定した管理文字列を _undefined_ に置換
| setDigit | Integer | Strings | 整数を指定した桁の文字列に変換
| buildNewName | nameStr | Strings | _nameStr_ から リネーム文字列を組み立てる
