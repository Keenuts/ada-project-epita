package Vec2 is
	type Vector is record
		X : Float;
		Y : Float;
	end record;

	VECTOR_UP    : Vector := (X => +0.0, Y => -1.0);
	VECTOR_DOWN  : Vector := (X => +0.0, Y => +1.0);
	VECTOR_LEFT  : Vector := (X => -1.0, Y => +0.0);
	VECTOR_RIGHT : Vector := (X => +1.0, Y => +0.0);

	function "+"(Left, Right : in Vector) return Vector
		with Post => "+"'Result.X = Left.X + Right.X and then
			     "+"'Result.Y = Left.Y + Right.Y;
	function "-"(Left, Right : in Vector) return Vector
		with Post => "-"'Result.X = Left.X - Right.X and then
			     "-"'Result.Y = Left.Y - Right.Y;
	function "*"(Left : in Vector; Scale : in Float) return Vector
		with Post => "*"'Result.X = Left.X * Scale and then
			     "*"'Result.Y = Left.Y * Scale;
	procedure swap(Left, Right : in out Vector)
		with Post => Left'Old = Right and then
			     Right'Old = Left;
	function Dot(A, B : in Vector) return Float
		with Post => Dot'Result = (A.X * B.X) + (A.Y * B.Y);
	function Magnitude(V : in Vector) return Float
		with Post => Magnitude'Result * Magnitude'Result = Dot(V, V);
	function Normalize(V : in vector) return Vector
		with Post => Normalize'Result = V * (1.0 / Magnitude(V));
	function Reflect(I, N : in Vector) return Vector
		with Post => Reflect'Result = I - (N * (2.0 * Dot(N, I)));

end Vec2;
