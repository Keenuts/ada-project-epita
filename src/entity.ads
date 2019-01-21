with Renderer; use Renderer;
with HAL.Bitmap; use HAL.Bitmap;

package Entity is
	type Entity is tagged record
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

	function getAABB(Self: in RangedEntity'Class) return Rect;
	function getAABB(Self: in Enemy'Class) return Rect;
end Entity;
