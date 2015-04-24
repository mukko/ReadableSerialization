package serializationReader;

enum Color {
	Red;
	Green;
	Blue;
	Grey( v : Int );
	Rgb( r : Int, g : Int, b : Color3 );
	Rgb2(r : Int, g : Color3, b : Int);
}