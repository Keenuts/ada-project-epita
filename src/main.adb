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
with HAL.Touch_Panel;       use HAL.Touch_Panel;
with HAL.Bitmap;
-- with STM32.User_Button;     use STM32;

with Vec2; use Vec2;
with Renderer; use Renderer;
with Input;

procedure Main
is
	-- MAX_OBJ_COUNT : constant Integer := 10; -- seems OK for now.
	-- Cell : array(CellId) of ObjectId;
	-- Gen : Ada.Numerics.Float_Random.Generator;
	-- type ObjectId is range 1 .. MAX_OBJ_COUNT;

	-- procedure InitializeBoard is
	-- begin
	-- 	--  Initialize touch panel
	-- 	Touch_Panel.Initialize;

	-- 	--  Initialize button
	-- 	User_Button.Initialize;
	-- end InitializeBoard;

	type Entity is record
		Pos : Renderer.CellId;
	end record;

	subtype Enemy is Entity;
	subtype Player is Entity;

	enemies : array(CellId range 1 .. 7) of Enemy;

	procedure InitEnemies is
	begin
		for i in enemies'Range loop
			enemies(i).Pos := i * 2;
		end loop;
	end InitEnemies;

	procedure UpdateEnemies is
	begin
		for i in enemies'Range loop
			enemies(i).Pos := (enemies(i).Pos mod Renderer.CellId'Last) + 1;
		end loop;
	end UpdateEnemies;

	procedure DrawFrame is
	begin
		Renderer.Clear;
		for i in enemies'Range loop
			Renderer.DrawEnemy(enemies(i).Pos);
		end loop;
		Renderer.Flip;
	end DrawFrame;
	switch : Boolean := false;
	type Tamere is access Vector;
	package Input_Vector is new Input(Vector, Tamere); use Input_Vector;
	V : Tamere := null;
	procedure RightTouch(toto : in out Tamere; Weight : in Natural) is
	begin
		Renderer.Fill(HAL.Bitmap.Red);
		Renderer.Flip;
	end;
	procedure LeftTouch(toto : in out Tamere; Weight : in Natural) is
	begin
		Renderer.Fill(HAL.Bitmap.Blue);
		Renderer.Flip;
	end;
	procedure MiddleTouch(toto : in out Tamere; Weight : in Natural) is
	begin
		Renderer.Fill(HAL.Bitmap.Green);
		Renderer.Flip;
	end;
begin
	Renderer.Initialize;
	-- InitializeBoard;

	-- InitEnemies;

	-- loop

	-- 	UpdateEnemies;
	-- 	DrawFrame;

	-- 	delay 2.0;
	Input_Vector.Initialize;
	Renderer.Clear;
	Input_Vector.RegisterEvent(RIGHT_TOUCH, RightTouch'Access, V);
	Input_Vector.RegisterEvent(LEFT_TOUCH, LeftTouch'Access, V);
	Input_Vector.RegisterEvent(MIDDLE_TOUCH, MiddleTouch'Access, V);
	loop
		Input_Vector.Trigger;
		-- if User_Button.Has_Been_Pressed then
		-- 	color := HAL.Bitmap.Red;
		-- end if;

		-- declare
		--     State : constant TP_State := Touch_Panel.Get_All_Touch_Points;
		-- begin
		-- 	case State'Length is
		-- 	when 0 =>
		-- 		color := HAL.Bitmap.Blue;
		-- 	when 1 =>
		-- 		color := HAL.Bitmap.Green;
	        -- 	when others =>
		-- 		color := HAL.Bitmap.Purple;
		-- 	end case;
		-- end;

		-- Renderer.Clear;

		-- for i in Renderer.CellId'Range loop
		-- 	Renderer.DrawPlayer(i);
		-- end loop;

		-- -- Renderer.DrawPlayer(22);
		-- Renderer.Flip;
	end loop;
end Main;
