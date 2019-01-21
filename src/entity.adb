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
end Entity;
