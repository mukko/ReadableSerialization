ReadableSerialization
=====================
ReadableSerializationはhaxe.Serializer.run()されたデータをjson形式に整形し、出力する機能を持ちます。  
また、出力された整形シリアライズデータをhaxe.Unserializer.run()することもできます。    

---
#### ディレクトリ構造(2015/04/27現在)
sr.n  
sw.n  
と同じディレクトリにテキストファイルを用意してください。

---
#### 具体例    
以下のPointクラスを定義したとする。
  
    class Point {  
        public var x(default, null) : Int; 
        public var y(default, null) : Int;  

        public function new(x : Int , y : Int) {
		    this.x = x;
		    this.y = y;
	    }
    }


コード内でポイント型のインスタンスを  
x = 10,
y = 20,
として作成したとし、それをシリアライズすると(haxe.Serializer.run())


    cy5:Pointy1:xi10y1:yi20g


という文字列を得ることができる。  
この文字列を例えばpoint.txt形式で保存し、  
### コマンド
    > neko sr point.txt
 
と入力することで、json形式に整形したデータ"sr_point.txt.txt"を出力する

    //sr_point.txt.txt
    "" : SClass(Point) = {
	    "x" : SInt = 10,
	    "y" : SInt = 20,
    },

以下作業中