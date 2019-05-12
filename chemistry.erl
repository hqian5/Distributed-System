%Module for simulating chemistry
%Main function is react(X, Y)
%parameters: X: input a number for Methanol molecules; Y: input a number for Oxygen molecules
-module(chemistry).
-export([ch3ohf/3, o2f/5, ch3of/3, ho2f/3, ch3f/5, ho3f/3, co2f/1, h3f/3, h2f/3, h2o3f/3, h2o2f/4, h2of/1, oof/1, react/2]).
-import(io, [format/1, format/2]).	

%Atmos: finished: stop function; add_x: add one x(atom); add_xxx: add one xxx(molecule); 
%		xxx_request: send communication request; no_xxx: refuse request; ok_xxx: accept request
%Parameters: N: number of a molecule; xxx: XXX_PID

%Function for CH3OH
ch3ohf(0, o2, ch3o) ->
	receive 
		finished ->
			format("CH3OH number: ~w~n", [0]);
		
		add_ch3oh ->
			ch3ohf(1, o2, ch3o)
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
			ch3ohf(N -1, o2, ch3o);
		
		add_ch3oh ->
			ch3ohf(N + 1, o2, ch3o)
	end.

%Function for O2
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
		
		add_c ->
			co2 ! add_co2,
			o2f(N - 1, ho2, ch3oh, ch3, co2)
	end.

%Function for CH3O	
ch3of(0, ho2, ch3) ->
	receive
		finished ->
			format("CH3O number: ~w~n", [0]);
			
		add_ch3o ->
			ch3of(1, ho2, ch3)
	end;

ch3of(N, ho2, ch3) ->
	ho2 ! ch3o_request,
	
	receive
		finished ->
			format("CH3O number: ~w~n", [N]);
			
		add_ch3o ->
			ch3of(N + 1, ho2, ch3);
			
		no_ch3o ->
			ch3of(N, ho2, ch3);
		
		ok_ch3o ->
			ho2 ! add_o,
			ch3 ! add_ch3,
			ch3of(N - 1, ho2, ch3)			
	end.

%Function for HO2
ho2f(0, ch3o, ho3) ->
	receive
		finished ->
			format("HO2 number: ~w~n", [0]);
			
		add_ho2 ->
			ho2f(1, ch3o, ho3);
		
		ch3o_request ->
			ch3o ! no_ch3o,
			ho2f(0, ch3o, ho3)
			
	end;

ho2f(N, ch3o, ho3) ->	
	receive 
		finished ->
			format("HO2 number: ~w~n", [N]);
			
		ch3o_request ->
			ch3o ! ok_ch3o,
			ho2f(N, ch3o, ho3);
			
		add_o ->
			ho3 ! add_ho3,
			ho2f(N - 1, ch3o, ho3)
	end.
			
%Function for CH3
ch3f(0, o2, h3, h2o2, ch3o) ->
	receive
		finished ->
			format("CH3 number: ~w~n", [0]);
			
		add_ch3 ->
			ch3f(1, o2, h3, h2o2, ch3o);
		
		h2o2_request ->
			h2o2 ! no_h2o2,
			ch3f(0, o2, h3, h2o2, ch3o)
	end;

ch3f(N, o2, h3, h2o2, ch3o) ->
	o2 ! ch3_request,
	
	receive
		finished ->
			format("CH3 number: ~w~n", [N]);
			
		add_ch3 ->
			ch3f(N + 1, o2, h3, h2o2, ch3o);
			
		no_ch3 ->
			ch3f(N, o2, h3, h2o2, ch3o);
		
		ok_ch3 ->
			o2 ! add_c,
			h3 ! add_h3,
			ch3f(N - 1, o2, h3, h2o2, ch3o);
		
		h2o2_request ->
			h2o2 ! ok_h2o2,
			ch3f(N, o2, h3, h2o2, ch3o);
		
		add_o ->
			ch3o ! add_ch3o,
			ch3f(N -1, o2, h3, h2o2, ch3o)
	end.

%Function for HO3
ho3f(0, h3, h2o3) ->
	receive 
		finished ->
			format("HO3 number: ~w~n", [0]);
			
		add_ho3 ->
			ho3f(1, h3, h2o3);
			
		h3_request ->
			h3 ! no_h3,
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

%Function for CO2
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

%Function for H3	
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
			h3f(N, ho3, h2);
			
		ok_h3 ->
			ho3 ! add_h,
			h2 ! add_h2,
			h3f(N - 1, ho3, h2)
	end.

