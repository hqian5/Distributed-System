%a test for module chemistry
-module(chemistry_tests).
-import(chemistry, [ch3ohf/3, o2f/5, ch3of/3, ho2f/3, ch3f/5, ho3f/3, co2f/1, h3f/3, h2f/3, h2o3f/3, h2o2f/4, h2of/1, oof/1, react/2]).
-include_lib("eunit/include/eunit.hrl").

%test function
expect(Val) ->
 receive
	Val ->
		ok;
	Other ->
		{error,Other}
 end.

%test every process
%test for CH3OH
ch3oh_test() ->
	%register PID for every function in chemistry.erl
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
	register(o2, spawn(chemistry, o2f, [12, ho2, ch3oh, ch3, co2])),
	register(ch3oh, spawn(chemistry, ch3ohf, [5, o2, ch3o])),
	register(reactpid, spawn(chemistry, react, [5,12])),
	
	%receive permit and refuse messages from O2
	%receive finished from function react
	ok = expect({ok_ch3oh, o2}),
	ok = expect({no_ch3oh, o2}),
	ok = expect({finished, reactpid}).
	
%test for O2
o2_test() ->
	%receive communication request from CH3OH and CH3
	%receive c and h actions
	ok = expect({ch3oh_request, ch3oh}),
	ok = expect({add_h, ch3oh}),
	ok = expect({ch3_request, ch3}),
	ok = expect({add_c, ch3}),
	ok = expect({finished, reactpid}).

%test for CH3O
ch3o_test() ->
	%receive add action
	ok = expect({add_ch3o, ch3oh}),
	ok = expect({no_ch3o, ho2}),
	ok = expect({ok_ch3o, ho2}),
	ok = expect({finished, reactpid}).

%following tests are similar with CH3OH and O2	
ho2_test() ->
	ok = expect({add_ho2, o2}),
	ok = expect({ch3o_request, ch3o}),
	ok = expect({add_o, ch3o}),
	ok = expect({finished, reactpid}).

ch3_test() ->
	ok = expect({add_ch3, ch3o}),
	ok = expect({no_ch3, o2}),
	ok = expect({ok_ch3, o2}),
	ok = expect({h2o2_request, h2o2}),
	ok = expect({add_o, h2o2}),
	ok = expect({finished, reactpid}).

ho3_test() ->
	ok = expect({add_ho3, ho2}),
	ok = expect({h3_request, h3}),
	ok = expect({add_h, h3}),
	ok = expect({finished, reactpid}).
	
co2_test() ->
	ok = expect({add_co2, o2}),
	ok = expect({finished, reactpid}).
	
h3_test() ->
	ok = expect({add_h3, ch3}),
	ok = expect({no_h3, ho3}),
	ok = expect({ok_h3, ho3}),
	ok = expect({finished, reactpid}).
	
h2o3_test() ->
	ok = expect({add_h2o3, ho3}),
	ok = expect({no_h2o3, h2}),
	ok = expect({ok_h2o3, h2}),
	ok = expect({finished, reactpid}).
	
h2_test() -> 
	ok = expect({add_h2, h3}),
	ok = expect({h2o3_request, h2o3}),
	ok = expect({add_o, h2o3}),
	ok = expect({finished, reactpid}).
	
h2o2_test() ->
	ok = expect({add_h2o2, h2o3}),
	ok = expect({no_h2o2, ch3}),
	ok = expect({ok_h2o2, ch3}),
	ok = expect({finished, reactpid}).

h2o_test() ->
	ok = expect({add_h2o, h2}),
	ok = expect({add_h2o, h2o2}),
	ok = expect({finished, reactpid}).
	
oo_test() ->
	ok = expect({add_o, h2o2}),
	ok = expect({finished, reactpid}).
	
	
	
	


	


	
