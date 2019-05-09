-module(chemistry).
-export([ch3oh/3, o2/2, ch3o/1, ho2/1, react/2]).
-import(io, [format/1, format/2]).	

ch3oh(0, O2_PID, CH3O_PID) ->
	O2_PID ! finished,
	CH3O_PID ! finished,
	format("ch3oh number: ~w~n", [0]);
	
ch3oh(N, O2_PID, CH3O_PID) ->
	O2_PID ! {h, self()},
	CH3O_PID ! ch3o,
	ch3oh(N-1, O2_PID, CH3O_PID).
	
o2(0, HO2_PID) ->
	HO2_PID ! finished,
	
	receive
		finished ->
			format("O2 number: ~w~n", [0])
	end;
	
o2(N, HO2_PID) ->
	receive
		finished ->
			format("O2 number: ~w~n", [N]),
			HO2_PID ! finished;
			
		{h, CH3OH_PID} ->
			HO2_PID ! ho2,
			o2(N-1, HO2_PID)
	end.
	
ch3o(0) ->
	receive
		finished ->
			format("CH3O number: ~w~n", [0]);
			
		ch3o ->
			ch3o(1)
	end;

ch3o(N) ->
	receive
		finished ->
			format("CH3O number: ~w~n", [N]);
			
		ch3o ->
			ch3o(N + 1)
	end.

ho2(0) ->
	receive
		finished ->
			format("HO2 number: ~w~n", [0]);
			
		ho2 ->
			ho2(1)
	end;

ho2(N) ->
	receive 
		finished ->
			format("HO2 number: ~w~n", [N]);
			
		ho2 ->
			ho2(N + 1)
	end.
			
	
react(X,Y) ->
	HO2_PID = spawn(chemistry, ho2, [0]),
	CH3O_PID = spawn(chemistry, ch3o, [0]),
	O2_PID = spawn(chemistry, o2, [Y, HO2_PID]),
	spawn(chemistry, ch3oh, [X, O2_PID, CH3O_PID]).