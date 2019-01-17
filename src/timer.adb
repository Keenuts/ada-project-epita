with Ada.Real_Time; use Ada.Real_Time;

package body Timer is
	procedure Initialize is
	begin
		null;
	end;


	procedure RegisterInterval(IntervalTime : Time_Span; Callback : Callback_Access; Handle : Game) is
	begin
		FirstValidHandler := FirstValidHandler + 1;

		Handlers(FirstValidHandler) := (
			Callback,
			Handle,
			IntervalTime,
			Clock - IntervalTime
		);
	end RegisterInterval;


	procedure Poll is
		now : Time := Clock;
	begin
		for H of Handlers loop
			if H.TriggerDelay < now - H.LastTrigger then
				H.Callback(H.Handle);
				H.LastTrigger := Clock;
			end if;
		end loop;
	end Poll;

	-- Sorry about this, type correctness, you know..
	procedure Dummy_Callback(Handle : in out Game) is
	begin
		null;
	end Dummy_Callback;
end Timer;
