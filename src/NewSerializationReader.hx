package ;

/**
 * シリアライズ文字列を整形シリアライズデータ形式に整形する
 * @author 000ubird
 */
class NewSerializationReader {
	public var serializedText(default, null) : String;				//シリアライズ文字列
	public var extendedUnserializedData(default, null) : Dynamic;	//拡張デシリアライザデータ
	public var readableSerializedText(default, null) : String;		//整形シリアライズ文字列
	private var indent : Int = 0;		//整形時のインデント保持用変数
	private var recursiveDepth:Int = 0;	//再帰の深度を保持する変数
	private static var INDENT = "	";	//スペース4個分のインデント文字列
	private static var NOT_OUTPUT_VALUE_TYPE = 2;	//変数名と型を出力しない再帰深度
	
	/**
	 * シリアライズ文字列を引数に取る
	 * 引数のシリアライズ文字列を拡張デシリアライザデータにしてフィールド変数に保持
	 * @param	serializedText シリアライズ文字列
	 */
	public function new(serializedText : String) {
		this.serializedText = serializedText;
		extendedUnserializedData = ExtendedUnserializer.run(serializedText);
		readableSerializedText = "";
	}
	
	public function getSeikeiSerializedData() : String {
		trace(indent);
		indent++;
		trace(indent);
		return this.extendedUnserializedData;
	/**
	 * 拡張デシリアライズデータを引数に取り、整形シリアライズ文字列を返す
	 * @return インデント・改行無しの整形シリアライズ文字列
	 */
	private function getReadableSerializedText(exUnserializedData : Dynamic) : String {
		var strbuf = "";						//整形シリアライズ文字列バッファー
		var type = typeof(exUnserializedData);	//拡張デシリアライズデータの型取得

		if (recursiveDepth == 0) strbuf += "{";
		recursiveDepth++;
		switch(type) {
			case SObject : strbuf += getSObjectReadableSerializedText(exUnserializedData,type);
			default : 
		}
		recursiveDepth--;
		if (recursiveDepth == 0) strbuf += "}";
		return strbuf;
	}
	
	/**
	 * SObject型の拡張デシリアライズデータを整形シリアライズ文字列にして返す
	 * @param	exUnserializedData 拡張デシリアライズデータ
	 * @param	type 拡張デシリアライズデータの型
	 * @return  改行・インデント無しの整形シリアライズ文字列
	 */
	private function getSObjectReadableSerializedText(exUnserializedData : Dynamic, type : SValueType) : String{
		var strbuf = "";		//整形シリアライズデータ保持用バッファ
		var fields = Reflect.fields(exUnserializedData);
		//2回目移行の再帰の場合は変数名と型名を出力しない
		if (recursiveDepth >= NOT_OUTPUT_VALUE_TYPE) {
			strbuf += '{';
		}
		else {
			strbuf += '"" : $type = {';
		}
		//フィールド走査を行いそれぞれのフィールドを整形シリアライズデータ形式にする
		for (field in fields) {
			var reflectField = Reflect.field(exUnserializedData, field);
			var fieldType = typeof(reflectField);
			
			if (isRecursive(fieldType)) {
				strbuf += '"$field" : $fieldType = '+getReadableSerializedText(reflectField)+',';
			}
			else {
				strbuf += '"$field" : $fieldType = $reflectField,';
			}
		}
		strbuf += '}';
		return strbuf;
	}
	
	/**
	 * 引数の型が再帰が必要な型かを返す
	 * @param	t SValueTypeのコンストラクタ
	 * @return  再帰が必要な場合はtrue、必要無い場合はfalse
	 */
	private static function isRecursive(t : SValueType) : Bool{
		switch(t) {
			//オブジェクト・クラス・Enum・配列は再帰が必要
			case SObject, SValueType.SClass, SValueType.SEnum, SArray : return true;
			//マップ型も再帰が必要
			case SIntMap, SStringMap, SEnumValueMap, SObjectMap : return true;
			//それ以外はプリミティブ型と判断し、再帰が必要でないとする
			default : return false;
		}
	}
	
	/**
	 * デシリアライズしたデータから得られたオブジェクトの型名を取得するメソッド
	 * @param	v デシリアライズしたデータ
	 * @return	要素の型名
	 */ 
	private static function typeof(v:Dynamic):SValueType {
		if (Reflect.hasField(v, '_readable_serialization_class_name_')) {
			return SClass(Reflect.field(v, '_readable_serialization_class_name_'));
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
}
