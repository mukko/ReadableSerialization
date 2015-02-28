package serializationWriter;
import serializationReader.FileTools;
import Type;

import sampleClass.Point;

/**
 * 整形シリアライズデータを元に元のデータを生成する
 * @author 000ubird
 */
class SerializationWriter {
	private var fileName : String = "";	//整形シリアライズデータの書かれたテキストファイル名
	private var line : String = "";		//整形シリアライズ文字列の1行を保持
	private var currentLine : Int = 0;		//読み取る行数
	private static var MAX_SET_CONSTRUCTORS = 8;	//クラス生成時の最大コンストラクタ数
	
	/**
	 * 整形シリアライズデータの文字列が書かれたテキストファイル名を
	 * 引数に取ってフィールドに保持する
	 * @param	filename 読み込むテキストファイル名
	 */
	public function new(fileName : String) {
		this.fileName = fileName;
	}
	
	/**
	 * 整形シリアライズデータから元のデータを生成を実行
	 * データの生成に失敗した場合は問題のある行数を出力し、nullを返す
	 * @return シリアライズ元データ
	 */
	public function run() : Dynamic { 
		//TODO エラーメッセージを詳細化
		try {
			return getOriginalValue();
		}catch (msg : String) {
			var line = StringTools.replace(this.line, '	', '');	//インデント文字の削除
			trace('\nError in line $currentLine \nLine detail : $line \nError message : $msg');
			return null;
		}
	}
	
