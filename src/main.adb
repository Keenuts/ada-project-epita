------------------------------------------------------------------------------
--                                                                          --
--                     Copyright (C) 2015-2016, AdaCore                     --
--                                                                          --
--  Redistribution and use in source and binary forms, with or without      --
--  modification, are permitted provided that the following conditions are  --
--  met:                                                                    --
--     1. Redistributions of source code must retain the above copyright    --
--        notice, this list of conditions and the following disclaimer.     --
--     2. Redistributions in binary form must reproduce the above copyright --
--        notice, this list of conditions and the following disclaimer in   --
--        the documentation and/or other materials provided with the        --
--        distribution.                                                     --
--     3. Neither the name of the copyright holder nor the names of its     --
--        contributors may be used to endorse or promote products derived   --
--        from this software without specific prior written permission.     --
--                                                                          --
--   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS    --
--   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT      --
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR  --
--   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT   --
--   HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, --
--   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT       --
--   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,  --
--   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY  --
--   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT    --
--   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE  --
--   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.   --
--                                                                          --
------------------------------------------------------------------------------

with Last_Chance_Handler;  pragma Unreferenced (Last_Chance_Handler);
--  The "last chance handler" is the user-defined routine that is called when
--  an exception is propagated. We need it in the executable, therefore it
--  must be somewhere in the closure of the context clauses.

pragma Warnings (Off, "referenced");
with Ada.Numerics.Elementary_Functions; use Ada.Numerics.Elementary_Functions;
with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;
with Ada.Exceptions; use Ada.Exceptions;

-- with STM32.Board;           use STM32.Board;
with HAL.Bitmap; use HAL.Bitmap;
with LCD_Std_Out;
-- with STM32.User_Button;     use STM32;

with Ada.Real_Time; use Ada.Real_Time; -- for seconds
with Vec2; use Vec2;
with Renderer; use Renderer;
with Input;
with Timer;

