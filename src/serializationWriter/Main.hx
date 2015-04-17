package serializationWriter;

import haxe.Serializer;
import haxe.Unserializer;

class Main extends mcli.CommandLine {
	
	public function runDefault(?name:String) {
		//コマンドラインの引数に何も入力していない場合
		if (name == null) { 
			Sys.println("No files selected.");
		}
		else {
			//ファイル名読み込みシリアライズテキストから元データを生成
			var sw = new SerializationWriter(name);
			var originValie = sw.run();
			
			Sys.println(originValie);
			Sys.println("value type =>"+Type.typeof(originValie));
		}
	}
	
	public static function main() {
		new mcli.Dispatch(Sys.args()).dispatch(new Main());
	}
}
