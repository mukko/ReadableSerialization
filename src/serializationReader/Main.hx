package serializationReader;
import haxe.ds.ObjectMap;
import haxe.ds.StringMap;
import haxe.Serializer;
import haxe.Unserializer;

class Main extends mcli.CommandLine {
	
	public function runDefault(?name:String) {
		if (name == null) {
			Sys.println("No files selected.");
		}
		else if (name == "sample") {
			//サンプルテキストを出力
			var array1 : Array<Dynamic> = [10, 20, "abc"];
			var array2 : Array<Dynamic> = [1.5, "aaa", true];
			var obj = { a:10, b:20 };
			var map1:ObjectMap<Dynamic, Dynamic> = [array1 => array2];
			var int : String = "abcdefg";
			var sr = new SerializationReader(Serializer.run(map1)).run();
			Sys.println(FileTools.outputString(sr, "sample.txt") + " is created.");
		}
		else {
			//指定したファイルからシリアライズ文字列を取得
			var sr = FileTools.readTextFile(name);
			if (sr == null) {
				Sys.println("No such file "+name);
			}
			else {
				var sr = new SerializationReader(sr);
				name += ".txt";
				//整形シリアライズ形式の文字列を出力し、出力ファイル名を取得
				var outFileName = FileTools.outputString(sr.run(), name);
				
				Sys.println("Save as "+outFileName);
			}
		}
	}
	
	public static function main() {
		new mcli.Dispatch(Sys.args()).dispatch(new Main());
	}
}
