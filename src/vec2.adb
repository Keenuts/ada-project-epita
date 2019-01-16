with Ada.Numerics.Elementary_Functions; use Ada.Numerics.Elementary_Functions;
package body Vec2 is

	function "+"(Left, Right : in Vector) return Vector is
		O : Vector;
	begin
		O.X := Left.X + Right.X;
		O.Y := Left.Y + Right.Y;
		return O;
	end "+";

	function "-"(Left, Right : in Vector) return Vector is
		O : Vector;
	begin
		O.X := Left.X - Right.X;
		O.Y := Left.Y - Right.Y;
		return O;
	end "-";

	function "*"(Left : in Vector; Scale : in Float) return Vector is
		O : Vector;
	begin
		O.X := Left.X * Scale;
		O.Y := Left.Y * Scale;
		return O;
	end "*";

	procedure swap(Left, Right : in out Vector) is
		O : Vector;
	begin
		O := Left;
		Left := Right;
		Right := O;
	end swap;

	function Dot(A, B : in Vector) return Float is
	begin
		return A.X * B.X + A.Y * B.Y;
	end Dot;

	function Magnitude(V : in Vector) return Float is
	begin
		return Sqrt(Dot(V, V));
	end Magnitude;

	function Normalize(V : in Vector) return Vector is
		M : Float;
	begin
		M := 1.0 / Magnitude(V);
		return V * M;
	end Normalize;

	function Reflect(I, N : in Vector) return Vector is
	begin
		return I - N * (2.0 * Dot(N, I));
	end Reflect;

end Vec2;
