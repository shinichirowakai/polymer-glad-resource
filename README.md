polymer-glad-resource
====

polymer-glad-resour は ajax request を 提供するメソッドをビヘイビアとして提供します。hogehoge

## Description

GladResourceUserBehavior を使用する場合は、
いくつかの宣言プロパティを設定してください。

宣言型プロパティを設定してください。

NAMESPACE

一意の命名を行います。
基本的にはModel名を設定してください。

- namespace:
    value: String

URL

エントリーポイント(ディレクトリ)のURLを設定してください。

- url
    value: String

PARAMS

パラメータを追加したい際にご利用ください。
基本的にデータ取得時の検索条件等になります。

- params: "Object"

META_KEY

同じエレメント使用する際にそれぞれ一意となる値を設定してください。
詳しくは、Polymer の iron-meta を参照してください。
一意となる値を入れてください。

- meta_key: String

RESOURCE_CLASS

レスポンスの値を格納するインスタンスのクラス名を設定してください。

- resource_class: Resource

## Usage

###  refetch([callback])

再度, ajax通信により値を取得してきます。

###  fetch([callback])

ajax通信により値を取得します。

### save

インスタンスがあればupdate、インスタンスが無ければpersistします。

### delete

ajax通信により値を削除します。

### set_instances

インスタンスをセットします。

### create

Classよりインスタンスを生成します。

