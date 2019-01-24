with HAL.Bitmap; use HAL.Bitmap;
with Entity; use Entity;
with Game; use Game;

package Collision is
	function CollideAABB(A, B : in Rect) return Boolean;
	procedure CollideParticle(ctx : in out GameAccess; P : in out Particle);
	procedure CollideParticles(ctx : in out GameAccess);
	procedure CollidePlayer(ctx : in out GameAccess);
	procedure CollideObjects(ctx : in out GameAccess);
end Collision;
