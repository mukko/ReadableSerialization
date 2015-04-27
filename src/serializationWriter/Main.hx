package serializationWriter;

import serializationReader.FileTools;

//生成したいクラス・EnumのインポートはSerializationWriterインスタンスを生成したクラス内
import sampleClass.Color;
import sampleClass.Point;

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
			//指定したファイルから文字列を取得
			var swFile = FileTools.readTextFile(name);
			if (swFile == null) {
				Sys.println("No such file "+name);
			}
			else {
				var sw = new SerializationWriter(name);
				var originValue = sw.run();
				Sys.println(name+"\n");
				Sys.println(swFile+"\n");
				Sys.println("Data is \n"+originValue+"\n\n");
			}
		}
	}
	
	public static function main() {
		new mcli.Dispatch(Sys.args()).dispatch(new Main());
	}
}
