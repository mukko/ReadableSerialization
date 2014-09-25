package ;

import haxe.Unserializer;
import sys.io.File;

/**
 * シリアライズされた文字列をJSON形式に整形し、
 * テキストファイルで出力する
 */

class SerializationReader {
	public function new() {
	}
	
	/**
	 * シリアライズされたデータをデシリアライズし、
	 * Json形式に整形し出力するメソッド
	 * 返り値をStringにするように修正予定。
	 * @param	serializedData シリアライズされたデータ
	 */
	public static function getJsonData(serializedData : String) : Void {
		var unserializedData = Unserializer.run(serializedData);
		
		trace(unserializedData);
		trace(serializedData);
		
		switch(serializedData.charAt(0)) {
			case('i') : trace('\n{\n  "" : $unserializedData - Int\n}'); 	//Int型変数の場合
			case('d') : trace('\n{\n  "" : $unserializedData - Float\n}');	//Float型変数の場合
			case('b') : trace('\n{\n   : $unserializedData - Hash\n}');		//Hash型変数の場合
			//case('o') : traceObjectJsonData(unserializedData);				//Object型変数の場合
			case _ : 	//それ以外の場合
		}

		var x = Unserializer.run(serializedData);
		//traceObjectJsonData(x);
	}
	
	/**
	 * デシリアライズされたオブジェクト型の変数をJson形式にして出力
	 * 返り値をStringにするように修正予定。
	 * @param	unserializedObjectData デシリアライズされたオブジェクト型の変数
	 * @return  Json形式に整形した文字列データ
	 */
	public static function getObjectJsonData(unserializedObjectData : Dynamic) : String {
		var buf = "";
		
		//デシリアライズデータ整形部分
		buf += "{\n";	//最初の「{」後は改行
		var fields = Reflect.fields(unserializedObjectData);
		var numberOfData = 0;
		for (field in fields) {
			var reflectField = Reflect.field(unserializedObjectData, field);
			var type = Type.getClassName(Type.getClass(field));
			
			//最後のデータには「,」が付かないようにする
			if (numberOfData == fields.length-1) {
				buf += '	"$field" : $reflectField - $type\n';
			}
			else {
				buf += '	"$field" : $reflectField - $type,\n';
			}
			numberOfData++;
		}

		//最後の「}」を出力後は改行
		buf += "}\n";
		
		return buf;
	}
	
	/**
	 * String型の文字列をテキストファイルに出力する
	 * @param	output 出力する文字列
	 * @param	fname  出力するテキストファイル名
	 */
	public static function outputString(output : String, fileName : String) : Void {
		var fileOut = File.write(fileName);
		fileOut.writeString(output);
		fileOut.close();
	}
	
	/**
	 * テキストファイルから文字列を取得する
	 * @param	fileName 読み込むテキストファイル名
	 * @return  読み込んだテキストファイルのデータ
	 */
	public static function readTextFile(fileName : String) : String {
		return File.getContent(fileName);
	}
}
