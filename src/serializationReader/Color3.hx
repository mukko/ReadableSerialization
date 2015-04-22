package serializationReader;

enum Color3 {
	Red;
	Green;
	Blue;
	Grey( v : Int );
	Rgb( r : Int, g : Int, b : Color3 );
}