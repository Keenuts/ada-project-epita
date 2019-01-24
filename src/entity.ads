with Renderer; use Renderer;
with HAL.Bitmap; use HAL.Bitmap;
with Vec2; use Vec2;

package Entity is
	type Entity is tagged private;

	type Enemy    is new Entity with private;
	type Player   is new Entity with private;
	type Particle is new Entity with private;
	type EnemyParticle is new Entity with private;
	type PlayerParticle is new Entity with private;

	function getAABB(Self: in Entity'Class) return Rect;

	procedure InitializeEntity(Self: in out Entity'Class);
	function IsAlive(Self: in Entity'Class) return Boolean;
	procedure Dead(Self: in out Entity'Class);

	-- Initialization functions
	procedure Init(Self : in out Entity'Class;
		       X : Renderer.RangedPos;
		       Y : Renderer.RangedPos;
		       Size : Positive;
		       Direction : Vector := (0.0, 0.0));
	procedure Init(Self : in out Particle;
		       X : Renderer.RangedPos;
		       Y : Renderer.RangedPos;
		       Size : Positive;
		       Player : Boolean;
		       Direction : Vector := (0.0, 0.0));

	-- Setters
	procedure SetPosition(Self : in out Entity'Class;
			      X : Renderer.RangedPos;
			      Y : Renderer.RangedPos);

	-- Getters
	function GetX(Self : in Entity'Class) return Renderer.RangedPos;
	function GetY(Self : in Entity'Class) return Renderer.RangedPos;
	function GetDirection(Self : in Entity'Class) return Vector;

	-- Equals
	function "="(A, B : in Entity'Class) return Boolean;

	function IsPlayer(Self : in Particle) return Boolean;
private
	type Entity is tagged record
		Id : Integer;
		Alive : Boolean;
		X : Renderer.RangedPos;
		Y : Renderer.RangedPos;
		Size : Positive;
		Direction : Vector;
	end record;

	type Player   is new Entity with null record;
	type Enemy    is new Entity with null record;
	type Particle is new Entity with record
		Player : Boolean;
	end record;
	type PlayerParticle is new Entity with null record;
	type EnemyParticle is new Entity with null record;

	InternalId : Integer := 0;
end Entity;
