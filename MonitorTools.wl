ClearAll["MonitorTools`*"];
ClearAll["MonitorTools`*`*"];

BeginPackage["MonitorTools`"];

MonitorMap::usage = "MonitorMap[foo, {x_1, x_2, ...}]
Effectively performs Map[foo, {x_1, x_2, ...}] with a progress bar and other features.";
MonitorMapIndexed::usage = "MonitorMapIndexed[foo, {x_1, x_2}]
Effectively performs MonitorMapIndexed[foo, {x_1, x_2, ...}] with a progress bar and other features.";
MonitorTable::usage = "MonitorTable[foo, ...]
Effectively performs Table[foo, ...] with a progress bar and other features.";
MonitorAssociationMap::usage = "MonitorAssociationMap[foo, ...]
Effectively performs AssociationMap[foo, ...] with a progress bar and other features";
MonitorKeyMap::usage = "MonitorKeyMap[foo, a_Association]
Effectively performs KeyMap[foo, ...] with a progress bar and other features";
MonitorApplyAt::usage = "MonitorApplyAt[foo, l_List]
Effectively performs foo @@@ l with a progress bar and other features";
MonitorKeyValueMap::usage = "MonitorKeyValueMap[foo, a_Association]
Effectively performs KeyValueMap[foo, a] with a progress bar and other features";

MonitorSelect::usage = "MonitorSelect[data, test : Identity, n : Infinity]
Effectively performs Select[data, test, n] with a progress bar and other features";

MonitorCases::usage = "MonitorCases[data, pattern, levelSpec: {1}, n:Infinity]
Effectively performs Cases[data, pattern, levelSpec, n] with a progress bar and other features";

Begin["`Private`"];

MonitorMap::aborted = "Aborted after `` of `` (~``% complete)";

Options[iMonitorMap] = {
	"Monitor" -> True,
	"DisplayThreshold" -> 1.5,
	UpdateInterval -> 2,
	TrackedSymbols -> {},
	"ProgressMessageFunction" -> (""&)
};
iMonitorMap[foo_, values_, opts : OptionsPattern[]] := Module[
	{
		v, counter, sowTag,
		progressMessageFunction, progressMessageFunctionArguments, passCurrentValueQ,
		updateInterval, trackedSymbols, valueCount
	},
	
	valueCount = Length[values];
	
	progressMessageFunction = OptionValue["ProgressMessageFunction"];
	passCurrentValueQ = Not @ FreeQ[progressMessageFunction, Slot["CurrentValue"]];
	updateInterval = OptionValue[UpdateInterval];
	trackedSymbols = OptionValue[TrackedSymbols];
	
	counter = 0;
	Monitor[
		Reap[
			CheckAbort[
				Do[
					With[{result = foo[v]},
						Sow[result, sowTag];
						counter++;
					],
					{v, values}
				],
				Message[MonitorMap::aborted, counter, Length[values], Round @ N[100. * counter / Length[values]]]
			],
			sowTag
		] // Last // Apply[Join],
		Refresh[
			Column[
				{
				(* Basic progress monitoring *)
					Row[
						{
							ProgressIndicator[counter, {0, valueCount}],
							StringTemplate["``/``"][counter, valueCount]
						},
						Spacer[1]
					],
				
				(* Custom function for showing progress *)
					progressMessageFunctionArguments = <|
						"CurrentCount" -> counter,
						"StartCount" -> 0,
						"EndCount" -> length
					|>;
					
					If[passCurrentValueQ,
						AppendTo[progressMessageFunctionArguments, "CurrentValue" -> v];
					];
					
					progressMessageFunction[progressMessageFunctionArguments]
				}
			],
			UpdateInterval -> updateInterval,
			TrackedSymbols -> trackedSymbols
		],
		OptionValue["DisplayThreshold"]
	]
];

Options[MonitorMap] = Join[
	Options[iMonitorMap],
	Options[monitorDisplay]
];
MonitorMap[foo_, values_, opts : OptionsPattern[]] := Which[
	OptionValue["Monitor"],
	iMonitorMap[foo, values, opts],
	
	True,
	Map[foo, values]
];


Options[MonitorMapIndexed] = Options[MonitorMap];
MonitorMapIndexed[foo_, values_, opts : OptionsPattern[]] := Which[
	OptionValue["Monitor"],
	iMonitorMapIndexed[foo, values, opts],
	
	True,
	MapIndexed[foo, values]
];

