package Vec2 is
	type Vector is record
		X : Float;
		Y : Float;
	end record;

	VECTOR_UP    : Vector := (X => +0.0, Y => -1.0);
	VECTOR_DOWN  : Vector := (X => +0.0, Y => +1.0);
	VECTOR_LEFT  : Vector := (X => -1.0, Y => +0.0);
	VECTOR_RIGHT : Vector := (X => +1.0, Y => +0.0);

	function "+"(Left, Right : in Vector) return Vector;
	function "-"(Left, Right : in Vector) return Vector;
	function "*"(Left : in Vector; Scale : in Float) return Vector;
	procedure swap(Left, Right : in out Vector);
	function Dot(A, B : in Vector) return Float;
	function Magnitude(V : in Vector) return Float;
	function Normalize(V : in vector) return Vector;
	function Reflect(I, N : in Vector) return Vector;

end Vec2;
