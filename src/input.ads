generic
	type T is private;
	type Game is access T;

package Input is
	type Event is (RIGHT_TOUCH, LEFT_TOUCH, MIDDLE_TOUCH, BUTTON);
	type Callback_Access is not null access procedure (Handle : in out Game;
							   Weight : in Natural);
	procedure RegisterEvent(e : Event; callback : Callback_Access; Handle : Game);
	procedure Poll;
	procedure Initialize;
private
	procedure Dummy_Callback(Handle : in out Game; Weight : in Natural);
	type Event_Elt is record
		callback : Callback_Access := Dummy_Callback'Access;
		handle : Game;
	end record;
	type Events_Array is array (Event) of Event_Elt;
	procedure FireEvent(e : Event; Weight : Natural);
	function GetStateFromPosition(X, Y : Integer) return Event;
	Events_Handles : Events_Array := (others => (Dummy_Callback'Access, null));
end Input;
