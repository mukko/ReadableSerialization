package ;

import haxe.Unserializer;

/**
 * シリアライズされた文字列をJSON形式に整形し、
 * テキストファイルで出力する
 */
class SerializationReader {
	private var serializedData : String;
	private var outputData : String;
	
	public function new(s:String) {
		this.serializedData = s;
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
