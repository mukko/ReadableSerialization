package serializationWriter;

import haxe.Serializer;
import haxe.Unserializer;
import serializationReader.SerializationReader;
import serializationReader.FileTools;

class Main extends mcli.CommandLine {
	
	public function runDefault(?name:String) {
		//コマンドラインの引数に何も入力していない場合
		if (name == null) { 
			Sys.println("No files selected.");
		}
		else if (name == "test") {
			var sw = new SerializationWriter("sr_out.txt");
			trace(sw.run());
		}
		else {
			Sys.println(FileTools.readTextFile(name));
			//ファイル名読み込みシリアライズテキストから元データを生成
			var sw = new SerializationWriter(name);
			var originValie = sw.run();
			
			Sys.println("Data is \n"+originValie);
			Sys.println("value type =>" + Type.typeof(originValie));

			//sw後のデータから再びsrできるかをテスト
			var sr = new SerializationReader(Serializer.run(originValie));
			Sys.println(sr.run());
		}
	}
	
	public static function main() {
		new mcli.Dispatch(Sys.args()).dispatch(new Main());
	}
}
