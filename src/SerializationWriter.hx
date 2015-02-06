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
	 * 整形シリアライズデータの文字列が書かれたテキストファイル名を
	 * 引数に取り、文字列を読み込んでフィールドに保持
	 * @param	filename 読み込むテキストファイル名
	 */
	public function new(filename : String) {
		readableSerializedText = FileTools.readTextFile(filename);
	}
	
	/**
	 * 整形シリアライズデータから元のデータを生成
	 * @return シリアライズ元データ
	 */
	public function run() : Dynamic { 
		line = readableSerializedText;	//修正予定
		var type = typeof();	//型情報を習得
		
		//元のデータを生成
		switch (type) {
			case TInt: originalValue = getInt();
			case TFloat: originalValue = getFloat();
			default : originalValue = null;
		}
		return originalValue;
	}
	
	/**
	 * 整形シリアライズ文字列の1行分のデータからInt型の数値を返す
	 * @return Int型の値
	 */
	private function getInt() : Int {
		var value = getPrimitiveValue();
		return Std.parseInt(value);
	}
	
	/**
	 * 整形シリアライズ文字列の1行分のデータからFloat型の数値を返す
	 * @return Float型の値
	 */
	private function getFloat() : Float {
		var value = getPrimitiveValue();
		return Std.parseFloat(value);
	}
	
	/**
	 * 整形シリアライズ文字列の1行分のデータから値の部分の文字列を抽出して返す
	 * 「=」と「,」に囲まれた部分を抽出する。
	 * プリミティブ型の場合のみ正しく動作する
	 * @return 値の文字列
	 */
	private function getPrimitiveValue() : String {
		var r : EReg = ~/=.*,/;	//型名を取り出す正規表現
		r.match(line);
		var value = r.matched(0);	//正規表現によって抽出された文字列を保持
		value = StringTools.replace(value, '=','');	//「=」の削除
		value = StringTools.replace(value, ',', '');//「,」の削除
		value = StringTools.replace(value, ' ', '');//スペースの削除
		return value.toString();
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
