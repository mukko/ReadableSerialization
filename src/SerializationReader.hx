package ;

import haxe.Unserializer;

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
			case('o') : traceObjectJsonData(unserializedData);				//Object型変数の場合
			case _ : 	//それ以外の場合
		}

		var x = Unserializer.run(serializedData);
		traceObjectJsonData(x);
	}
	
	/**
	 * デシリアライズされたオブジェクト型の変数をJson形式にして出力
	 * 返り値をStringにするように修正予定。
	 * @param	unserializedObjectData デシリアライズされたオブジェクト型の変数
	 */
	public static function traceObjectJsonData(unserializedObjectData : Dynamic) : Void {
		var fields = Reflect.fields(unserializedObjectData);
		
		trace("\n{");
		for (field in fields) {
			var reflectField = Reflect.field(unserializedObjectData, field);
			trace('"$field" : $reflectField - type,');
		}
		trace("\n}");
	}
}
