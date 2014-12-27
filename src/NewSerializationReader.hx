package ;

/**
 * シリアライズ文字列を整形シリアライズデータ形式に整形する
 * @author 000ubird
 */
class NewSerializationReader {
	public var serializedText(default, null) : String;				//シリアライズ文字列
	public var extendedUnserializedData(default, null) : Dynamic;	//拡張デシリアライザデータ
	private var indent : Int = 0;									//整形時のインデント保持用変数
	private static var INDENT = "	";								//スペース4個分のインデント文字列
}
