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
with Entity; use Entity;
with Game; use Game;
with Collision; use Collision;

procedure Main
is
	game : GameAccess := new GameContext;

	package Input_GameAccess is new Input(GameContext, GameAccess); use Input_GameAccess;
	package Timer_GameAccess is new Timer(GameContext, GameAccess); use Timer_GameAccess;

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
				P := (True, game.player.X, game.player.Y);
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

	game.Initialize;

	Input_GameAccess.RegisterEvent(RIGHT_TOUCH, RightTouch'Access, game);
	Input_GameAccess.RegisterEvent(LEFT_TOUCH, LeftTouch'Access, game);
	Input_GameAccess.RegisterEvent(MIDDLE_TOUCH, MiddleTouch'Access, game);

	Timer_GameAccess.RegisterInterval(Seconds(1), UpdateEnemies'Access, game);
	Timer_GameAccess.RegisterInterval(Milliseconds(50), UpdateParticles'Access, game);

	loop
		Input_GameAccess.Poll;
		Timer_GameAccess.Poll;

		CollideParticles(game);
		game.DrawFrame;
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
