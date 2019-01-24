package body Collision is

	function CollideAABB(A, B : in Rect) return Boolean is
	begin
		if A.Position.X + A.Width < B.Position.X then
			return False;
		end if;

		if A.Position.Y + A.Height < B.Position.Y then
			return False;
		end if;

		if A.Position.X > B.Position.X + B.Width then
			return False;
		end if;

		if A.Position.Y > B.Position.Y + B.Height then
			return False;
		end if;

		return True;
	end CollideAABB;

	procedure CollideParticle(ctx : in out GameAccess; P : in out Particle) is
		A, B : Rect;
	begin
		B := P.getAABB;
		A := ctx.player.getAABB;
		if CollideAABB(A, B) then
			ctx.CollisionCallback(P, ctx.player);
			return;
		end if;
		for E of ctx.enemies loop
			if E.IsAlive then
				A := E.getAABB;
				if CollideAABB(A, B) then
					ctx.CollisionCallback(P, E);
				end if;
			end if;
		end loop;
	end CollideParticle;

	procedure CollideParticles(ctx : in out GameAccess) is
	begin
		for P of ctx.particles loop
			if P.IsAlive then
				CollideParticle(ctx, P);
			end if;
		end loop;
	end CollideParticles;

	procedure CollidePlayer(ctx : in out GameAccess) is
		A, B : Rect;
	begin
		A := ctx.player.getAABB;
		for E of ctx.enemies loop
			B := E.getAABB;
			if CollideAABB(A, B) then
				ctx.CollisionCallback(ctx.player, E);
			end if;
		end loop;
	end CollidePlayer;

	procedure CollideObjects(ctx : in out GameAccess) is
	begin
		CollideParticles(ctx);
		CollidePlayer(ctx);
	end CollideObjects;

end Collision;
