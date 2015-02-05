package ;

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
	
}
