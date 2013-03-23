kkci2pron(Kana Kanji Conversion Input to Pronunciation)
=========

## Contribution

The <strong>kkci2pron</strong> converts a Japanese yomi, precisely Kana-Kanji conversion input, to a pronunciation.

With this program, you can generate a speaking-style corpus from a writing-style corpus annotated with word boundaries and Japanese yomis, then can construct a speaking-stype language model. You can improve an accurary of a speech recogniton system by combining this language model and the domain-independent large corpus, i.e. [CSJ](http://www.ninjal.ac.jp/csj/).

This program is developed by [Yohei Yamaguchi](http://www.gologo13.com) when he was a graduate student. If you have an any question, please contact him.

## Installation

<pre>
$ git clone git://github.com/gologo13/kkci2pron
</pre>

You must install [Kyfd (the Kyoto Fst Decoder)](http://www.phontron.com/kyfd/) before running kkci2pron.

## Configuration

Edit <strong>config.xml</strong> to setup kyfd before running the kkci2pron.

## Usage

<pre>
$ cat sample.txt
私/ワタシ は/ハ 太郎/タロウ です/デス
気温/キオン 変動/ヘンドウ
$ perl bin/kkci2pron.pl ＜ sample.txt
私/ワタシ は/ワ 太郎/タロー です/デス
気温/キオン 変動/ヘンドー
</pre>

## Input Format

An input text must follow the following format.

> text := sentence + \n(newline character) + sentence + … + sentence
> 
> sentence := unit + ' '(space) + unit + … + unit
> 
> unit := word + /(slash) + yomi
> 
> word := (Japanese Full-width Character)+
> 
> yomi := (Japanese Full-width Katakana Character)+


Next, an input text must be encoded in <strong>UTF8</strong>.

## License

MIT License. Please see the LICENSE file for details.

## Reference

山口 洋平、森 信介、河原 達也<br>
仮名漢字変換ログを用いた講義音声認識のための言語モデル適応<br>
言語処理学会第18回年次大会(NLP2012)、広島、March 2012
