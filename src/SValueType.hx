package ;

enum SValueType {
	SNull;
	SInt;
	SFloat;
	SBool;
	SObject;
	SFunction;
	SClass(c:String);
	SEnum(e:Dynamic, n:Dynamic, p:Dynamic);
	SUnknown;
}
