ClearAll["MonitorTools`*"];
ClearAll["MonitorTools`*`*"];

BeginPackage["MonitorTools`"];

MonitorMap::usage = "MonitorMap[foo, {x_1, x_2, ...}]
Effectively performs Map[foo, {x_1, x_2, ...}] with a progress bar and other features.";
MonitorTable::usage = "MonitorTable[foo, ...]
Effectively performs Table[foo, ...] with a progress bar and other features.";

Begin["`Private`"];

MonitorMap::aborted = "Aborted after `` of `` (~``% complete)";

Options[iMonitorMap] = {
	"Monitor" -> True,
	"DisplayThreshold" -> 1.5,
	UpdateInterval -> 2,
	TrackedSymbols -> {},
	"ProgressMessageFunction" -> (""&)
};
iMonitorMap[foo_, values_List, opts : OptionsPattern[]] := Module[
	{v, counter, sowTag},
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
							ProgressIndicator[counter, {0, Length[values]}],
							StringTemplate["``/``"][counter, Length[values]]
						},
						Spacer[1]
					],
				
				(* Custom function for showing progress *)
					OptionValue["ProgressMessageFunction"][
						<|
							"CurrentValue" -> v,
							"CurrentCount" -> counter,
							"StartCount" -> 0,
							"EndCount" -> Length[values]
						|>
					]
				}
			],
			UpdateInterval -> OptionValue[UpdateInterval],
			TrackedSymbols -> OptionValue[TrackedSymbols]
		],
		OptionValue["DisplayThreshold"]
	]
];

Options[MonitorMap] = Join[
	Options[iMonitorMap],
	Options[monitorDisplay]
];
MonitorMap[foo_, values_List, opts : OptionsPattern[]] := Which[
	OptionValue["Monitor"],
	iMonitorMap[foo, values, opts],
	
	True,
	Map[foo, values]
];



Attributes[MonitorTable] = {HoldFirst};
Options[MonitorTable] = Join[
	Options[iMonitorMap],
	Options[monitorDisplay]
];

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

End[];

EndPackage[];