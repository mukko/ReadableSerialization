package ;

/**
 * シリアライズされた文字列をJSON形式に整形し、
 * テキストファイルで出力するクラス
 */
class SerializationReader {
	private var serializedData : String;
	private var outputData : String;
	
	public function new(s:String) {
		this.serializedData = s;
	}	
}
