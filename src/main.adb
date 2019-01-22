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
with Game; use Game;
with Collision; use Collision;

procedure Main
is
	game : GameAccess := new GameContext;

	package Input_GameAccess is new Input(GameContext, GameAccess); use Input_GameAccess;
	package Timer_GameAccess is new Timer(GameContext, GameAccess); use Timer_GameAccess;

	procedure RightTouch(game : in out GameAccess; Weight : in Natural) is
	begin
		game.PlayerMoveRight;
	end;

	procedure LeftTouch(game : in out GameAccess; Weight : in Natural) is
	begin
		game.PlayerMoveLeft;
	end;

	procedure MiddleTouch(game : in out GameAccess; Weight : in Natural) is
	begin
		game.FireParticle;
	end;
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

	while not game.GameEnded loop
		Input_GameAccess.Poll;
		Timer_GameAccess.Poll;

		CollideObjects(game);
		game.DrawFrame;
	end loop;
exception
	when Error: others =>
		declare
			Msg : String := Exception_Information(Error);
			Left : Natural := 1;
			Right : Natural := 1;
			Y : Natural := 0;

			function min(A, B: Natural) return Natural is
			begin
				if A < B then
					return A;
				else
					return B;
				end if;
			end min;
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
