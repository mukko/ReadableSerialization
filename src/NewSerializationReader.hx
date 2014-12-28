package ;

/**
 * シリアライズ文字列を整形シリアライズデータ形式に整形する
 * @author 000ubird
 */
class NewSerializationReader {
	public var serializedText(default, null) : String;				//シリアライズ文字列
	public var extendedUnserializedData(default, null) : Dynamic;	//拡張デシリアライザデータ
	public var readableSerializedText(default, null) : String;		//整形シリアライズ文字列
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
	
	/**
	 * 拡張デシリアライズデータから整形シリアライズ文字列を取得し、
	 * インデントと改行を挿入した整形シリアライズ文字列を返す
	 */
	public function run() : String {
		readableSerializedText = getReadableSerializedText(extendedUnserializedData);
		return addIndentAndNewLine(readableSerializedText);
	}
	
	/**
	 * 整形シリアライズ文字列を読み込み、改行とインデントを付け足す
	 * @param	readableSerializedText 整形シリアライズ文字列
	 * @return  改行とインデントが含まれた整形シリアライズ文字列
	 */
	private function addIndentAndNewLine(readableSerializedData : String) : String {
		var strBuf = "";	//文字列保持用のバッファ
		var indent = 0; 	//整形時のインデント保持用変数
		
		for (i in 0...readableSerializedData.length) {
			switch(readableSerializedData.charAt(i)) {
				case "{","[":
					strBuf += readableSerializedData.charAt(i);
					strBuf += "\n";
					indent++;
					for (i in 0...indent) strBuf += INDENT;
				case "}": 
					//「}」の次の文字が「,」だったら改行を出力しない
					if (readableSerializedData.charAt(i + 1) == "," ||
						readableSerializedData.charAt(i + 1) == ")") {
						strBuf += readableSerializedData.charAt(i);
					}
					else {
						strBuf += readableSerializedData.charAt(i);
						strBuf += "\n";
						indent--;
					}
				case ",": 
					//「,」の次の文字が「}」だったら改行を出力してインデントの数を減らす
					if (readableSerializedData.charAt(i + 1) == "}" ||
						readableSerializedData.charAt(i + 1) == "]") {
						strBuf += readableSerializedData.charAt(i);
						strBuf += "\n";
						indent--;
					}
					else {
						strBuf += readableSerializedData.charAt(i);
						strBuf += "\n";
					}
					for (i in 0...indent) strBuf += INDENT;
				default : strBuf += readableSerializedData.charAt(i);
			}
		}
		return strBuf;
	}
	
	/**
	 * 拡張デシリアライズデータを引数に取り、整形シリアライズ文字列を返す
	 * @return インデント・改行無しの整形シリアライズ文字列
	 */
	private function getReadableSerializedText(exUnserializedData : Dynamic) : String {
		var strbuf = "";						//整形シリアライズ文字列バッファー
		var type = typeof(exUnserializedData);	//拡張デシリアライズデータの型取得

		if (recursiveDepth == 0) strbuf += "{";
		recursiveDepth++;
		
		//デシリアライズデータの型で判定
		switch(type) {
			case SObject , SValueType.SClass : 
				strbuf += getSObjectReadableSerializedText(exUnserializedData, type);
			case SArray : 
				strbuf += getSArrayReadableSerializedText(exUnserializedData, type);
			case SIntMap, SStringMap, SEnumValueMap, SObjectMap : 
				strbuf += getSMapReadableSerializedText(exUnserializedData, type);
			case SValueType.SEnum : 
				strbuf += getSEnumReadableSerializedText(exUnserializedData, type);
			default : strbuf += '"" : $type = $exUnserializedData,';
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
	 * SArray型の拡張デシリアライズデータを整形シリアライズ文字列にして返す
	 * @param	exUnserializedData 拡張デシリアライズデータ
	 * @param	type 拡張デシリアライズデータの型
	 * @return  改行・インデント無しの整形シリアライズ文字列
	 */
	private function getSArrayReadableSerializedText(exUnserializedData : Dynamic, type : SValueType) : String {
		var strbuf = "";		//整形シリアライズデータ保持用バッファ
		var array : Array<Dynamic> = exUnserializedData;	//デシリアライズデータを明示的に配列に代入
		var fields = Reflect.fields(exUnserializedData);	//フィールド取得
		var name = fields[0];	//フィールドのインデックスの0番目に配列のインスタンス名が保持されている
		
		//インスタンス名が「__a」だった場合はトップレベルの配列であることを名前部分に出力する
		if (name == "__a") {
			if (recursiveDepth >= NOT_OUTPUT_VALUE_TYPE) strbuf += '[';
			else strbuf += '__topLevelValue : $type = [';
		}
		
		for (i in 0...array.length) {
			var fieldType = typeof(array[i]);	//配列の要素の型を取得
			if (isRecursive(fieldType)) {
				strbuf += '"" : $fieldType = '+getReadableSerializedText(array[i])+',';
			}
			else {
				strbuf += '"" : $fieldType = '+array[i]+',';
			}
		}
		
		if (recursiveDepth >= NOT_OUTPUT_VALUE_TYPE) strbuf += ']';
		else strbuf += '],';
		
		return strbuf;
	}
	
	/**
	 * マップ型の拡張デシリアライズデータを整形シリアライズ文字列にして返す
	 * @param	exUnserializedData 拡張デシリアライズデータ
	 * @param	type 拡張デシリアライズデータの型
	 * @return  改行・インデント無しの整形シリアライズ文字列
	 */
	private function getSMapReadableSerializedText(exUnserializedData : Dynamic, type : SValueType) : String {
		var map : Map<Dynamic,Dynamic> = exUnserializedData;
		var strBuf = "";	//マップ用文字列バッファ
		
		strBuf += '"" : $type = ';
		for (key in map.keys()) {
			var keyType = typeof(key);				//キーの型情報を取得
			var valueType = typeof(map.get(key));	//値の情報を取得
			
			//値の型が再帰が必要な場合、値を引数に入れて再帰的に呼び出す
			if (isRecursive(valueType)) {
				strBuf += '($key : $keyType => ' +getReadableSerializedText(map.get(key))+') : $valueType,';
			}
			else {
				strBuf += '($key : $keyType => '+map.get(key)+' : $valueType),';
			}
		}
		return strBuf;
	}
	
	/**
	 * SEnum型の拡張デシリアライズデータを整形シリアライズ文字列にして返す
	 * @param	exUnserializedData 拡張デシリアライズデータ
	 * @param	type 拡張デシリアライズデータの型
	 * @return  改行・インデント無しの整形シリアライズ文字列
	 */
	private function getSEnumReadableSerializedText(exUnserializedData : Dynamic, type : SValueType) : String {
		var dummyEnum : DummyEnum = exUnserializedData;
		var enumParam = dummyEnum.getParameters();
		var params : Array<Dynamic> = enumParam[2];	//Enumのパラメータを取得
		var strBuf = "";	//マップ用文字列バッファ
		
		if (params != null) {
			strBuf += '"" : SEnum = ';
			for (i in 0...params.length) {
				//Enumのパラメータを引数に取り、再帰的に呼び出し
				strBuf += getReadableSerializedText(params[i])+"\n";
			}
		}
		else{
			strBuf += '"" : SEnum('+enumParam[0]+') = '+enumParam[1]+",\n";
		}
		return strBuf;
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
						SEnum(e);
					case _ :
						throw 'Internal Error';
				}
			case TUnknown  : SUnknown;
		}
	}
}
