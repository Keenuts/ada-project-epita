package body Entity is
	function getAABB(Self: in RangedEntity'Class) return Rect is
		PX, PY : Float;
	begin
		PX := FLoat(Self.X) / Float(Renderer.RangedPos'Last);
		PY := FLoat(Self.Y) / Float(Renderer.RangedPos'Last);
		PX := PX * Float(SCREEN_WIDTH);
		PY := PY * Float(SCREEN_HEIGHT);

		return ((Natural(PX), Natural(PY)), PARTICLE_SIZE, PARTICLE_SIZE);
	end getAABB;

	function getAABB(Self: in Enemy'Class) return Rect is
		X, Y : Natural;
	begin
		X := (Natural(Self.Pos) - 1) mod GRID_WIDTH;
		Y := (Natural(Self.Pos) - 1) / GRID_HEIGHT;
		X := X * CELL_SIZE;
		Y := Y * CELL_SIZE;
		
		-- FIXME: fix the radius render of the enemy.
		return ((X, Y), CELL_SIZE, CELL_SIZE);
	end getAABB;

	procedure InitializeEntity(Self: in out Entity'Class) is
	begin
		Self.Id := InternalId;
		InternalId := InternalId + 1;
	end InitializeEntity;

	function IsAlive(Self: in Entity'Class) return Boolean is
	begin
		return Self.Alive;
	end IsAlive;

	procedure Dead(Self: in out Entity'Class) is
	begin
		Self.Alive := False;
	end Dead;

	procedure Init(Self : in out Enemy; Pos : Renderer.CellId) is
	begin
		Self.Alive := True;
		Self.Id := InternalId;
		InternalId := InternalId + 1;
		Self.Pos := Pos;
	end Init;

	procedure Init(Self : in out RangedEntity'Class;
		       X : Renderer.RangedPos;
		       Y : Renderer.RangedPos) is
	begin
		Self.Alive := True;
		Self.Id := InternalId;
		InternalId := InternalId + 1;
		Self.X := X;
		Self.Y := Y;
	end Init;

	procedure SetPosition(Self : in out Enemy; Pos : Renderer.CellId) is
	begin
		Self.Pos := Pos;
	end SetPosition;

	procedure SetPosition(Self : in out RangedEntity'Class;
			      X : Renderer.RangedPos;
			      Y : Renderer.RangedPos) is
	begin
		Self.X := X;
		Self.Y := Y;
	end SetPosition;

	function GetPosition(Self : in Enemy) return Renderer.CellId is
	begin
		return Self.Pos;
	end GetPosition;

	function GetX(Self : in RangedEntity'Class) return Renderer.RangedPos is
	begin
		return Self.X;
	end GetX;

	function GetY(Self : in RangedEntity'Class) return Renderer.RangedPos is
	begin
		return Self.Y;
	end GetY;

	function "="(A, B : in Entity'Class) return Boolean is
	begin
		return A.Id = B.Id;
	end "=";

end Entity;
