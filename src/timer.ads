with Ada.Real_Time; use Ada.Real_Time;

generic
	type T is private;
	type Game is access T;

package Timer is
	type Callback_Access is not null access procedure (Handle : in out Game);

	procedure Initialize;
	procedure RegisterInterval(IntervalTime : Time_Span; callback : Callback_Access; Handle : Game);
	procedure Poll;

private
	procedure Dummy_Callback(Handle : in out Game);

	type Handlers_Elt is record
		Callback : Callback_Access := Dummy_Callback'Access;
		Handle : Game;
		TriggerDelay : Time_Span;
		LastTrigger : Time;
	end record;

	type HandlerId is range 1 .. 100;
	type HandlersArray is array (HandlerId) of Handlers_Elt;

	Handlers : HandlersArray := (others => (Dummy_Callback'Access, null, Clock - Clock, Clock));
	FirstValidHandler : HandlerId := 1;
end Timer;
