ClearAll["MonitorTools`*"];
ClearAll["MonitorTools`*`*"];

BeginPackage["MonitorTools`"];

MonitorMap::usage = "MonitorMap[foo, {x_1, x_2, ...}]
Effectively performs Map[foo, {x_1, x_2, ...}] with a progress bar and other features.";

Begin["`Private`"];


Options[iMonitorMap] = {
	"Monitor" -> True,
	"DisplayThreshold" -> 1.5,
	UpdateInterval -> 2,
	TrackedSymbols -> {},
	"ProgressMessageFunction" -> (""&)
};
iMonitorMap[foo_, values_List, opts : OptionsPattern[]] := Module[
	{v, counter},
	counter = 0;
	Monitor[
		Table[
			With[{result = foo[v]},
				counter++;
				result
			],
			{v, values}
		],
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


End[];

EndPackage[];