with STM32.Board;     use STM32.Board;
with HAL.Touch_Panel; use HAL.Touch_Panel;
with Renderer;

package body Input is

	procedure RegisterEvent(e : Event; callback : Callback_Access; Handle : Game) is
	begin
		Events_Handles(e) := (callback, Handle);
	end RegisterEvent;

	-- Sorry about this, type correctness, you know..
	procedure Dummy_Callback(Handle : in out Game; Weight : in Natural) is
	begin
		null;
	end Dummy_Callback;

	procedure Trigger is
		State : TP_State := Touch_Panel.Get_All_Touch_Points;
	begin
		for E of State loop
			FireEvent(GetStateFromPosition(E.X, E.Y),
				  E.Weight);
		end loop;
	end Trigger;

	procedure Initialize is
	begin
		Touch_Panel.Initialize;
	end;

	procedure FireEvent(e : Event; Weight : Natural) is
	begin
		Events_Handles(e).callback(Events_Handles(e).handle, Weight);
	end;

	function GetStateFromPosition(X, Y : Integer) return Event is
	begin
		if Y < Renderer.SCREEN_HEIGHT / 2 then
			return MIDDLE_TOUCH;
		end if;
		if X < Renderer.SCREEN_WIDTH / 2 then
			return LEFT_TOUCH;
		end if;
		return RIGHT_TOUCH;
	end;

end Input;
