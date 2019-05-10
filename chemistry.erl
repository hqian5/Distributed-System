-module(chemistry).
-export([ch3ohf/3, o2f/5, ch3of/3, ho2f/2, ch3f/3, ho3f/3, co2f/1, h3f/3, h2f/1, h2o3f/1, react/2]).
-import(io, [format/1, format/2]).	

ch3ohf(0, o2, ch3o) ->
	receive 
		finished ->
			format("CH3OH number: ~w~n", [0])
	end;
	
ch3ohf(N, o2, ch3o) ->	
	o2 ! ch3oh_request,
	
	receive 
		finished ->
			format("CH3OH number: ~w~n", [N]);
		
		no_ch3oh ->
			ch3ohf(N, o2, ch3o);
		
		ok_ch3oh ->
			o2 ! add_h,
			ch3o ! add_ch3o,
			ch3ohf(N -1, o2, ch3o)	
	end.
	
o2f(0, ho2, ch3oh, ch3, co2) ->
	receive
		finished ->
			format("O2 number: ~w~n", [0]);
			
		ch3oh_request ->
			ch3oh ! no_ch3oh,
			o2f(0, ho2, ch3oh, ch3, co2);
		
		ch3_request ->
			ch3 ! no_ch3,
			o2f(0, ho2, ch3oh, ch3, co2)
	end;
	
o2f(N, ho2, ch3oh, ch3, co2) ->
	receive
		finished ->
			format("O2 number: ~w~n", [N]);
			
		ch3oh_request ->
			ch3oh ! ok_ch3oh,
			o2f(N, ho2, ch3oh, ch3, co2);
		
		add_h ->
			ho2 ! add_ho2,
			o2f(N - 1, ho2, ch3oh, ch3, co2);
		
		ch3_request ->
			ch3 ! ok_ch3,
			o2f(N, ho2, ch3oh, ch3, co2);
		
		c ->
			co2 ! add_co2,
			o2f(N - 1, ho2, ch3oh, ch3, co2)
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
			

ch3f(0, o2, h3) ->
	receive
		finished ->
			format("CH3 number: ~w~n", [0]);
			
		add_ch3 ->
			ch3f(1, o2, h3)
	end;

ch3f(N, o2, h3) ->
	o2 ! ch3_request,
	
	receive
		finished ->
			format("CH3 number: ~w~n", [N]);
			
		add_ch3 ->
			ch3f(N + 1, o2, h3);
			
		no_ch3 ->
			ch3f(N, o2, h3);
		
		ok_ch3 ->
			o2 ! c,
			h3 ! add_h3,
			ch3f(N - 1, o2, h3)
	end.

ho3f(0, h3, h2o3) ->
	receive 
		finished ->
			format("HO3 number: ~w~n", [0]);
			
		add_ho3 ->
			ho3f(1, h3, h2o3);
			
		h3_request ->
			ho3 ! no_h3,
			ho3f(0, h3, h2o3)
	end;
	
ho3f(N, h3, h2o3) ->
	receive
		finished ->
			format("HO3 number: ~w~n", [N]);
			
		add_ho3 ->
			ho3f(N + 1, h3, h2o3);
			
		h3_request ->
			h3 ! ok_h3,
			ho3f(N, h3, h2o3);
		
		add_h ->
			h2o3 ! add_h2o3,
			ho3f(N - 1, h3, h2o3)
	end.

co2f(0) ->
	receive 
		finished ->
			format("CO2 number: ~w~n", [0]);
			
		add_co2 ->
			co2f(1)
	end;

co2f(N) ->
	receive
		finished ->
			format("CO2 number: ~w~n", [N]);
			
		add_co2 ->
			co2f(N + 1)
	end.
	
h3f(0, ho3, h2) ->
	receive
		finished ->
			format("H3 number: ~w~n", [0]);
			
		add_h3 ->
			h3f(1, ho3, h2)
	end;
	
h3f(N, ho3, h2) ->
	ho3 ! h3_request,
	
	receive
		finished ->
			format("H3 number: ~w~n", [N]);
			
		add_h3 ->
			h3f(N + 1, ho3, h2);
			
		no_h3 ->
			ho3f(N, ho3, h2);
			
		ok_h3 ->
			ho3 ! add_h,
			h2 ! add_h2,
			h3f(N - 1, ho3, h2)
	end.

h2f(0) ->
	receive
		finished ->
			format("H2 number: ~w~n", [0]);
			
		add_h2 ->
			h2f(1)
	end;
	
h2f(N) ->

	receive
		finished ->
			format("H2 number: ~w~n", [N]);
			
		add_h2 ->
			h2f(N + 1)
	end.

h2o3f(0) ->
	receive
		finished ->
			format("H2O3 number: ~w~n", [0]);
		
		add_h2o3 ->
			h2o3f(1)
	end;

h2o3f(N) ->
	receive 
		finished ->
			format("H2O3 number: ~w~n", [N]);
			
		add_h2o3 ->
			h2o3f(N + 1)
	end.
		
react(X,Y) ->

	register(h2o3, spawn(chemistry, h2o3f, [0])),
	register(h2, spawn(chemistry, h2f, [0])),
	register(h3, spawn(chemistry, h3f, [0, ho3, h2])),
	register(co2, spawn(chemistry, co2f, [0])),
	register(ch3, spawn(chemistry, ch3f, [0, o2, h3])),
	register(ho3, spawn(chemistry, ho3f, [0, h3, h2o3])),
	register(ho2, spawn(chemistry, ho2f, [0, ho3])),
	register(ch3o, spawn(chemistry, ch3of, [0, ho2, ch3])),
	register(o2, spawn(chemistry, o2f, [Y, ho2, ch3oh, ch3, co2])),
	register(ch3oh, spawn(chemistry, ch3ohf, [X, o2, ch3o])),
	
	receive
		after 3000 ->
			h2o3 ! h2 ! h3 ! co2 ! ch3 ! ho3 ! ch3o ! ho2 ! o2 ! ch3oh ! finished 
	end.
	