iMonitorMapIndexed[foo_, values_, opts___] :=
	Head[values] @@ MonitorApplyAt[foo, Transpose[{List @@ values, List /@ Range[Length[values]]}], opts];

iMonitorMapIndexed[foo_, values_Association, opts___] :=
    Association @ MonitorKeyValueMap[#1 -> foo[#2, {Key[#1]}]&, values, opts];

Attributes[MonitorTable] = {HoldFirst};
Options[MonitorTable] = Options[MonitorMap];

MonitorTable[foo_, {i_Symbol, start_, end_, step_: 1}, opts : OptionsPattern[]] := MonitorTable[foo, {i, Range[start, end, step]}, opts];

MonitorTable[foo_, {i_Symbol, values_List}, opts : OptionsPattern[]] := Which[
	OptionValue["Monitor"],
	iMonitorMap[
		Function @@ (Hold[foo] /. i :> With[{eval = Slot[]}, eval /; True]),
		values,
		opts
	],
	
	True,
	Table[foo, {i, values}]
];

Attributes[MonitorAssociationMap] = Attributes[MonitorMap];
Options[MonitorAssociationMap] = Options[MonitorMap];
MonitorAssociationMap[foo_, values_, opts : OptionsPattern[]] := Which[
	OptionValue["Monitor"],
	Switch[Head[values],
		
		Association,
		Association @ MonitorMap[foo, Normal[values], opts],
		
		_,
		With[
			{
				results = MonitorMap[foo, values, opts]
			},
			AssociationThread[Take[values, Length[results]] -> results]
		]
	],
	
	True,
	AssociationMap[foo, values]
	
];

Attributes[MonitorKeyMap] = Attributes[MonitorMap];
Options[MonitorKeyMap] = Options[MonitorMap];
MonitorKeyMap[foo_, a_Association, opts: OptionsPattern[]] := Which[
	OptionValue["Monitor"],
	With[
		{
			modifiedKeys = MonitorMap[foo, Keys[a], opts]
		},
		AssociationThread[modifiedKeys -> Take[Values[a], Length[modifiedKeys]]]
	],
	
	True,
	AssociationMap[foo, a]

];

Attributes[MonitorApplyAt] = Attributes[MonitorMap];
Options[MonitorApplyAt] = Options[MonitorMap];
MonitorApplyAt[foo_, values_, opts: OptionsPattern[]] := Which[
	OptionValue["Monitor"],
	MonitorMap[Apply[foo], values, opts],
	
	True,
	f @@@ values

];

Attributes[MonitorKeyValueMap] = Attributes[MonitorMap];
Options[MonitorKeyValueMap] = Options[MonitorMap];
MonitorKeyValueMap[foo_, a_Association, opts: OptionsPattern[]] := Which[
	OptionValue["Monitor"],
	MonitorMap[Apply[foo], Normal[a], opts],
	
	True,
	KeyValueMap[f, values]

];

Options[MonitorSelect] = Options[MonitorMap];
MonitorSelect[data_, test_:Identity, n: (_Integer ? Positive | Infinity): Infinity, opts: OptionsPattern[]] := Which[
	OptionValue["Monitor"],
	Module[{sowTag, sowCount = 0},
		Reap[
			MonitorMap[
				With[{},
					If[TrueQ[test[#]],
						Sow[#, sowTag];
						sowCount++;
						If[sowCount >= n,
							Break[];
						];
					];
				]&,
				data,
				opts
			],
			sowTag
		] // Last // Replace[{l_List} :> l]
	],
	
	True,
	Select[data, test, n]
	
];

Options[MonitorCases] = Options[MonitorMap];
MonitorCases[data_, pattern_, levelSpec_: {1}, n: (_Integer ? Positive | Infinity): Infinity, opts: OptionsPattern[]] := Which[
	OptionValue["Monitor"],
	Module[{sowTag, sowCount = 0},
		Reap[
			MonitorMap[
				With[
					{cases = Cases[#, pattern, levelSpec - 1]},
					If[Length[cases] > 0,
						Sow[cases, sowTag];
						sowCount++;
						If[sowCount >= n,
							Break[];
						];
					]
				]&,
				data,
				opts
			],
			sowTag
		] // Last // Replace[{l_List} :> Join @@ l]
	],
	
	True,
	Cases[data, pattern, levelSpec, n]

];

End[];

EndPackage[];