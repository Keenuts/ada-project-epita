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

-- with STM32.Board;           use STM32.Board;
with HAL.Bitmap;
-- with STM32.User_Button;     use STM32;

with Ada.Real_Time; use Ada.Real_Time; -- for seconds
with Vec2; use Vec2;
with Renderer; use Renderer;
with Input;
with Timer;

procedure Main
is
	type Entity is record
		Pos : Renderer.CellId;
	end record;
	subtype EnemyEntity is Entity;

	type RangedEntity is record
		X : Renderer.RangedPos;
		Y : Renderer.RangedPos;
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
		particleCount : Natural;
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
	 	end loop;
	end InitializeEnemies;

	procedure InitializePlayer(ctx: in out GameAccess) is
	begin
		ctx.player.Y := Renderer.RangedPos'Last;
		ctx.player.X := (Renderer.RangedPos'Last + Renderer.RangedPos'First) / 2;
	end InitializePlayer;

	procedure UpdateEnemies(ctx : in out GameAccess) is
	begin
		for E of ctx.enemies loop
			E.Pos := (E.Pos mod Renderer.CellId'Last) + 1;
		end loop;
	end UpdateEnemies;

	procedure DrawFrame(ctx : in out GameAccess) is
	begin
		Renderer.Clear;

		for E of ctx.enemies loop
			Renderer.DrawEnemy(E.Pos);
		end loop;

		for I in 1 .. ctx.particleCount loop
			Renderer.DrawParticle(ctx.particles(I).X, ctx.particles(I).Y);
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
		p : ParticleEntity := (game.player.X, game.player.Y);
	begin
		-- particle instance count is limited
		if game.ParticleCount >= MAX_PARTICLE_COUNT - 1 then
			return;
		end if;

		-- particle fire rate is limited
		if game.lastParticleSpawn + PARTICLE_FIRE_DELAY > clock then
			return;
		end if;

		-- particle registration
		game.ParticleCount := game.ParticleCount + 1;
		game.Particles(game.ParticleCount) := p;
		game.lastParticleSpawn := clock;

		-- muzzle-flash effect
		Renderer.Fill(HAL.Bitmap.White);
		Renderer.Flip;
	end;
begin
	Renderer.Initialize;
	Input_GameAccess.Initialize;
	Timer_GameAccess.Initialize;

	InitializeEnemies(game);
	InitializePlayer(game);

	Input_GameAccess.RegisterEvent(RIGHT_TOUCH, RightTouch'Access, game);
	Input_GameAccess.RegisterEvent(LEFT_TOUCH, LeftTouch'Access, game);
	Input_GameAccess.RegisterEvent(MIDDLE_TOUCH, MiddleTouch'Access, game);

	Timer_GameAccess.RegisterInterval(Seconds(1), UpdateEnemies'Access, game);

	loop
		Input_GameAccess.Poll;
		Timer_GameAccess.Poll;

		DrawFrame(game);
	end loop;
end Main;
