package body Game is

	procedure InitializeEnemies(Self : in out GameContext) is
	begin
		for I in Self.enemies'Range loop
			Self.enemies(I) := (True, I * 2);
	 	end loop;
	end InitializeEnemies;

	procedure InitializePlayer(Self: in out GameContext) is
	begin
		Self.player.Y := Renderer.RangedPos'Last;
		Self.player.X := (Renderer.RangedPos'Last + Renderer.RangedPos'First) / 2;
		Self.player.Alive := True;
	end InitializePlayer;

	procedure InitializeParticles(Self: in out GameContext) is
	begin
		Self.lastParticleSpawn := clock;
		for P of Self.particles loop
			P.Alive := False;
		end loop;
	end InitializeParticles;

	procedure Initialize(Self: in out GameContext) is
	begin
		Self.InitializeEnemies;
		Self.InitializePlayer;
		Self.InitializeParticles;
	end;

	procedure UpdateEnemies(Self : in out GameAccess) is
	begin
		for E of Self.enemies loop
			if E.Alive then
				E.Pos := (E.Pos mod Renderer.CellId'Last) + 1;
			end if;
		end loop;
	end UpdateEnemies;

	procedure UpdateParticles(Self : in out GameAccess) is
	begin
		for P of Self.particles loop
			if P.Alive then
				if P.Y = RangedPos'First then
					P.Alive := False;
				else
					P.Y := P.Y - 1;
				end if;

			end if;
		end loop;
	end UpdateParticles;

	procedure DrawFrame(Self : in out GameContext) is
	begin
		Renderer.Clear;

		for E of Self.enemies loop
			if E.Alive then
				Renderer.DrawEnemy(E.Pos);
			end if;
		end loop;

		for P of Self.particles loop
			if P.Alive then
				Renderer.DrawParticle(P.X, P.Y);
			end if;
		end loop;

		Renderer.DrawPlayer(Self.player.X, Self.player.Y);

		Renderer.Flip;
	end DrawFrame;

end Game;
