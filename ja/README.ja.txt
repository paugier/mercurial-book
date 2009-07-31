===============================================================================
                             HGBOOK 翻訳
===============================================================================

本ディレクトリ配下に格納されている成果物は、以下の URL で公開されている
Bryan O'Sullivan 氏による "Mercurial: The Definitive Guide" の翻訳版です。

    http://hgbook.red-bean.com/

****
**** 注意
****

** 内容に関する注意

  - 翻訳ベースが 2007-06-17 時点の版なので、1.x 版以降となった現状の
    Mercurial にそぐわない内容が含まれています


** 翻訳内容に関する注意:

  - 翻訳水準を試行錯誤している頃だったので、「commit」を「確定」と訳す
    など、現状の Mercurial メッセージ翻訳の方針とは異なるものが含まれて
    います

    ※ 現状の Mercurial メッセージ翻訳方針の詳細に関しては、以下の日本
       語翻訳プロジェクトの成果物を参照してください

       http://bitbucket.org/foozy/mercurial-translation-ja/wiki/

  - 原著の以下の Appendix は翻訳版には含まれていません

    - Command reference
    - Mercurial Queues reference

  - 原著の以下の Appendix は未翻訳です

    - Open Publication License

  - 適切な訳ができなかった箇所には、"XXXX" マークと共に原文を併記してあ
    ります


** 翻訳成果に関する注意:

  - 本来は、実際にコマンドを実行した結果を文書に取り込むようになってい
    ますが:

      - 期待内容との差を検出した際に、実行結果生成が中断されてしまう

      - Mercurial の版を厳密に一致させないと、差分が検出されてしまう

      - コマンド自動実行が Win32 環境では上手く機能しない

    以上のことから、実行結果出力は別途提供するものを展開して使用するこ
    ととしています

    別途提供している実行結果出力は、比較的新しい Mercurial を使用して生
    成しているため、原著者の期待するものとは異なる可能性があります

  - 以下の理由から、翻訳結果ファイルの文字コードには iso-2022-jp を採用
    しています:

      - TeX の Unicode 化が実用的なのは Win32 環境(+ MacOS ?)のみ

      - Linux/Win32 環境の日本語化された TeX が、共に認識可能な文字コー
        ドは iso-2022-jp のみ

  - PDF 生成は Linux/Win32 の両環境で確認済み

  - HTML 生成は Win32 環境でのみ確認済み

    以下の理由から、(パッケージベースで環境構築するのであれば)Win32 環
    境でのみ HTML 生成を確認済みです。

       - HTML 化に使用する tex4ht は、ASCII TeX(ptex)ではなく、
         NTT-jTeX が必要(内部での処理の違いに起因)

       - Vine 向けの NTT-jTeX パッケージは流通していない

       - Debian 向けの NTT-jTeX パッケージは版が古すぎる

  - HTML 生成はファイル分割形式のみ

    単一ファイル形式の HTML 生成は、LaTeX がヒープ領域不足で悲鳴を上げ
    てしまうため、現時点では未確認です


****
**** 事前準備
****

  現状、LaTeX ソースからの PDF/HTML 生成は、以下の環境で確認しています。

      - Vine 4.2 2.6.16-76.40vl4 (Linux)
      - Debian 2.6.26-13lenny2   (Linux)
      - Windows XP/Vista         (Win32)

  生成に必要なパッケージの導入方法等に関しては、それぞれ以下の URL を参
  照してください。

      - Vine:
          http://oku.edu.mie-u.ac.jp/~okumura/texwiki/?cmd=read&page=Linux%2Fvine

      - Debian:
          http://oku.edu.mie-u.ac.jp/~okumura/texwiki/?cmd=read&page=Linux%2FDebian
          ※ 上記ページでの説明は Sarge でのものですが、動作確認済み環
             境は Lenny です

      - Win32:
          http://www.fsci.fuk.kindai.ac.jp/kakuto/win32-ptex/web2c75.html
          http://oku.edu.mie-u.ac.jp/~okumura/texwiki/?%E3%82%A4%E3%83%B3%E3%82%B9%E3%83%88%E3%83%BC%E3%83%AB(Windows)

  動作確認済みの環境に関する情報は、ja/CONFIRMED.ja.txt を参照してくだ
  さい(導入後の手動設定に関する記述もありますので、必ず目を通してくださ
  い)。

  Linux 環境でパッケージ導入する場合は、自動的に依存パッケージの導入が
  行われますが、Win32 上で環境構築する場合は、手動で適宜導入する必要が
  あります。

  パッケージ間の依存関係は、導入する版によって常に変動しますので、ディ
  スク容量事情が許すなら、試行錯誤をするよりも全パッケージを導入(「フル
  インストール」と呼ばれる状態)するのがお勧めです。


  TeX/LaTeX とは別に、以下のツールの導入が必要です。

      - Inkscape: SVG 画像からの変換処理に使用
          http://www.inkscape.org/
          
      - Graphviz: グラフ画像の生成に使用
          http://www.graphviz.org/

  Debian/Vine 等の Linux 環境ではパッケージ管理ツール経由で導入可能です
  が、Win32 環境への導入はダウンロード＆インストールを手動で行う必要が
  あります。


  LaTeX や画像ファイルとは直接関係しませんが、以下のものも必要です。

      - Perl
      - Python
      - GNU make
      - GNU bash ※ いわゆる B-shell でも可


****
**** PDF/HTML の生成手順
****

  1. lxo ファイルの展開

     以下の URL で表示されるページの "Uploaded files" にある
     "hgbook_lxo.tar.gz" をダウンロードし、「HGBOOK のソースツリーのルー
     ト位置」で展開してください。

         http://bitbucket.org/foozy/hgbook-ja/downloads/

  2. ja ディレクトリ(このファイルの格納されている位置)に移動

     ※ 以下の説明は、全てこのディレクトリを起点としています

  3. Makefile の選択

     Linux 環境の場合は Makefile.linux を、Win32 環境の場合は
     Makefile.win32 を使用します。

     以下の "make 実行" に関する箇所において、それぞれ "-f
     Makefile.linux" ないし "-f Makefile.win32" を指定するものとし
     ます。

  4. PDF の生成は "make pdf" を実行

     pdf ディレクトリ配下に hgbook.pdf が生成されます。

  5. HTML の生成は "make split" を実行(※ Win32 環境でのみ生成を確認)

     html/split ディレクトリ配下に HTML ファイルが生成されます。
     必要なファイルは *.css *.html および *.png フィルです。

===============================================================================
