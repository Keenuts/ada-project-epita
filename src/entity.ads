with Renderer; use Renderer;
with HAL.Bitmap; use HAL.Bitmap;

package Entity is
	type Entity is tagged private;

	type Enemy is new Entity with private;

	type RangedEntity is new Entity with private;

	type Player is new RangedEntity with private;
	type Particle is new RangedEntity with private;

	function getAABB(Self: in RangedEntity'Class) return Rect;
	function getAABB(Self: in Enemy'Class) return Rect;
	procedure InitializeEntity(Self: in out Entity'Class);
	function IsAlive(Self: in Entity'Class) return Boolean;
	procedure Dead(Self: in out Entity'Class);

	-- Initialization functions
	procedure Init(Self : in out Enemy; Pos : Renderer.CellId);
	procedure Init(Self : in out RangedEntity'Class;
		       X : Renderer.RangedPos;
		       Y : Renderer.RangedPos);

	-- Setters
	procedure SetPosition(Self : in out Enemy; Pos : Renderer.CellId);
	procedure SetPosition(Self : in out RangedEntity'Class;
			      X : Renderer.RangedPos;
			      Y : Renderer.RangedPos);

	-- Getters
	function GetPosition(Self : in Enemy) return Renderer.CellId;
	function GetX(Self : in RangedEntity'Class) return Renderer.RangedPos;
	function GetY(Self : in RangedEntity'Class) return Renderer.RangedPos;

	-- Equals
	function "="(A, B : in Entity'Class) return Boolean;
private
	type Entity is tagged record
		Id : Integer;
		Alive : Boolean;
	end record;

	type Enemy is new Entity with record
		Pos : Renderer.CellId;
	end record;
	
	type RangedEntity is new Entity with record
		X : Renderer.RangedPos;
		Y : Renderer.RangedPos;
	end record;

	type Player is new RangedEntity with null record;
	type Particle is new RangedEntity with null record;
	InternalId : Integer := 0;
end Entity;
