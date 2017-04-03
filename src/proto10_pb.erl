-file("src/proto10_pb.erl", 1).

-module(proto10_pb).

-export([encode_sc_10002/1, decode_sc_10002/1,
	 delimited_decode_sc_10002/1, encode_cs_10002/1,
	 decode_cs_10002/1, delimited_decode_cs_10002/1,
	 encode_sc_10001/1, decode_sc_10001/1,
	 delimited_decode_sc_10001/1, encode_cs_10001/1,
	 decode_cs_10001/1, delimited_decode_cs_10001/1,
	 encode_sc_10000/1, decode_sc_10000/1,
	 delimited_decode_sc_10000/1, encode_role_info/1,
	 decode_role_info/1, delimited_decode_role_info/1,
	 encode_cs_10000/1, decode_cs_10000/1,
	 delimited_decode_cs_10000/1]).

-export([has_extension/2, extension_size/1,
	 get_extension/2, set_extension/3]).

-export([decode_extensions/1]).

-export([encode/1, decode/2, delimited_decode/2]).

-export([int_to_enum/2, enum_to_int/2]).

-record(sc_10002, {ret}).

-record(cs_10002,
	{server_id, platform_id, platform, suid, nick_name, sex,
	 career}).

-record(sc_10001, {ret, role}).

-record(cs_10001, {role}).

-record(sc_10000, {ret, role_list}).

-record(role_info, {nick_name, sex, career}).

-record(cs_10000,
	{server_id, platform_id, platform, suid}).

encode([]) -> [];
encode(Records) when is_list(Records) ->
    delimited_encode(Records);
encode(Record) -> encode(element(1, Record), Record).

encode_sc_10002(Records) when is_list(Records) ->
    delimited_encode(Records);
encode_sc_10002(Record)
    when is_record(Record, sc_10002) ->
    encode(sc_10002, Record).

encode_cs_10002(Records) when is_list(Records) ->
    delimited_encode(Records);
encode_cs_10002(Record)
    when is_record(Record, cs_10002) ->
    encode(cs_10002, Record).

encode_sc_10001(Records) when is_list(Records) ->
    delimited_encode(Records);
encode_sc_10001(Record)
    when is_record(Record, sc_10001) ->
    encode(sc_10001, Record).

encode_cs_10001(Records) when is_list(Records) ->
    delimited_encode(Records);
encode_cs_10001(Record)
    when is_record(Record, cs_10001) ->
    encode(cs_10001, Record).

encode_sc_10000(Records) when is_list(Records) ->
    delimited_encode(Records);
encode_sc_10000(Record)
    when is_record(Record, sc_10000) ->
    encode(sc_10000, Record).

encode_role_info(Records) when is_list(Records) ->
    delimited_encode(Records);
encode_role_info(Record)
    when is_record(Record, role_info) ->
    encode(role_info, Record).

encode_cs_10000(Records) when is_list(Records) ->
    delimited_encode(Records);
encode_cs_10000(Record)
    when is_record(Record, cs_10000) ->
    encode(cs_10000, Record).

encode(cs_10000, Records) when is_list(Records) ->
    delimited_encode(Records);
encode(cs_10000, Record) ->
    [iolist(cs_10000, Record) | encode_extensions(Record)];
encode(role_info, Records) when is_list(Records) ->
    delimited_encode(Records);
encode(role_info, Record) ->
    [iolist(role_info, Record) | encode_extensions(Record)];
encode(sc_10000, Records) when is_list(Records) ->
    delimited_encode(Records);
encode(sc_10000, Record) ->
    [iolist(sc_10000, Record) | encode_extensions(Record)];
encode(cs_10001, Records) when is_list(Records) ->
    delimited_encode(Records);
encode(cs_10001, Record) ->
    [iolist(cs_10001, Record) | encode_extensions(Record)];
encode(sc_10001, Records) when is_list(Records) ->
    delimited_encode(Records);
encode(sc_10001, Record) ->
    [iolist(sc_10001, Record) | encode_extensions(Record)];
encode(cs_10002, Records) when is_list(Records) ->
    delimited_encode(Records);
encode(cs_10002, Record) ->
    [iolist(cs_10002, Record) | encode_extensions(Record)];
encode(sc_10002, Records) when is_list(Records) ->
    delimited_encode(Records);
encode(sc_10002, Record) ->
    [iolist(sc_10002, Record) | encode_extensions(Record)].

encode_extensions(_) -> [].

delimited_encode(Records) ->
    lists:map(fun (Record) ->
		      IoRec = encode(Record),
		      Size = iolist_size(IoRec),
		      [protobuffs:encode_varint(Size), IoRec]
	      end,
	      Records).

