-module(chemistry).
-export([ch3ohf/3, o2f/2, ch3of/3, ho2f/2, ch3f/1, ho3f/1, react/2]).
-import(io, [format/1, format/2]).	

ch3ohf(0, o2, ch3o) ->
	receive 
		finished ->
			format("ch3oh number: ~w~n", [0])
	end;
	
ch3ohf(N, o2, ch3o) ->	
	o2 ! request,
	
	receive 
		finished ->
			format("CH3OH number: ~w~n", [N]);
		
		no ->
			ch3ohf(N, o2, ch3o);
		
		ok ->
			o2 ! add_h,
			ch3o ! add_ch3o,
			ch3ohf(N -1, o2, ch3o)	
	end.
	
o2f(0, ho2) ->
	receive
		finished ->
			format("O2 number: ~w~n", [0]);
			
		request ->
			ch3oh ! no,
			o2f(0, ho2)
	end;
	
o2f(N, ho2) ->
	receive
		finished ->
			format("O2 number: ~w~n", [N]);
			
		request ->
			ch3oh ! ok,
			o2f(N, ho2);
		
		add_h ->
			ho2 ! add_ho2,
			o2f(N - 1, ho2)
	end.
	
ch3of(0, ho2, ch3) ->
	receive
		finished ->
			format("CH3O number: ~w~n", [0]);
			
		add_ch3o ->
			ch3of(1, ho2, ch3)
	end;

ch3of(N, ho2, ch3) ->
	ho2 ! add_o,
	ch3 ! add_ch3,
	ch3of(N - 1, ho2, ch3),
	
	receive
		finished ->
			format("CH3O number: ~w~n", [N]);
			
		add_ch3o ->
			ch3of(N + 1, ho2, ch3)			
	end.

ho2f(0, ho3) ->
	receive
		finished ->
			format("ho2 number: ~w~n", [0]);
			
		add_ho2 ->
			ho2f(1, ho3)
			
	end;

ho2f(N, ho3) ->	
	receive 
		finished ->
			format("ho2 number: ~w~n", [N]);
			
		add_o ->
			ho3 ! add_ho3,
			ho2f(N - 1, ho3)
	end.
			

ch3f(0) ->
	receive
		finished ->
			format("CH3 number: ~w~n", [0]);
			
		add_ch3 ->
			ch3f(1)
	end;

ch3f(N) ->
	receive
		finished ->
			format("CH3 number: ~w~n", [N]);
			
		add_ch3 ->
			ch3f(N + 1)
	end.

ho3f(0) ->
	receive 
		finished ->
			format("HO3 number: ~w~n", [0]);
			
		add_ho3 ->
			ho3f(1)
	end;
	
ho3f(N) ->
	receive
		finished ->
			format("HO3 number: ~w~n", [N]);
			
		add_ho3 ->
			ho3f(N + 1)
	end.
	
react(X,Y) ->
	register(ch3, spawn(chemistry, ch3f, [0])),
	register(ho3, spawn(chemistry, ho3f, [0])),
	register(ho2, spawn(chemistry, ho2f, [0, ho3])),
	register(ch3o, spawn(chemistry, ch3of, [0, ho2, ch3])),
	register(o2, spawn(chemistry, o2f, [Y, ho2])),
	register(ch3oh, spawn(chemistry, ch3ohf, [X, o2, ch3o])),
	receive
		after 3000 ->
			ch3 ! ho3 ! ch3o ! ho2 ! o2 ! ch3oh ! finished 
	end.
	