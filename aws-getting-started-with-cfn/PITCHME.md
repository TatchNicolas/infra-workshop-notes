# AWS CloudFormationことはじめ

---

## アジェンダ

* CloudFormationとは
   * CloudFormationって何が嬉しいの?
   * 用語の整理
* 使ってみよう
   * IAMの設定
   * テンプレートを書いてみよう
   * マネジメントコンソールから
   * CLIから
   * パラメータ/組み込み関数を使ってみよう
* 参考文献

Note:
個別のリソースの書き方は触れません。
セッション内で扱うのは必要なプロパティが少なく説明しやすいため作成するリソースはS3に限定します

---

## CloudFormationとは

---

### CloudFormationって何が嬉しいの?

* AWSの各種リソースをコード(JSON/YAML)で定義できる=Infrastructure as Code
* リソースをまとめて作成/削除ができる
* 自動化: 再利用性/再現性が高い
   * もちろんSDK、CLI+シェルスクリプトでも同じようなことはできるが、パラメータ化や依存関係の解決が容易
* (今日はTerraformの話はナシで)

Note:
先日、AWS Summitで出会った方に聞いたところCFnはAWSの半分くらいの昨日しか実装されていないらしい
個人的には、細かいところで実装がなくてCLIやカスタムリソースをしかたなく使う経験もあったが大きくは困らなかった

---

### 用語の整理

* テンプレート: JSON/YAMLで書かれた定義のこと
* スタック: テンプレートを元に作成されるAWSリソース一式のこと
* 変更セット(Change Set): スタックを更新する前に、どのような変更が行われるかを確認できる。

Note:
テンプレートはYAMLベースで書きます(JSONのほうがよいケースがあるのか知りたい/Access Policy Languageがそのままかけるとか？)
テンプレートはクラス、スタックはオブジェクトと考えても良い？

---

## 使ってみよう

--- 

### IAMの設定

* 作れるリソースは実行者の権限により決まる
   * 例) EC2インスタンスを作りたいならその作成権限が必要
   * 例) スタックを更新/削除するなら、スタック内のリソースの更新/削除権限が必要
* または、CloudFormationにサービスロールとして実行時の権限を渡すことができる

Note:
更新の例:たとえば、EC2にElasticIPを当てたいならAllocateAddress/AssociateAddresの操作権限が必要

--- 

### テンプレートを書いてみよう

最も簡単なテンプレートの例

```
AWSTemplateFormatVersion: 2010-09-09
Description: IEEEEEEEE
Resources:
  Bucket:
    Type: AWS::S3::Bucket
    Properties:
      # S3のバケット名は全世界で一意でないといけないので、
      # コピペしても動かないよ/先にやられると私が困るよ
      BucketName: tatch-sample-bucket
```

--- 

### マネジメントコンソールから

* スタックの作成
   * テンプレートファイルの指定方法
      * ローカルファイルをS3にアップロード
         * cf-templat-xxxxxxxxxxxx-ap-northeast-1のようなバケットが作られる
      * すでにS3にあるファイルのURLを指定する
         * IAM/Bucket Policyで権限があれば、Static Website Hostingは必要なし

---

### マネジメントコンソールから

* スタックの更新
   * 直接更新する: Update Stack
   * Change Setを作ってから更新する
* スタックの削除

```
AWSTemplateFormatVersion: 2010-09-09
Description: IEEEEEEEE
Resources:
  Bucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: tatch-sample-bucket
  AnotherBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: tatch-sample-another-bucket
```


Note:
Switch to AWS Management Console, show the process

---

### CLIからスタックの作成/確認

```
# ローカルファイル 
aws cloudformation create-stack --template-body file://foo.yml --stack-name <スタック名>
# S3のURLを指定
aws cloudformation create-stack --template-url https://<bucket name>.s3.amazonaws.com/<object key> --stack-name bar

# スタック一覧の確認
aws cloudformation describe-stacks [--stack-name <スタック名で絞り込み>]
# 個人的によく使うコマンド
aws cloudformation describe-stacks|jq '.Stacks[]|[{name:.StackName, status:.StackStatus}]'
```

---

### CLIからスタックの更新/削除

```
# 直接更新する
aws cloudformation update-stack --template-url https://<bucket name>.s3.amazonaws.com/<object key> --stack-name bar

# Change Setを作ってから更新する
## Change Set作成
aws cloudformation create-change-set --template-url[body] <path or url to template> --stack-name bar --change-set-name
## Change Set確認
aws cloudformation describe-change-set --change-set-name <create-change-setで帰ってきたARN>
aws cloudformation describe-change-set --change-set-name <Change Setの名前> --stack-name <スタック名>
## Change Set実行
aws cloudformation execute-change-set --change-set-name <create-change-setで帰ってきたARN>
aws cloudformation execute-change-set --change-set-name <Change Setの名前> --stack-name <スタック名>

# スタックの削除
aws cloudformation delete-stack --stack-name <スタック名>
```

---

### パラメータ/組み込み関数を使ってみよう

* [サンプルテンプレート](https://github.com/TatchNicolas/infra-workshop/blob/master/aws-getting-started-with-cfn/s3-3.yml)
* `Parameters`をテンプレートで定義すると
   * マネジメントコンソールからの場合はパラメータ設定の画面が出る
   * CLIからは
      * `--parameters ParameterKey=hoge,ParameterValue=fuga` 
      * `--parameters file://some-param-file.json`

* 組み込み関数
   * 上記サンプルテンプレートで`!Ref`/`!Sub`と出てきたもの
   * 書き方は2種類ある: `Fn::GetAtt`(完全名) v. `!GetAtt`(省略形)
      * (Base64関数の中で別の関数を呼ぶ場合、少なくともひとつは完全名で書かないといけない)
         * 不正な例:`Base64 !Ref logical_ID`

---

### 参考資料

* 各リソースの書き方(GetAtt関数で取れる属性も各リソースのドキュメント中にあるよ)
   * https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-template-resource-type-ref.html
* Ref関数で取れる戻り値
   * https://docs.aws.amazon.com/ja_jp/AWSCloudFormation/latest/UserGuide/intrinsic-function-reference-ref.html#w2ab2c21c28c69c25
* 擬似パラメータ
   * https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/pseudo-parameter-reference.html
* とても良くまとまっているQiita記事
   * https://qiita.com/yasuhiroki/items/8463eed1c78123313a6f

Note:
前回の登壇で記事を紹介したら書いたご本人が参加者の中にいた...
