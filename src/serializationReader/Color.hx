package serializationReader;

enum Color {
	Red;
	Green;
	Blue;
	Grey( v : Int );
	Rgb( r : Int, g : Int, b : Color );
	Rgb2(r : Int, g : Color, b : Int);
}