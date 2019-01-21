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

	function CollideParticle(ctx : in out GameAccess; P : in RangedEntity'Class) return Boolean is
		A, B : Rect;
	begin
		for E of ctx.enemies loop
			if E.Alive then
				A := E.getAABB;
				B := P.getAABB;
				if CollideAABB(A, B) then
					E.Alive := False;
					return True;
				end if;
			end if;
		end loop;
		return False;
	end CollideParticle;

	procedure CollideParticles(ctx : in out GameAccess) is
	begin
		for P of ctx.particles loop
			if P.Alive then
				if CollideParticle(ctx, P) then
					P.Alive := False;
				end if;
			end if;
		end loop;
	end CollideParticles;

end Collision;
