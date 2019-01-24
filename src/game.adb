with HAL.Bitmap; use HAL.Bitmap;
with Ada.Numerics.Discrete_Random;

package body Game is

	procedure InitializeEnemies(Self : in out GameContext) is
		X : RangedPos := RangedPos'First;
		Y : RangedPos := RangedPos'First;
	begin
		for I in Self.enemies'Range loop
			Self.enemies(I).Init(X, Y, ENEMY_SPRITE_SIZE);

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
		Self.player.Init(
			(Renderer.RangedPos'Last + Renderer.RangedPos'First) / 2,
			Renderer.RangedPos'Last,
			PLAYER_SPRITE_SIZE
		);
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
		X, Y : Renderer.RangedPos;
	begin
		for P of Self.particles loop
			if P.IsAlive then
				if P.GetY = RangedPos'First or else
				   P.GetY = RangedPos'Last then
					P.Dead;
				else
					X := Renderer.RangedPos(Float(P.GetX) +
						Float'Floor(P.GetDirection.X));
					Y := Renderer.RangedPos(Float(P.GetY) +
						Float'Floor(P.GetDirection.Y));
					P.SetPosition(X, Y);
				end if;

			end if;
		end loop;
	end UpdateParticles;

	procedure DrawFrame(Self : in out GameContext) is
	begin
		Renderer.Clear;

		for E of Self.enemies loop
			if E.IsAlive then
				Renderer.Draw_Enemy(E.GetX, E.GetY);
			end if;
		end loop;

		for P of Self.particles loop
			if P.IsAlive then
				Renderer.Draw_Particle(P.GetX, P.GetY);
			end if;
		end loop;

		Renderer.Draw_Player(Self.player.GetX, Self.player.GetY);

		Renderer.Flip;
	end DrawFrame;

	function Transform_RangedPos(
		P : in RangedPos;
		SizeA, SizeB : in Positive
	) return RangedPos
	is
		PX : Float;
	begin
		-- project to frustrum-space coordinates
		PX := Float(P) / Float(RANGED_POS_LEN);
		-- convert to screen-space coordinated
		PX := PX * Float(SCREEN_WIDTH - SizeA);
		PX := PX + Float(SizeA) * 0.5;
		PX := PX / Float(SCREEN_WIDTH - SizeB);
		PX := PX * Float(RANGED_POS_LEN);

		return RangedPos(PX);
	end Transform_RangedPos;

	procedure PlayerShoot(Self : in out GameContext) is
	begin
		-- particle fire rate is limited
		if Self.lastParticleSpawn + PARTICLE_FIRE_DELAY > clock then
			return;
		end if;

		for P of Self.particles loop
			if not P.IsAlive then
				P.Init(
					Transform_RangedPos(Self.player.GetX, PLAYER_SPRITE_SIZE, PARTICLE_SIZE),
					Transform_RangedPos(Self.player.GetY, PLAYER_SPRITE_SIZE, PARTICLE_SIZE),
					PARTICLE_SIZE,
					True,
					(0.0, -1.0)
				);
				Self.lastParticleSpawn := clock;

				-- muzzle-flash effect
				Renderer.Fill(HAL.Bitmap.White);
				Renderer.Flip;
				exit;
			end if;
		end loop;
	end PlayerShoot;

	procedure RandomEnemyShoot(Self : in out GameAccess) is
		package Rand is new Ada.Numerics.Discrete_Random(EnemyRange);
		Gen : Rand.Generator;
		E : Enemy;
	begin
		Rand.Reset(Gen);
		loop
			E := Self.enemies(Rand.Random(Gen));
			exit when E.IsAlive;
		end loop;
		for P of Self.particles loop
			if not P.IsAlive then
				P.Init(
					Transform_RangedPos(E.GetX, ENEMY_SPRITE_SIZE, PARTICLE_SIZE),
					Transform_RangedPos(E.GetY, ENEMY_SPRITE_SIZE, PARTICLE_SIZE),
					PARTICLE_SIZE,
					False,
					(0.0, 1.0)
				);
				exit;
			end if;
		end loop;
	end RandomEnemyShoot;

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
		if not A.IsPlayer then
			return;
		end if;
		B.Dead;
		A.Dead;
		Self.score := Self.score + 1;
	end HandleCollision;

	procedure HandleCollision(Self : in out GameContext;
				  A : in out Particle;
				  B : in out Player) is
	begin
		if A.IsPlayer then -- Should never happend
			return;
		end if;
		B.Dead;
		A.Dead;
	end HandleCollision;

	procedure HandleCollision(Self : in out GameContext;
				  A : in out Player;
				  B : in out Enemy) is
	begin
		A.Dead;
	end HandleCollision;

	procedure CollisionCallback(Self: in out GameContext;
				    A : in out Entity.Entity'Class;
				    B : in out Entity.Entity'Class) is
	begin
		if A in Particle'Class and B in Enemy'Class then
			Self.HandleCollision(Particle(A), Enemy(B));
		end if;
		if A in Player'Class and B in Enemy'Class then
			Self.HandleCollision(Player(A), Enemy(B));
		end if;
		if A in Particle'Class and B in Player'Class then
			Self.HandleCollision(Particle(A), Player(B));
		end if;
	end CollisionCallback;
end Game;
