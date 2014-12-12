package ;

import haxe.ds.StringMap;
import sys.io.File;
import StringTools;

/**
 * シリアライズされた文字列を整形シリアライズ形式に整形する
 */

class SerializationReader {
	private static var TYPE_OF_CLASS_NAME = "_readable_serialization_class_name_";
	private static var INDENT = "	";
	
	public function new() {
	}
	
	/**
	 * デシリアライズされた変数のデータを整形シリアライズデータ形式にし、文字列として返す。
	 * シリアライズされた文字列はあらかじめ拡張デシリアライザでデシリアライズし、
	 * その変数のデータを引数に取る。
	 * @param	unserializedData　拡張デシリアライザによってデシリアライズされたデータ
	 * @param   indent インデントの数を保持
	 * @return	整形シリアライズデータの文字列
	 */
	public static function getShapedSerializeData(unserializedData : Dynamic,indent : Int) : String {
		var buf = "";							//整形シリアライズ文字列バッファー
		var type = typeof(unserializedData);	//拡張デシリアライズデータの型取得
		
		//インデント数を1増やした後、「{」と改行とインデントを格納
		indent++;
		buf += "{\n";
		for (i in 0...indent) {
			buf += INDENT;
		}
		//デシリアライズデータの型で判定
		switch(type) {
		case SValueType.SObject, SValueType.SClass :
			//フィールド走査
			var fields = Reflect.fields(unserializedData);
			for (field in fields) {
				var reflectField = Reflect.field(unserializedData, field);
				var field_type = typeof(reflectField);
				var recursiveStrBuf = getShapedSerializeData(reflectField,indent);	//再帰呼び出す用文字列バッファ
				var mapStrBuf = "";	//マップ用文字列バッファ
				var arrayStrBuf = "";	//配列用文字列バッファ
				
				//フィールド変数の文字で出力形式を変更
				switch(field) {
					case "h" : //フィールドが「h」だった場合はハッシュ・マップと判断して整形シリアライズ文字列を生成する
						field_type = SValueType.SClass("HashMap");
						var x:Map<Dynamic,Dynamic> = unserializedData;
						for (key in x.keys()) {
							var keyType = typeof(key);			//キーの型情報を取得
							var valueType = typeof(x.get(key));	//値の情報を取得
						
							//ハッシュ・マップの値を引数に入れて再帰的に呼び出す
							if (Std.is(x.get(key), StringMap)) {
								mapStrBuf += '[$key : $keyType --> ' +getShapedSerializeData(x.get(key),indent);
							}
							else {
								mapStrBuf += '[$key : $keyType --> '+getShapedSerializeData(x.get(key),indent)+' : $valueType]';
							}
						}
						buf += '"$field" : $field_type = $mapStrBuf,\n';
						
					//フィールドが「__a」だった場合は配列と判断して整形シリアライズ文字列を生成する
					case "__a" :
						field_type = SValueType.SClass("Array");
						var array:Array<Dynamic> = unserializedData;
						for (i in 0...array.length) {
							arrayStrBuf += getShapedSerializeData(array[i],indent) + ",";
						}
						buf += '"$field" : $field_type = $arrayStrBuf\n';
						
					//lengthの場合には何も出力しない
					case "length" :
						
					default : 
						for (i in 0...indent) {
							buf += INDENT;
						}
						buf += '"$field" : $field_type = $recursiveStrBuf,\n';
				}
			}
		case SString :
			var fields = Reflect.fields(unserializedData);
			//フィールドのインデックスの0番目に文字列のインスタンス名が保持されている
			var name = fields[0];
			//インスタンス名が「__s」だった場合は名前を出力しない
			if (name == "__s") {
				buf += '"" : $type = $unserializedData,\n';
			}
			else {
				buf += '"$name" : $type = $unserializedData,\n';
			}
			
		case SValueType.SEnum : 
			var dummyEnum : DummyEnum = unserializedData;
			var enumParam = dummyEnum.getParameters();
			//Enumのパラメータを引数に取り、再帰的に呼び出し
			buf += '"'+enumParam[0]+'"'+" : SEnum("+enumParam[1]+") = "+getShapedSerializeData(enumParam[2],indent)+"\n";
		
		default : 
			buf += '"__type_name__" : $type = $unserializedData\n';
		}
		//インデントと最後の「}」を出力
		for (i in 0...indent - 1) {
			buf += INDENT;
		}
		buf += "}";
		
		return buf;
	}
	
	/**
	 * 整形シリアライズデータからデシリアライズ可能な文字列を生成する
	 * @param	整形シリアライズデータの文字列
	 * @return  デシリアライズ可能な文字列
	 */
	public static function getOriginalUnserializedData(jsonData : String) : String {
		var buf = "";
		var buf2 = "";
		//改行文字の削除
		for (i in 0...jsonData.length) {
			buf += StringTools.replace(jsonData.charAt(i), '\n', '');
		}
		//スペースの削除
		for (i in 0...buf.length) {
			buf2 += StringTools.ltrim(buf.charAt(i));
		}

		trace(buf2);
		return buf2;
	}
	
	/**
	 * デシリアライズしたデータから得られたオブジェクトの型名を取得するメソッド
	 * @param	v デシリアライズしたデータ
	 * @return	要素の型名
	 */ 
	private static function typeof(v:Dynamic):SValueType {
		if (Reflect.hasField(v, '$TYPE_OF_CLASS_NAME')) {
			return SClass(Reflect.field(v, '$TYPE_OF_CLASS_NAME'));
		}
		return switch (Type.typeof(v)) {
			case TNull     : SNull;
			case TInt      : SInt;
			case TFloat    : SFloat;
			case TBool     : SBool;
			case TObject   : SObject;
			case TFunction : SFunction;
			case TClass(c) : //trace(Type.getClassName(c));	//デバッグ用
				switch (Type.getClassName(c)) {
					case "Array"				: SArray;
					case "String"				: SString;
					case "haxe.ds.IntMap"		: SIntMap;
					case "haxe.ds.StringMap"	: SStringMap;
					case "haxe.ds.EnumValueMap"	: SEnumValueMap;
					case "haxe.ds.ObjectMap"	: SObjectMap;
					default						: SClass(Type.getClassName(c)); 
				};
			case TEnum(e)  : 
				switch (v) {
					case DummyEnum.Dummy_Enum(e, c, p) :
						SEnum(e, c, p);
					case _ :
						throw 'Internal Error';
				}
			case TUnknown  : SUnknown;
		}
	}
	
	/**
	 * String型の文字列をテキストファイルに出力する
	 * @param	output 出力する文字列
	 * @param	fileName  出力するテキストファイル名
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
