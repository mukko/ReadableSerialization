package ;
import Type;

/**
 * 整形シリアライズデータを元に元のデータを生成する
 * @author 000ubird
 */
class SerializationWriter {
	public var readableSerializedText(default, null) : String;	//整形シリアライズ文字列
	private var originalValue : Dynamic;//シリアライズ元のデータ
	private var line : String = "";		//整形シリアライズ文字列の1行を保持
	
	/**
	 * 整形シリアライズデータの文字列の書かれたテキストファイル名を
	 * 引数に取り、文字列を読み込んでフィールドに保持
	 * @param	filename 読み込むテキストファイル名
	 */
	public function new(filename : String) {
		readableSerializedText = FileTools.readTextFile(filename);
	}
	
	
	/**
	 * 整形シリアライズ文字列の1行分のデータから型情報を取り出す
	 * @return データの型
	 */
	private function typeof() : ValueType {
		var r : EReg = ~/:.*=/;	//型名を取り出す正規表現
		r.match(line);
		var type = r.matched(0);	//正規表現によって抽出された文字列を保持
		type = StringTools.replace(type, ':','');	//「:」の削除
		type = StringTools.replace(type, '=', '');	//「=」の削除
		type = StringTools.replace(type, ' ', '');	//スペースの削除
		
		//型情報を元にTypeのEnumコンストラクタを返す
		switch (type) {
			case "SNull"	: return TNull;
			case "SInt"		: return TInt;
			case "SFloat"	: return TFloat;
			case "SBool"	: return TBool;
			case "SObject"	: return TObject;
			case "SFunction": return TFunction;
			case "SArray"	: return TClass(Array);
			case "SString"	: return TClass(String);
			case "SIntMap"		: return TClass(haxe.ds.IntMap);
			case "SStringMap"	: return TClass(haxe.ds.StringMap);
			case "SEnumValueMap": return TClass(haxe.ds.EnumValueMap);
			case "SObjectMap"	: return TClass(haxe.ds.ObjectMap);
			case "SUnknown" : return TUnknown;
			default			: return TUnknown;
		}
	}
}