%Function for H2
h2f(0, h2o3, h2o) ->
	receive
		finished ->
			format("H2 number: ~w~n", [0]);
			
		add_h2 ->
			h2f(1, h2o3, h2o);
			
		h2o3_request ->
			h2o3 ! no_h2o3,
			h2f(0, h2o3, h2o)
	end;
	
h2f(N, h2o3, h2o) ->
	receive
		finished ->
			format("H2 number: ~w~n", [N]);
			
		add_h2 ->
			h2f(N + 1, h2o3, h2o);
		
		h2o3_request ->
			h2o3 ! ok_h2o3,
			h2f(N, h2o3, h2o);
		
		add_o ->
			h2o ! add_h2o,
			h2f(N -1, h2o3, h2o)
	end.

%Function for H2O3
h2o3f(0, h2, h2o2) ->
	receive
		finished ->
			format("H2O3 number: ~w~n", [0]);
		
		add_h2o3 ->
			h2o3f(1, h2, h2o2)
	end;

h2o3f(N, h2, h2o2) ->
	h2 ! h2o3_request,

	receive 
		finished ->
			format("H2O3 number: ~w~n", [N]);
			
		add_h2o3 ->
			h2o3f(N + 1, h2, h2o2);
			
		no_h2o3 ->
			h2o3f(N, h2, h2o2);
		
		ok_h2o3 ->
			h2 ! add_o,
			h2o2 ! add_h2o2,
			h2o3f(N - 1, h2, h2o2)
	end.

%Function for H2O2
h2o2f(0, ch3, h2o, o) ->
	receive
		finished ->
			format("H2O2 number: ~w~n", [0]);
		
		add_h2o2 ->
			h2o2f(1, ch3, h2o, o)
	end;
	
h2o2f(N, ch3, h2o, o) ->
	ch3 ! h2o2_request,
	
	receive 
		finished ->
			format("H2O2 number: ~w~n", [N]);
			
		add_h2o2 ->
			h2o2f(N + 1, ch3, h2o, o);
		
		no_h2o2 ->
			o ! add_o,
			h2o ! add_h2o,
			h2o2f(N - 1, ch3, h2o, o);
		
		ok_h2o2 ->
			ch3 ! add_o,
			h2o ! add_h2o,
			h2o2f(N - 1, ch3, h2o, o)
	end.

%Function for O
oof(0) ->
	receive
		finished ->
			format("O number: ~w~n", [0]);
			
		add_o ->
			oof(1)
	end;
	
oof(N) ->
	receive
		finished ->
			format("O number: ~w~n", [N]);
			
		add_o ->
			oof(N + 1)
		
	end.

%Function for H2O	
h2of(0) ->
	receive
		finished ->
			format("H2O number: ~w~n", [0]);
			
		add_h2o ->
			h2of(1)	
	end;
	
h2of(N) ->
	receive
		finished ->
			format("H2O number: ~w~n", [N]);
		
		add_h2o ->
			h2of(N + 1)
	end.

%Main function
%parameters: X: number of CH3OH; Y: number of O2
%register PIDs for every process
%set a delay to react fully 
react(X, Y) ->

	register(o, spawn(chemistry, oof, [0])),
	register(h2o, spawn(chemistry, h2of, [0])),
	register(h2o2, spawn(chemistry, h2o2f, [0, ch3, h2o, o])),
	register(h2o3, spawn(chemistry, h2o3f, [0, h2, h2o2])),
	register(h2, spawn(chemistry, h2f, [0, h2o3, h2o])),
	register(h3, spawn(chemistry, h3f, [0, ho3, h2])),
	register(co2, spawn(chemistry, co2f, [0])),
	register(ch3, spawn(chemistry, ch3f, [0, o2, h3, h2o2, ch3o])),
	register(ho3, spawn(chemistry, ho3f, [0, h3, h2o3])),
	register(ho2, spawn(chemistry, ho2f, [0, ch3o, ho3])),
	register(ch3o, spawn(chemistry, ch3of, [0, ho2, ch3])),
	register(o2, spawn(chemistry, o2f, [Y, ho2, ch3oh, ch3, co2])),
	register(ch3oh, spawn(chemistry, ch3ohf, [X, o2, ch3o])),

%stop all reactions after 3 seconds	
	receive
		after 3000 ->
			o ! h2o ! h2o2 ! h2o3 ! h2 ! h3 ! co2 ! ch3 ! ho3 ! ch3o ! ho2 ! o2 ! ch3oh ! finished 
	end.
	