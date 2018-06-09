# 昼のNginx実践入門 by いちのせさん用環境

[インフラ勉強会Wiki](https://wiki.infra-workshop.tech/%E5%8B%89%E5%BC%B7%E4%BC%9A%E3%83%AD%E3%82%B0/2018/01/14/%E6%98%BC%E3%81%AENginx%E5%AE%9F%E8%B7%B5%E5%85%A5%E9%96%80)

上記勉強会で動かした環境を立ち上げるVagrantfile作りました。

※ ハンズオンおよびアプリ自体はいちのせさんによるものです。

以下の手順で動きます。

ホストマシン
```
vagrant up
vagrant ssh
```

ゲストマシン
```
cd nginx-sinatra
vim app.rb # APIキー発行して書き換えてください。そのままではNoMethodなエラーが出ます。
sudo nginx -s stop
sudo nginx
unicorn -c config/unicorn.rb
```

