with HAL.Bitmap; use HAL.Bitmap;

package body Game is

	procedure InitializeEnemies(Self : in out GameContext) is
		X : RangedPos := RangedPos'First;
		Y : RangedPos := RangedPos'First;
	begin
		for I in Self.enemies'Range loop
			Self.enemies(I).Init(X, Y);

			if X >= RangedPos'Last - ENEMY_STEP_W then
				X := RangedPos'First;
				Y := Y + ENEMY_STEP_H;
			else
				X := X + ENEMY_STEP_W;
			end if;
	 	end loop;
	end InitializeEnemies;

	procedure InitializePlayer(Self: in out GameContext) is
	begin
		Self.player.Init((Renderer.RangedPos'Last + Renderer.RangedPos'First) / 2,
				 Renderer.RangedPos'Last);
	end InitializePlayer;

	procedure InitializeParticles(Self: in out GameContext) is
	begin
		Self.lastParticleSpawn := clock;
		for P of Self.particles loop
			P.Dead;
		end loop;
	end InitializeParticles;

	procedure Initialize(Self: in out GameContext) is
	begin
		Self.InitializeEnemies;
		Self.InitializePlayer;
		Self.InitializeParticles;
	end;

	procedure UpdateEnemies(Self : in out GameAccess) is
		X, Y : RangedPos;
	begin
		for E of Self.enemies loop
			if E.IsAlive then
				X := E.GetX;
				Y := E.GetY;

				if X >= RangedPos'Last - ENEMY_SPEED then
					X := RangedPos'First;
					Y := Y + ENEMY_STEP_H;
				else
					X := X + ENEMY_SPEED;
				end if;

				E.SetPosition(X, Y);
				null;
			end if;
		end loop;
	end UpdateEnemies;

	procedure UpdateParticles(Self : in out GameAccess) is
	begin
		for P of Self.particles loop
			if P.IsAlive then
				if P.GetY = RangedPos'First then
					P.Dead;
				else
					P.SetPosition(P.GetX, P.GetY - 1);
				end if;

			end if;
		end loop;
	end UpdateParticles;

	procedure DrawFrame(Self : in out GameContext) is
	begin
		Renderer.Clear;

		for E of Self.enemies loop
			if E.IsAlive then
				Renderer.DrawEnemy(E.GetX, E.GetY);
			end if;
		end loop;

		for P of Self.particles loop
			if P.IsAlive then
				Renderer.DrawParticle(P.GetX, P.GetY);
			end if;
		end loop;

		Renderer.DrawPlayer(Self.player.GetX, Self.player.GetY);

		Renderer.Flip;
	end DrawFrame;

	procedure FireParticle(Self : in out GameContext) is
	begin
		-- particle fire rate is limited
		if Self.lastParticleSpawn + PARTICLE_FIRE_DELAY > clock then
			return;
		end if;

		for P of Self.particles loop
			if not P.IsAlive then
				P.Init(Self.player.GetX, Self.player.GetY);
				Self.lastParticleSpawn := clock;

				-- muzzle-flash effect
				Renderer.Fill(HAL.Bitmap.White);
				Renderer.Flip;
				exit;
			end if;
		end loop;
	end FireParticle;

	procedure PlayerMoveLeft(Self : in out GameContext) is
	begin
		if Self.player.GetX > Renderer.RangedPos'First then
			Self.player.SetPosition(Self.player.GetX - 1, Self.player.GetY);
		end if;
	end PlayerMoveLeft;

	procedure PlayerMoveRight(Self : in out GameContext) is
	begin
		if Self.player.GetX < Renderer.RangedPos'Last then
			Self.player.SetPosition(Self.player.GetX + 1, Self.player.GetY);
		end if;
	end PlayerMoveRight;

	function GameEnded(Self : in out GameContext) return Boolean is
	begin
		return not Self.player.IsAlive or
			   (for all E of Self.enemies => not E.IsAlive);
	end GameEnded;

	procedure HandleCollision(Self : in out GameContext;
				  A : in out Particle;
				  B : in out Enemy) is
	begin
		B.Dead;
		A.Dead;
		Self.score := Self.score + 1;
	end HandleCollision;

	procedure CollisionCallback(Self: in out GameContext;
				    A : in out Entity.Entity'Class;
				    B : in out Entity.Entity'Class) is
	begin
		if A in Particle'Class and B in Enemy'Class then
			Self.HandleCollision(Particle(A), Enemy(B));
		end if;
	end CollisionCallback;

end Game;