procedure Main
is
	-- FIXME: implement me as a class, and inherit with RangedEntity
	type Entity is record
		Pos : Renderer.CellId;
		Alive : Boolean;
	end record;
	subtype EnemyEntity is Entity;

	type RangedEntity is record
		X : Renderer.RangedPos;
		Y : Renderer.RangedPos;
		Alive : Boolean;
	end record;
	subtype PlayerEntity is RangedEntity;

	subtype ParticleEntity is RangedEntity;

	MAX_ENEMY_COUNT : constant CellId := 7;
	type EnemiesArray is array(CellId range 1 .. MAX_ENEMY_COUNT) of EnemyEntity;

	MAX_PARTICLE_COUNT : constant Natural := 10;
	type ParticleArray is array(Natural range 1 .. MAX_PARTICLE_COUNT) of ParticleEntity;
	
	PARTICLE_FIRE_DELAY : constant Time_Span := Seconds(1);
	type GameContext is record
		enemies : EnemiesArray;

		particles : ParticleArray;
		lastParticleSpawn : Time;

		player : PlayerEntity;
		score : Natural;
	end record;
	type GameAccess is access GameContext;

	game : GameAccess := new GameContext;



	package Input_GameAccess is new Input(GameContext, GameAccess); use Input_GameAccess;
	package Timer_GameAccess is new Timer(GameContext, GameAccess); use Timer_GameAccess;

	procedure InitializeEnemies(ctx : in out GameAccess) is
	begin
		for I in ctx.enemies'Range loop
			ctx.enemies(I).Pos := I * 2;
			ctx.enemies(I).Alive := True;
	 	end loop;
	end InitializeEnemies;

	procedure InitializePlayer(ctx: in out GameAccess) is
	begin
		ctx.player.Y := Renderer.RangedPos'Last;
		ctx.player.X := (Renderer.RangedPos'Last + Renderer.RangedPos'First) / 2;
		ctx.player.Alive := True;
	end InitializePlayer;

	procedure UpdateEnemies(ctx : in out GameAccess) is
	begin
		for E of ctx.enemies loop
			if E.Alive then
				E.Pos := (E.Pos mod Renderer.CellId'Last) + 1;
			end if;
		end loop;
	end UpdateEnemies;

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

	function RangedEntityToAABB(E : in RangedEntity; Size : in Natural) return Rect is
		PX, PY : Float;
	begin
		-- project to frustrum-space coordinates
		PX := Float(E.X) / Float(RangedPos'Last);
		PY := Float(E.Y) / Float(RangedPos'Last);
		PX := PX * Float(SCREEN_WIDTH);
		PY := PY * Float(SCREEN_HEIGHT);

		return ((Natural(PX), Natural(PY)), Size, Size);
	end RangedEntityToAABB;

	function EnemyToAABB(E : in Entity) return Rect is
		X, Y : Natural;
	begin
		X := (Natural(E.Pos) - 1) mod GRID_WIDTH;
		Y := (Natural(E.Pos) - 1) / GRID_HEIGHT;
		X := X * CELL_SIZE;
		Y := Y * CELL_SIZE;
		
		-- FIXME: fix the radius render of the enemy.
		return ((X, Y), CELL_SIZE, CELL_SIZE);
	end EnemyToAABB;

	function CollideParticle(ctx : in out GameAccess; P : in RangedEntity) return Boolean is
		A, B : Rect;
	begin
		for E of ctx.enemies loop
			if E.Alive then
				A := EnemyToAABB(E);
				B := RangedEntityToAABB(P, PARTICLE_SIZE);
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

	procedure UpdateParticles(ctx : in out GameAccess) is
	begin
		for P of ctx.particles loop
			if P.Alive then
				if P.Y = RangedPos'First then
					P.Alive := False;
				else
					P.Y := P.Y - 1;
				end if;

			end if;
		end loop;
	end UpdateParticles;

	procedure DrawFrame(ctx : in out GameAccess) is
	begin
		Renderer.Clear;

		for E of ctx.enemies loop
			if E.Alive then
				Renderer.DrawEnemy(E.Pos);
			end if;
		end loop;

		for P of ctx.particles loop
			if P.Alive then
				Renderer.DrawParticle(P.X, P.Y);
			end if;
		end loop;

		Renderer.DrawPlayer(ctx.player.X, ctx.player.Y);

		Renderer.Flip;
	end DrawFrame;

	procedure RightTouch(game : in out GameAccess; Weight : in Natural) is
	begin
		if game.player.X < Renderer.RangedPos'Last then
			game.player.X := game.player.X + 1;
		end if;
	end;

	procedure LeftTouch(game : in out GameAccess; Weight : in Natural) is
	begin
		if game.player.X > Renderer.RangedPos'First then
			game.player.X := game.player.X - 1;
		end if;
	end;

	procedure MiddleTouch(game : in out GameAccess; Weight : in Natural) is
	begin
		-- particle fire rate is limited
		if game.lastParticleSpawn + PARTICLE_FIRE_DELAY > clock then
			return;
		end if;

		for P of game.particles loop
			if not P.Alive then
				P := (game.player.X, game.player.Y, True);
				game.lastParticleSpawn := clock;

				-- muzzle-flash effect
				Renderer.Fill(HAL.Bitmap.White);
				Renderer.Flip;
				exit;
			end if;
		end loop;
	end;

	function min(A, B: Natural) return Natural is
	begin
		if A < B then
			return A;
		else
			return B;
		end if;
	end min;

begin
	Renderer.Initialize;
	Input_GameAccess.Initialize;
	Timer_GameAccess.Initialize;

	-- FIXME: initialize game correctly
	-- Reset does not seem to reset the lastParticleSpawm var (maybe RAM is left)
	game.lastParticleSpawn := clock;
	For P of game.particles loop
		P.Alive := False;
	end loop;

	InitializeEnemies(game);
	InitializePlayer(game);

	Input_GameAccess.RegisterEvent(RIGHT_TOUCH, RightTouch'Access, game);
	Input_GameAccess.RegisterEvent(LEFT_TOUCH, LeftTouch'Access, game);
	Input_GameAccess.RegisterEvent(MIDDLE_TOUCH, MiddleTouch'Access, game);

	Timer_GameAccess.RegisterInterval(Seconds(1), UpdateEnemies'Access, game);
	Timer_GameAccess.RegisterInterval(Milliseconds(50), UpdateParticles'Access, game);

	loop
		Input_GameAccess.Poll;
		Timer_GameAccess.Poll;

		CollideParticles(game);
		DrawFrame(game);
	end loop;
exception
	when Error: others =>
		declare
			Msg : String := Exception_Information(Error);
			Left : Natural := 1;
			Right : Natural := 1;
			Y : Natural := 0;
		begin
			while Right < Msg'Length loop
				Right := min(Left + 30, Msg'Last);
				LCD_Std_Out.Put(0, Y, Msg(Left .. Right));
				Left := Right;
				Y := Y + 10;
			end loop;
		end;
		
		LCD_Std_Out.Put(0, 30, Exception_Information(Error)(50 .. 75));
		loop
			null;
		end loop;
end Main;
