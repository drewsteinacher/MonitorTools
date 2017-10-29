BeginPackage["MonitorTools`"];

MonitorMap::usage = "MonitorMap[foo, {x_1, x_2, ...}]
Effectively performs Map[foo, {x_1, x_2, ...}] with a progress bar and other features.";

Begin["`Private`"];

MonitorMap[foo_, values_List] := With[{},
	foo /@ values
];

End[];

EndPackage[];