iolist(cs_10000, Record) ->
    [pack(1, required,
	  with_default(Record#cs_10000.server_id, none), int32,
	  []),
     pack(2, required,
	  with_default(Record#cs_10000.platform_id, none), int32,
	  []),
     pack(3, required,
	  with_default(Record#cs_10000.platform, none), string,
	  []),
     pack(4, required,
	  with_default(Record#cs_10000.suid, none), string, [])];
iolist(role_info, Record) ->
    [pack(1, required,
	  with_default(Record#role_info.nick_name, none), string,
	  []),
     pack(2, required,
	  with_default(Record#role_info.sex, none), int32, []),
     pack(3, required,
	  with_default(Record#role_info.career, none), int32,
	  [])];
iolist(sc_10000, Record) ->
    [pack(1, required,
	  with_default(Record#sc_10000.ret, none), int32, []),
     pack(2, repeated,
	  with_default(Record#sc_10000.role_list, none),
	  role_info, [])];
iolist(cs_10001, Record) ->
    [pack(1, required,
	  with_default(Record#cs_10001.role, none), role_info,
	  [])];
iolist(sc_10001, Record) ->
    [pack(1, required,
	  with_default(Record#sc_10001.ret, none), int32, []),
     pack(2, required,
	  with_default(Record#sc_10001.role, none), role_info,
	  [])];
iolist(cs_10002, Record) ->
    [pack(1, required,
	  with_default(Record#cs_10002.server_id, none), int32,
	  []),
     pack(2, required,
	  with_default(Record#cs_10002.platform_id, none), int32,
	  []),
     pack(3, required,
	  with_default(Record#cs_10002.platform, none), string,
	  []),
     pack(4, required,
	  with_default(Record#cs_10002.suid, none), string, []),
     pack(5, required,
	  with_default(Record#cs_10002.nick_name, none), string,
	  []),
     pack(6, required,
	  with_default(Record#cs_10002.sex, none), int32, []),
     pack(7, required,
	  with_default(Record#cs_10002.career, none), int32, [])];
iolist(sc_10002, Record) ->
    [pack(1, required,
	  with_default(Record#sc_10002.ret, none), int32, [])].

with_default(Default, Default) -> undefined;
with_default(Val, _) -> Val.

pack(_, optional, undefined, _, _) -> [];
pack(_, repeated, undefined, _, _) -> [];
pack(_, repeated_packed, undefined, _, _) -> [];
pack(_, repeated_packed, [], _, _) -> [];
pack(FNum, required, undefined, Type, _) ->
    exit({error,
	  {required_field_is_undefined, FNum, Type}});
pack(_, repeated, [], _, Acc) -> lists:reverse(Acc);
pack(FNum, repeated, [Head | Tail], Type, Acc) ->
    pack(FNum, repeated, Tail, Type,
	 [pack(FNum, optional, Head, Type, []) | Acc]);
pack(FNum, repeated_packed, Data, Type, _) ->
    protobuffs:encode_packed(FNum, Data, Type);
pack(FNum, _, Data, _, _) when is_tuple(Data) ->
    [RecName | _] = tuple_to_list(Data),
    protobuffs:encode(FNum, encode(RecName, Data), bytes);
pack(FNum, _, Data, Type, _)
    when Type =:= bool;
	 Type =:= int32;
	 Type =:= uint32;
	 Type =:= int64;
	 Type =:= uint64;
	 Type =:= sint32;
	 Type =:= sint64;
	 Type =:= fixed32;
	 Type =:= sfixed32;
	 Type =:= fixed64;
	 Type =:= sfixed64;
	 Type =:= string;
	 Type =:= bytes;
	 Type =:= float;
	 Type =:= double ->
    protobuffs:encode(FNum, Data, Type);
pack(FNum, _, Data, Type, _) when is_atom(Data) ->
    protobuffs:encode(FNum, enum_to_int(Type, Data), enum).

enum_to_int(pikachu, value) -> 1.

int_to_enum(_, Val) -> Val.

decode_sc_10002(Bytes) when is_binary(Bytes) ->
    decode(sc_10002, Bytes).

decode_cs_10002(Bytes) when is_binary(Bytes) ->
    decode(cs_10002, Bytes).

decode_sc_10001(Bytes) when is_binary(Bytes) ->
    decode(sc_10001, Bytes).

decode_cs_10001(Bytes) when is_binary(Bytes) ->
    decode(cs_10001, Bytes).

decode_sc_10000(Bytes) when is_binary(Bytes) ->
    decode(sc_10000, Bytes).

decode_role_info(Bytes) when is_binary(Bytes) ->
    decode(role_info, Bytes).

decode_cs_10000(Bytes) when is_binary(Bytes) ->
    decode(cs_10000, Bytes).

delimited_decode_cs_10000(Bytes) ->
    delimited_decode(cs_10000, Bytes).

delimited_decode_role_info(Bytes) ->
    delimited_decode(role_info, Bytes).

delimited_decode_sc_10000(Bytes) ->
    delimited_decode(sc_10000, Bytes).

delimited_decode_cs_10001(Bytes) ->
    delimited_decode(cs_10001, Bytes).

delimited_decode_sc_10001(Bytes) ->
    delimited_decode(sc_10001, Bytes).

delimited_decode_cs_10002(Bytes) ->
    delimited_decode(cs_10002, Bytes).

delimited_decode_sc_10002(Bytes) ->
    delimited_decode(sc_10002, Bytes).

delimited_decode(Type, Bytes) when is_binary(Bytes) ->
    delimited_decode(Type, Bytes, []).

delimited_decode(_Type, <<>>, Acc) ->
    {lists:reverse(Acc), <<>>};
delimited_decode(Type, Bytes, Acc) ->
    try protobuffs:decode_varint(Bytes) of
      {Size, Rest} when size(Rest) < Size ->
	  {lists:reverse(Acc), Bytes};
      {Size, Rest} ->
	  <<MessageBytes:Size/binary, Rest2/binary>> = Rest,
	  Message = decode(Type, MessageBytes),
	  delimited_decode(Type, Rest2, [Message | Acc])
    catch
      _What:_Why -> {lists:reverse(Acc), Bytes}
    end.

decode(enummsg_values, 1) -> value1;
decode(cs_10000, Bytes) when is_binary(Bytes) ->
    Types = [{4, suid, string, []},
	     {3, platform, string, []}, {2, platform_id, int32, []},
	     {1, server_id, int32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_10000, Decoded);
decode(role_info, Bytes) when is_binary(Bytes) ->
    Types = [{3, career, int32, []}, {2, sex, int32, []},
	     {1, nick_name, string, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(role_info, Decoded);
decode(sc_10000, Bytes) when is_binary(Bytes) ->
    Types = [{2, role_list, role_info,
	      [is_record, repeated]},
	     {1, ret, int32, []}],
    Defaults = [{2, role_list, []}],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_10000, Decoded);
decode(cs_10001, Bytes) when is_binary(Bytes) ->
    Types = [{1, role, role_info, [is_record]}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_10001, Decoded);
decode(sc_10001, Bytes) when is_binary(Bytes) ->
    Types = [{2, role, role_info, [is_record]},
	     {1, ret, int32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_10001, Decoded);
decode(cs_10002, Bytes) when is_binary(Bytes) ->
    Types = [{7, career, int32, []}, {6, sex, int32, []},
	     {5, nick_name, string, []}, {4, suid, string, []},
	     {3, platform, string, []}, {2, platform_id, int32, []},
	     {1, server_id, int32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(cs_10002, Decoded);
decode(sc_10002, Bytes) when is_binary(Bytes) ->
    Types = [{1, ret, int32, []}],
    Defaults = [],
    Decoded = decode(Bytes, Types, Defaults),
    to_record(sc_10002, Decoded).

decode(<<>>, Types, Acc) ->
    reverse_repeated_fields(Acc, Types);
decode(Bytes, Types, Acc) ->
    {ok, FNum} = protobuffs:next_field_num(Bytes),
    case lists:keyfind(FNum, 1, Types) of
      {FNum, Name, Type, Opts} ->
	  {Value1, Rest1} = case lists:member(is_record, Opts) of
			      true ->
				  {{FNum, V}, R} = protobuffs:decode(Bytes,
								     bytes),
				  RecVal = decode(Type, V),
				  {RecVal, R};
			      false ->
				  case lists:member(repeated_packed, Opts) of
				    true ->
					{{FNum, V}, R} =
					    protobuffs:decode_packed(Bytes,
								     Type),
					{V, R};
				    false ->
					{{FNum, V}, R} =
					    protobuffs:decode(Bytes, Type),
					{unpack_value(V, Type), R}
				  end
			    end,
	  case lists:member(repeated, Opts) of
	    true ->
		case lists:keytake(FNum, 1, Acc) of
		  {value, {FNum, Name, List}, Acc1} ->
		      decode(Rest1, Types,
			     [{FNum, Name, [int_to_enum(Type, Value1) | List]}
			      | Acc1]);
		  false ->
		      decode(Rest1, Types,
			     [{FNum, Name, [int_to_enum(Type, Value1)]} | Acc])
		end;
	    false ->
		decode(Rest1, Types,
		       [{FNum, Name, int_to_enum(Type, Value1)} | Acc])
	  end;
      false ->
	  case lists:keyfind('$extensions', 2, Acc) of
	    {_, _, Dict} ->
		{{FNum, _V}, R} = protobuffs:decode(Bytes, bytes),
		Diff = size(Bytes) - size(R),
		<<V:Diff/binary, _/binary>> = Bytes,
		NewDict = dict:store(FNum, V, Dict),
		NewAcc = lists:keyreplace('$extensions', 2, Acc,
					  {false, '$extensions', NewDict}),
		decode(R, Types, NewAcc);
	    _ ->
		{ok, Skipped} = protobuffs:skip_next_field(Bytes),
		decode(Skipped, Types, Acc)
	  end
    end.

reverse_repeated_fields(FieldList, Types) ->
    [begin
       case lists:keyfind(FNum, 1, Types) of
	 {FNum, Name, _Type, Opts} ->
	     case lists:member(repeated, Opts) of
	       true -> {FNum, Name, lists:reverse(Value)};
	       _ -> Field
	     end;
	 _ -> Field
       end
     end
     || {FNum, Name, Value} = Field <- FieldList].

unpack_value(Binary, string) when is_binary(Binary) ->
    binary_to_list(Binary);
unpack_value(Value, _) -> Value.

to_record(cs_10000, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_10000),
						   Record, Name, Val)
			  end,
			  #cs_10000{}, DecodedTuples),
    Record1;
to_record(role_info, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       role_info),
						   Record, Name, Val)
			  end,
			  #role_info{}, DecodedTuples),
    Record1;
to_record(sc_10000, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_10000),
						   Record, Name, Val)
			  end,
			  #sc_10000{}, DecodedTuples),
    Record1;
to_record(cs_10001, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_10001),
						   Record, Name, Val)
			  end,
			  #cs_10001{}, DecodedTuples),
    Record1;
to_record(sc_10001, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_10001),
						   Record, Name, Val)
			  end,
			  #sc_10001{}, DecodedTuples),
    Record1;
to_record(cs_10002, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       cs_10002),
						   Record, Name, Val)
			  end,
			  #cs_10002{}, DecodedTuples),
    Record1;
to_record(sc_10002, DecodedTuples) ->
    Record1 = lists:foldr(fun ({_FNum, Name, Val},
			       Record) ->
				  set_record_field(record_info(fields,
							       sc_10002),
						   Record, Name, Val)
			  end,
			  #sc_10002{}, DecodedTuples),
    Record1.

decode_extensions(Record) -> Record.

decode_extensions(_Types, [], Acc) ->
    dict:from_list(Acc);
decode_extensions(Types, [{FNum, Bytes} | Tail], Acc) ->
    NewAcc = case lists:keyfind(FNum, 1, Types) of
	       {FNum, Name, Type, Opts} ->
		   {Value1, Rest1} = case lists:member(is_record, Opts) of
				       true ->
					   {{FNum, V}, R} =
					       protobuffs:decode(Bytes, bytes),
					   RecVal = decode(Type, V),
					   {RecVal, R};
				       false ->
					   case lists:member(repeated_packed,
							     Opts)
					       of
					     true ->
						 {{FNum, V}, R} =
						     protobuffs:decode_packed(Bytes,
									      Type),
						 {V, R};
					     false ->
						 {{FNum, V}, R} =
						     protobuffs:decode(Bytes,
								       Type),
						 {unpack_value(V, Type), R}
					   end
				     end,
		   case lists:member(repeated, Opts) of
		     true ->
			 case lists:keytake(FNum, 1, Acc) of
			   {value, {FNum, Name, List}, Acc1} ->
			       decode(Rest1, Types,
				      [{FNum, Name,
					lists:reverse([int_to_enum(Type, Value1)
						       | lists:reverse(List)])}
				       | Acc1]);
			   false ->
			       decode(Rest1, Types,
				      [{FNum, Name, [int_to_enum(Type, Value1)]}
				       | Acc])
			 end;
		     false ->
			 [{FNum,
			   {optional, int_to_enum(Type, Value1), Type, Opts}}
			  | Acc]
		   end;
	       false -> [{FNum, Bytes} | Acc]
	     end,
    decode_extensions(Types, Tail, NewAcc).

set_record_field(Fields, Record, '$extensions',
		 Value) ->
    Decodable = [],
    NewValue = decode_extensions(element(1, Record),
				 Decodable, dict:to_list(Value)),
    Index = list_index('$extensions', Fields),
    erlang:setelement(Index + 1, Record, NewValue);
set_record_field(Fields, Record, Field, Value) ->
    Index = list_index(Field, Fields),
    erlang:setelement(Index + 1, Record, Value).

list_index(Target, List) -> list_index(Target, List, 1).

list_index(Target, [Target | _], Index) -> Index;
list_index(Target, [_ | Tail], Index) ->
    list_index(Target, Tail, Index + 1);
list_index(_, [], _) -> -1.

extension_size(_) -> 0.

has_extension(_Record, _FieldName) -> false.

get_extension(_Record, _FieldName) -> undefined.

set_extension(Record, _, _) -> {error, Record}.