	/**
	 * 整形シリアライズデータから元のデータを生成
	 * @return シリアライズ元データ
	 */
	private function getOriginalValue() : Dynamic {
		var originalValue : Dynamic;
		while(true){
			//文字列を取得
			line = FileTools.readLine(fileName, currentLine);
			if (line == null) break;
			/*
			 *ここにある1行に対しての処理を追加予定
			 */
			var type = typeof(line);	//型情報を習得
		
			//元のデータを生成
			switch (type) {
				case TNull : originalValue = null;
				case TInt: originalValue = getInt();
				case TFloat: originalValue = getFloat();
				case TBool : originalValue = getBool();
				case TClass(c) : 
					switch(Type.getClassName(c)) {
						case "String" : originalValue = getString();
						case "Array" : 
							currentLine++;
							originalValue = getArray();
						//外部クラスの場合はインポートが必要
						default : 
							currentLine++;
							originalValue = getClass();
					}
				case TObject : 
					currentLine++;
					originalValue = getObject();
				default : originalValue = null;
			}
			currentLine++;
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
	 * 整形シリアライズ文字列の1行分のデータからBool型の値を返す
	 * @return Bool型の値
	 */
	private function getBool() : Bool {
		var value = getPrimitiveValue();
		if (value == "true") return true;
		else return false;
	}
	
	/**
	 * 整形シリアライズ文字列の1行分のデータからString型の値を返す
	 * @return String型の値
	 */
	private function getString() : String {
		var value = getPrimitiveValue();
		
		//String型の値が「""」だった場合は空列を代入
		if (value == '""') value = '';
		
		return value.toString();
	}
	
	/**
	 * 整形シリアライズデータ文字列から配列を返す
	 * @return 元データの配列
	 */
	private function getArray() : Array<Dynamic> {
		var array : Array<Dynamic> = [];
		//配列の要素を追加
		while(true){
			//文字列を取得
			line = FileTools.readLine(fileName, currentLine);
			if (isEndOfInstance()) break;	//オブジェクトの終わりを示す記号が来たらループを抜ける
			
			//型情報を習得
			var type = typeof(line);
			
			//元のデータを生成
			switch (type) {
				case TNull : array.push(null);
				case TInt: array.push(getInt());
				case TFloat: array.push(getFloat());
				case TBool : array.push(getBool());
				case TClass(c) : 
					switch(Type.getClassName(c)) {
						case "String" : array.push(getString());
						case "Array" : 
							currentLine++;
							array.push(getArray());
						//外部クラスの場合はインポートが必要
						default : 
							currentLine++;
							array.push(getClass());
					}
				case TObject :
					currentLine++;
					array.push(getObject());
				default : array.push(null);
			}
			currentLine++;
		}
		return array;
	}
	
	/**
	 * 整形シリアライズデータ文字列からObject型の値を返す
	 * @return Object型の値
	 */
	private function getObject() : Dynamic {
		var obj = {};
		while(true){
			//文字列を取得
			line = FileTools.readLine(fileName, currentLine);
			if (isEndOfInstance()) break;	//オブジェクトの終わりを示す記号が来たらループを抜ける
			
			//型情報を習得
			var type = typeof(line);
			
			//元のデータを生成
			switch (type) {
				case TNull : Reflect.setField(obj, getValueName(), null);
				case TInt: Reflect.setField(obj,getValueName(),getInt());
				case TFloat: Reflect.setField(obj,getValueName(),getFloat());
				case TBool : Reflect.setField(obj,getValueName(),getBool());
				case TClass(c) : 
					switch(Type.getClassName(c)) {
						case "String" : Reflect.setField(obj, getValueName(), getString());
						case "Array" : 
							currentLine++;
							Reflect.setField(obj, getValueName(), getArray());
						//外部クラスの場合はインポートが必要
						default : 
							currentLine++;
							Reflect.setField(obj, getValueName(), getClass());
					}
				case TObject :
					currentLine++;
					Reflect.setField(obj, getValueName(), getObject());
				default : obj = null;
			}
			currentLine++;
		}
		return obj;
	}
	
	/**
	 * 整形シリアライズデータ文字列からクラスのインスタンスを返す
	 * @return　Classのインスタンス
	 */
	private function getClass() : Class<Dynamic> {
		var className = getClassName();
		var resolveClass = Type.resolveClass(className);
		//クラスが見つからなかった場合はエラーと読み取った行数を出力
		if (resolveClass == null) throw '$currentLine : class "$className" is not found';
		
		var originalClass = Type.createEmptyInstance(resolveClass);
		var numberOfConstructors = 0;
		
		while(true){
			//文字列を取得
			line = FileTools.readLine(fileName, currentLine);
			//インスタンスの終わりを示す記号が来たらループを抜ける
			if (isEndOfInstance()) break;
			//設定可能コンストラクタ数を超えたらエラーを出力
			if (numberOfConstructors > MAX_SET_CONSTRUCTORS) throw "Too many arguments";
			//型情報を習得
			var type = typeof(line);
			
			//元のデータを生成
			switch (type) {
				case TNull : Reflect.setField(originalClass, getValueName(), null);
				case TInt: Reflect.setField(originalClass,getValueName(),getInt());
				case TFloat: Reflect.setField(originalClass,getValueName(),getFloat());
				case TBool : Reflect.setField(originalClass,getValueName(),getBool());
				case TClass(c) : 
					switch(Type.getClassName(c)) {
						case "String" : Reflect.setField(originalClass, getValueName(), getString());
						case "Array" : 
							currentLine++;
							Reflect.setField(originalClass, getValueName(), getArray());
						//外部クラスの場合はインポートが必要
						default : currentLine++;
								  Reflect.setField(originalClass, getValueName(), getClass());
					}
				case TObject :
					currentLine++;
					Reflect.setField(originalClass, getValueName(), getObject());
				default : originalClass = null;
			}
			numberOfConstructors++;
			currentLine++;
		}
		return originalClass;
	}
	
	/**
	 * 現在の行がオブジェクト・クラス・配列の終わりを示す文字列であるかを取得
	 * @return　終わりを示す記号だった場合は真を返す
	 */
	private function isEndOfInstance () : Bool {
		//インデント文字列と「,」を除いた文字列が「}」なら真
		var str = StringTools.replace(line, '	', '');
		str = StringTools.replace(str, ',', '');
		if (str == '}' || str == ']') return true;
		else return false;
	}
	
	/**
	 * 整形シリアライズ文字列の1行分のデータからクラス名を取得する
	 * SClassの次に記述される括弧内の文字列を抽出する
	 * @return クラス名の文字列
	 */
	private function getClassName() : String {
		var r : EReg = ~/SClass(.*) =/;	//クラス名を取り出す正規表現
		r.match(line);
		var value = r.matched(0);	//正規表現によって抽出された文字列を保持
		value = StringTools.replace(value, 'SClass','');//不要な文字の削除
		value = StringTools.replace(value, '(', '');	//「(」の削除
		value = StringTools.replace(value, ')', '');	//「)」の削除
		value = StringTools.replace(value, ' ', '');	//スペースの削除
		value = StringTools.replace(value, '=', '');	//「=」の削除
		return value.toString();
	}
	
	/**
	 * 整形シリアライズ文字列の1行分のデータから変数名を取得する
	 * ダブルクオーテーションで囲まれた部分を抽出する
	 * @return 変数名の文字列
	 */
	private function getValueName() : String {
		var r : EReg = ~/".*" : /;	//型名を取り出す正規表現
		r.match(line);
		var value = r.matched(0);	//正規表現によって抽出された文字列を保持
		value = StringTools.replace(value, ':','');		//「:」の削除
		value = StringTools.replace(value, '"', '');	//「"」の削除
		value = StringTools.replace(value, ' ', '');	//スペースの削除
		return value.toString();
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
	
	private function getMapKeyType() : ValueType{
		return null;
	}
	
	/**
	 * 整形シリアライズ文字列1行がクラス型のデータであるかを判定
	 * @return クラス型であった場合には真を返す
	 */
	private function isClass() : Bool {
		var r : EReg = ~/ SClass\(.*\) /;
		return r.match(line);
	}
	
	/**
	 * 整形シリアライズ文字列の1行分のデータから型情報を取り出す
	 * @param str 型を取得したい文字列
	 * @return データの型
	 */
	private function typeof(str :String) : ValueType {
		var type = "";	//型情報を保持する文字列
		
		//型が外部クラスだった場合はリゾルバクラスを取得する
		if (isClass()) {
			var className = getClassName();
			var resolveClass = Type.resolveClass(className);
			return TClass(resolveClass);
		}
		//型が外部クラスでない場合は型名を取得
		else {
			var r : EReg = ~/:.*=/;	//型名を取り出す正規表現
			r.match(str);
			type = r.matched(0);	//正規表現によって抽出された文字列を保持
			type = StringTools.replace(type, ':','');	//「:」の削除
			type = StringTools.replace(type, '=', '');	//「=」の削除
			type = StringTools.replace(type, ' ', '');	//スペースの削除
		}
		
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
