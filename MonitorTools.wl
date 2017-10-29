ClearAll["MonitorTools`*"];
ClearAll["MonitorTools`*`*"];

BeginPackage["MonitorTools`"];

MonitorMap::usage = "MonitorMap[foo, {x_1, x_2, ...}]
Effectively performs Map[foo, {x_1, x_2, ...}] with a progress bar and other features.";

Begin["`Private`"];


Options[iMonitorMap] = {
	"Monitor" -> True,
	"DisplayThreshold" -> 2
};
iMonitorMap[foo_, values_List, OptionsPattern[]] := Module[
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
		monitorDisplay[v, counter, {0, Length[values]}],
		OptionValue["DisplayThreshold"]
	]
];


Options[monitorDisplay] = {
	"TrackedSymbols" -> {},
	"UpdateInterval" -> OptionValue[iMonitorMap, "DisplayThreshold"]
};
monitorDisplay[currentValue_, currentCount_Integer, {startCount_Integer, endCount_Integer}, opts : OptionsPattern[]] := With[{},
	Refresh[ProgressIndicator[currentCount, {startCount, endCount}], opts]
];


Options[MonitorMap] = Options[iMonitorMap];
MonitorMap[foo_, values_List, opts : OptionsPattern[]] := Which[
	OptionValue["Monitor"],
	iMonitorMap[foo, values, opts],
	
	True,
	Map[foo, values]
];


End[];

EndPackage[];