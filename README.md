#CKIP_Client

[RubyGems](http://rubygems.org/gems/ckip_client)

CKIP_Client是連接[中央研究院][中央研究院][詞庫小組][詞庫小組]研發之[中文斷詞系統][斷詞系統]與[中文剖析系統][剖析系統]的Ruby程式界面。  
感謝中央研究院[詞庫小組][詞庫小組]多年來之研究成果！


## 安裝 Installation

請先至中文斷詞系統[網站][斷詞申請]或中文剖析系統[網站][剖析申請]申請：帳號/密碼  
再安裝本Gem

	gem install ckip_client

安裝完成後至Gem所在資料夾中修改帳號密碼資料。  
資料夾位置通常在：/usr/local/lib/ruby/gems/1.9.1/gems/  
進入：ckip_client-0.0.5/lib/config/  
於 segment.yml 檔案中輸入中文斷詞系統之帳號密碼，  
於 parser.yml 檔案中輸入中文剖析系統之帳號密碼，  
至此安裝設定就緒。


## 使用 Usage

將文章斷詞：

	CKIP.segment( text )

剖析文章：

	CKIP.parser( text )
	
也可以讓輸出結果濾除詞性資料，在輸入時加入第二個參數 'neat'

	CKIP.segment( text , 'neat' )
	CKIP.parser( text , 'neat' )

文字編碼：  
輸入的字串編碼可以是 UTF-8 或 Big5 或是 Big5-UAO 三種其中之一。  
而輸出結果一律為 UTF-8 編碼。  
CKIP系統不支援 Big5-HKSCS 之特有港字。


## 範例 Example

	require 'ckip_client'
	text = File.open('text.txt').read
	puts CKIP.segment( text )


## 參閱 References

+ [中研院詞庫小組][詞庫小組]
+ [中文斷詞系統][斷詞系統]
+ [中文剖析系統][剖析系統]


[中央研究院]: http://www.sinica.edu.tw/
[詞庫小組]: http://godel.iis.sinica.edu.tw/CKIP/
[斷詞系統]: http://ckipsvr.iis.sinica.edu.tw
[剖析系統]: http://parser.iis.sinica.edu.tw
[斷詞申請]: http://ckipsvr.iis.sinica.edu.tw/webservice.htm
[剖析申請]: http://parser.iis.sinica.edu.tw/v1/apply.htm