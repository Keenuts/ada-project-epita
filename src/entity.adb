package body Entity is
	function getAABB(Self: in Entity'Class) return Rect is
		PX, PY : Float;
	begin
		-- project to frustrum-space coordinates
		PX := Float(Self.X) / Float(RANGED_POS_LEN);
		PY := Float(Self.Y) / Float(RANGED_POS_LEN);

		-- convert to screen-space coordinated
		PX := PX * Float(SCREEN_WIDTH - Self.Size);
		PY := PY * Float(SCREEN_HEIGHT - Self.Size);

		return ((Natural(PX), Natural(PY)), Self.Size, Self.Size);
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

	procedure Init(Self : in out Entity'Class;
		       X : Renderer.RangedPos;
		       Y : Renderer.RangedPos;
		       Size : Positive;
		       Direction : Vector := (0.0, 0.0)) is
	begin
		Self.Alive := True;
		Self.Id := InternalId;
		InternalId := InternalId + 1;
		Self.X := X;
		Self.Y := Y;
		Self.Size := Size;
		Self.Direction := Direction;
	end Init;

	procedure Init(Self : in out Particle;
		       X : Renderer.RangedPos;
		       Y : Renderer.RangedPos;
		       Size : Positive;
		       Player : Boolean;
		       Direction : Vector := (0.0, 0.0)) is
	begin
		Init(Entity(Self), X, Y, Size, Direction);
		Self.Player := Player;
	end Init;

	procedure SetPosition(Self : in out Entity'Class;
			      X : Renderer.RangedPos;
			      Y : Renderer.RangedPos) is
	begin
		Self.X := X;
		Self.Y := Y;
	end SetPosition;

	function GetX(Self : in Entity'Class) return Renderer.RangedPos is
	begin
		return Self.X;
	end GetX;

	function GetY(Self : in Entity'Class) return Renderer.RangedPos is
	begin
		return Self.Y;
	end GetY;

	function GetDirection(Self : in Entity'Class) return Vector is
	begin
		return Self.Direction;
	end GetDirection;

	function "="(A, B : in Entity'Class) return Boolean is
	begin
		return A.Id = B.Id;
	end "=";

	function IsPlayer(Self : in Particle) return Boolean is
	begin
		return Self.Player;
	end IsPlayer;
end Entity;
