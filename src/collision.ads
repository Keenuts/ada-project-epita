with HAL.Bitmap; use HAL.Bitmap;
with Entity; use Entity;
with Game; use Game;

package Collision is
	function CollideAABB(A, B : in Rect) return Boolean;
	function CollideParticle(ctx : in out GameAccess;
				 P : in RangedEntity'Class) return Boolean;
	procedure CollideParticles(ctx : in out GameAccess);
end Collision;
