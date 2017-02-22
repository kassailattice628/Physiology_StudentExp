# Quick NI-DAQ recording on MATLAB
NIDAQ (例えば USB6009) を使用して GUI つき簡易記録．

ーーー
## Requirement
1. Windwos 7, 8 (64bit) で動作確認．  
2. MATLAB 64bit R2016 a, b で動作確認．  
3. Data acquisition toolbox (64bit) 必須．  
4. NIDAQ サポートパッケージ（MATLAB アドオンから入手）

### Instration Drivers
おそらく MATLAB R2016a 以降は，MATLAB のアドオン追加機能からドライバを入れた方が良い．  
（ホームタブメニュー > （環境）アドオン > ハードウェアサポートパッケージの入手）  
NI から最新版の NIDAQ-mxをインストールしても，機器が MATLAB を介して認識されない場合がある．

### DAQ devices
NIDAQ USB-6009．これはおそらくなんでも使える．  
NI デバイスモニタ など PC 上で認識されてるデバイス ID を MainRecDAQ の setDAQsession に書く必要あり．  
デフォルトは 'Dev2'.

### Input Channel
現在は，差動入力で Ch(1) しか設定していない（AI0)．  

---
## Usage
```MainRecDAQ.m
> cd ('path/to/program/folders/')
> MainRecDAQ
```
1. Live Plot が自動でスタート．Live 止めるときは，Pause ボタン．Live 再開は，Start ボタン．  
Lie Plot は現在の入力を見ているだけで，記録はしてない．  

2. データを記録する場合は，Capture．  
Capture を押すと 域値を超える入力がくるまで待機．域値の設定は，Pause 中に Trigger Level で編集．  
取得データの範囲（時間）は，Trigger の前後数秒． 設定は，Pause 中に Capture Pre-Trig, Post-Trig で編集．  

3. Triger 入力されると，指定した時間文のデータが Varibale Name で指定した 変数で MATLAB の workspace に保存．  
複数回記録した場合は，データが追加．  
記録したデータを書きだすときは，GUI 左下の SaveVars ボタンを押す．  

### Others
Sampling Rate 及び，Live plot の範囲も，GUI から変更

---
### ToDos
- 記録開始の Trigger 設定を見直す． >>>> event.data を *1000 して mV 表示にした．  
- Trigger なしでも記録できるようにする． <<<< これはやらない？  
- Threshold, slope(はやめる？)． <<<< これも mV 表示で対応できた？  
 
- Sampling Rate の確認．（あってない？）．デフォルト 50K とかにするか >>>> USB6009 は max 48K なので 30K をデフォルトにした  

- AC 結合っぽく表示できないか？どうか？．  デジタルフィルタでなんとかなるのか？

