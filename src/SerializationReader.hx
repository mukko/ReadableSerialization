package ;

import haxe.ds.StringMap;
import sys.io.File;
import StringTools;

/**
 * シリアライズされた文字列を整形シリアライズ形式に整形する
 */

class SerializationReader {
	private static var TYPE_OF_CLASS_NAME = "_readable_serialization_class_name_";
	
	public function new() {
	}
	
	/**
	 * デシリアライズされた変数のデータを整形シリアライズデータ形式にし、文字列として返す。
	 * シリアライズされた文字列はあらかじめ拡張デシリアライザでデシリアライズし、
	 * その変数のデータを引数に取る。
	 * @param	unserializedData　拡張デシリアライザによってデシリアライズされたデータ
	 * @return	整形シリアライズデータの文字列
	 */
	public static function getTrim2(unserializedData : Dynamic) : String {
		var buf = "";							//整形シリアライズ文字列バッファー
		var type = typeof(unserializedData);	//拡張デシリアライズデータの型取得
		
		//最初の「{」を出力
		buf += "{\n";
		
		//デシリアライズデータの型で判定
		switch(type) {
		case(SValueType.SObject) : //オブジェクトの場合
			var fields = Reflect.fields(unserializedData);
			var numberOfData = 0;
			for (field in fields) {
				var reflectField = Reflect.field(unserializedData, field);
				var field_type = typeof(reflectField);
				var buf2 = getTrim2(reflectField);
				//最後のデータには「,」が付かないようにする
				if (numberOfData == fields.length-1) {
					buf += '	"$field" : $field_type = $reflectField\n';
				}
				else {
					buf += '	"$field" : $field_type = $reflectField,\n';
				}
				trace(buf2);
				numberOfData++;
			}
		case(SValueType.SClass) : 
			var fields = Reflect.fields(unserializedData);
			var numberOfData = 0;
			for (field in fields) {
				var reflectField = Reflect.field(unserializedData, field);
				var field_type = typeof(reflectField);
				var buf2 = getTrim2(reflectField);
				//最後のデータには「,」が付かないようにする
				if (numberOfData == fields.length-1) {
					buf += '	"$field" : $field_type = $reflectField\n';
				}
				else {
					buf += '	"$field" : $field_type = $reflectField,\n';
				}
				trace(buf2);
				numberOfData++;
			}
		case _ : 
			buf += '"__type_name__" : $type = $unserializedData';
		}
		//最後の「}」を出力後は改行
		buf += "}\n";
		
		return buf;
	}
	
	/**
	 * シリアライズされたデータを拡張デシリアライザでデシリアライズし、
	 * 解析した後整形シリアライズデータを取得するメソッド
	 * @param	serializedData シリアライズされた文字列
	 * @return  整形シリアライズ書式に整形した文字列
	 */
	public static function getTrim(serializedString : String) : String {
		var buf = "";
		//拡張デシリアライザを利用しデシリアライズデータを取得
		var unserializedString = ExtendedUnserializer.run(serializedString);
		
		//ハッシュを整形シリアライズデータ化する場合の変数を定義
		var unserializedHash:StringMap<Int> = null;
		if (serializedString.charAt(0) == 'b') {
			unserializedHash = ExtendedUnserializer.run(serializedString);
		}
		//シリアライズデータの先頭の文字を見て、オブジェクトを判別
		var type = typeof(unserializedString);
		switch(serializedString.charAt(0)) {
			case('b') : buf = '{\n	"__type_name__" : $type = $unserializedHash\n}';		//ハッシュの場合
			case('o') : buf = getObjectTrim(unserializedString);		//Object型の場合
			case('c') : buf = getObjectTrim(unserializedString);		//クラスの場合
			case _ : buf = '{\n	"__type_name__" : $type = $unserializedString\n}';	//それ以外の場合
		}
		
		return buf;
	}
	
	/**
	 * デシリアライズされたオブジェクト型の変数をJson形式にして出力
	 * 返り値をStringにするように修正予定。
	 * @param	unserializedObjectData デシリアライズされたオブジェクト型の変数
	 * @return  整形シリアライズ書式に整形したオブジェクトの文字列
	 */
	public static function getObjectTrim(unserializedObjectData : Dynamic) : String {
		var buf = "";
		
		//デシリアライズデータ整形部分
		buf += "{\n";	//最初の「{」後は改行
		var fields = Reflect.fields(unserializedObjectData);
		var numberOfData = 0;
		for (field in fields) {
			var reflectField = Reflect.field(unserializedObjectData, field);
			var type = typeof(reflectField);
			
			//最後のデータには「,」が付かないようにする
			if (numberOfData == fields.length-1) {
				buf += '	"$field" : $type = $reflectField\n';
			}
			else {
				buf += '	"$field" : $type = $reflectField,\n';
			}
			numberOfData++;
		}

		//最後の「}」を出力後は改行
		buf += "}\n";
		
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
			case TClass(c) : SClass(Type.getClassName(c));
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
