## 処理概要 
MedDRA、MedDRA/J、CTCAEの情報をマージし、その結果とllt_j.ascを突き合わせてllt_codeがマッチするレコードのみを抽出したllt_j2.ascファイルを出力する。  
MedDRA\Vxx.x\ASCII\配下に複数フォルダが存在した場合は処理を終了する。  

## プログラム実行前の事前準備  
### パッケージのインストール
未インストールの場合のみ、readxlのインストールが必要となるため下記の手順を実行する。  
プログラム2行目「# install.packages('readxl')」の文頭の#を消し、行選択してプログラムを実行する。  
インストール終了後は再度文頭に#を付与し、コメントアウトする。  
### CTCAEダウンロード
[ここからEXCELファイルをダウンロード](http://www.jcog.jp/doctor/tool/ctcaev4.html)して任意の場所に保存する。  
### MedDRAバージョン、入出力パスの設定
プログラム39行目「kVersion」を対象とするMedDRAのバージョンに書き換える。  
プログラム41行目「input_prt_path」をMedDRAフォルダのパスに書き換える。  
プログラム78行目「ctcae_path」をCTCAEフォルダのパスに書き換える。  
  
## 出力ファイル
### ファイル名
llt_j2.asc  
### スキーマ
llt_j.ascと同一である。  
## 入力ファイル
### ファイル名
- MedDRA
  - llt.asc  
  - pt.asc   
  - soc.asc  
  - mdhier.asc  
- MedDRA/J
  - llt_j.asc  
  - pt_j.asc  
  - soc_j.asc  
- CTCAE  
  - CTCAEv4J_20170912.xlsx  
    ("v4","20170912"の値はバージョン毎に異なる)  
### 処理中データフレームのフィールド名について
MedDRA,MedDRA/Jは元ファイルにフィールド名が存在しない。  
そのためフィールド名はdist_file_format_21_0_Japanese.docxの内容を参照して設定している。  
CTCAEの元ファイルはEXCEL形式であり、フィールド名に改行コードを含んでいる箇所があるためフィールド名を読み飛ばし、プログラム内で再設定している。  

## 処理詳細
### 処理対象レコードの抽出
- mdhier,lltは以下の条件のレコードのみ処理対象とする。  
    mdhier：primary_soc_fg="Y"のレコード  
    llt：llt_currency="Y"のレコード  
### llt日本語マージ  
- lltとctcaeのマージ処理  
    llt:llt_code, ctcae:B列をキーとしてマージする。  
    lltのレコードは全て出力する。  
- 上記処理後のlltとllt_jのマージ処理
    llt_codeをキーとしてマージする。lltのレコードは全て出力する。  
- 上記処理後のlltとmdhierのマージ処理
    pt_codeをキーとしてマージする。lltのレコードは全て出力する。  
### pt日本語マージ
- ptとpt_j,mdhierのマージ処理
    ptとpt_jをpt_codeをキーとしてマージし、その結果とmdhierをpt_codeでマージする。ptのレコードは全て出力する。  
### soc日本語マージ
- socとsoc_jをsoc_codeをキーとしてマージする。socのレコードは全て出力する。  
### llt,pt,socマージ
- 上記処理後のllt,ptをpt_codeをキーとしてマージし、その結果と上記処理後のsocをsoc_codeをキーとしてマージする。lltのレコードは全て出力する。  
- lltの日本語重複病名については下記の優先順位で英語：日本語を1:1にする。  
  1.CTCAEで採用されている日本語病名  
  2.llt_jのllt_jcurr="Y"の日本語病名  
### llt_j2.asc出力
- 上記処理後のデータとllt_j.ascの内容を比較し、llt_codeが等しい場合のみllt_j.ascのレコードを出力する。  
- llt_j.ascの形式と合わせるため、改行コードCrLf, 文字コードCP932にて出力する。  
