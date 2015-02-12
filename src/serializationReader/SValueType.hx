package serializationReader;

enum SValueType {
	SNull;
	SInt;
	SFloat;
	SBool;
	SObject;
	SFunction;
	SClass(c:String);
	SEnum(e:Dynamic);
	SArray;
	SString;
	SIntMap;
	SStringMap;
	SEnumValueMap;
	SObjectMap;
	SUnknown;
}
