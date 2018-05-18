BeginTestSection["MonitorTools"];

VerificationTest[
	Get["MonitorTools.wl"],
	Null,
	TestID -> "Get-Package"
];

VerificationTest[
	MonitorTools`MonitorMap[Sin, {1, 2, 3}],
	{Sin[1], Sin[2], Sin[3]},
	TestID -> "Mirror-Map"
];

VerificationTest[
	Reap[
		MonitorTools`MonitorMap[
			Identity,
			CharacterRange["A", "E"],
			"Monitor" -> False,
			"ProgressMessageFunction" -> (Sow[#CurrentValue]&)
		]
	] // Last // Flatten,
	{},
	TimeConstraint -> Quantity[5.25, "Seconds"],
	TestID -> "Monitor-False-means-no-progress-function-call"
];

VerificationTest[
	Reap[
		MonitorTools`MonitorMap[
			Identity,
			CharacterRange["A", "E"],
			"ProgressMessageFunction" -> (Sow[#CurrentValue]&),
			"DisplayThreshold" -> 100
		]
	] // Last // Flatten,
	{},
	SameTest -> MatchQ,
	TestID -> "Large-DisplayThreshold-means-no-progress-function-call"
];

VerificationTest[
	Reap[
		MonitorTools`MonitorMap[
			(Pause[0.5]; #) &,
			CharacterRange["A", "E"],
			"ProgressMessageFunction" -> (Sow[#CurrentValue]&),
			UpdateInterval -> 1
		]
	] // Last // Flatten,
	{__String},
	SameTest -> MatchQ,
	TestID -> "ProgressFunction-is-called-for-some-inputs"
];

VerificationTest[
	Reap[
		MonitorTools`MonitorMap[
			(Pause[0.5]; #) &,
			CharacterRange["A", "E"],
			"ProgressMessageFunction" -> (Sow[#CurrentValue]&),
			"DisplayThreshold" -> 0,
			UpdateInterval -> 1
		]
	] // Last // Flatten,
	{_Symbol, __String},
	SameTest -> MatchQ,
	TestID -> "ProgressFunction-gets-symbol-with-no-DisplayThreshold"
];

VerificationTest[
	Reap[
		MonitorTools`MonitorMap[
			(Pause[0.5]; #) &,
			CharacterRange["A", "E"],
			"ProgressMessageFunction" -> (Sow[#CurrentValue]&),
			UpdateInterval -> 0,
			"DisplayThreshold" -> 0.2
		]
	] // Last // Flatten // Union,
	CharacterRange["A", "E"],
	SameTest -> MatchQ,
	TestID -> "UpdateInterval-zero-means-repeatedly-called-for-all-inputs"
];

VerificationTest[
	Reap[
		MonitorTools`MonitorTable[Sow[i]; i^2, {i, 1, 3, 1}]
	],
	{{1, 4, 9}, {{1, 2, 3}}},
	TestID -> "MonitorTable-No-EvaluationLeaks"
];

VerificationTest[
	MonitorTools`MonitorTable[i, {i, 1, 3, 2}],
	{1, 3},
	TestID -> "MonitorTable-Mirror-Table-with-step"
];

VerificationTest[
	MonitorTools`MonitorTable[i, {i, 1, 3}],
	{1, 2, 3},
	TestID -> "MonitorTable-Mirror-Table-without-step"
];

VerificationTest[
	MonitorTools`MonitorTable[ToUpperCase[i], {i, {"a", "b", "c"}}],
	{"A", "B", "C"},
	TestID -> "MonitorTable-Mirror-Table-with-list-of-values"
];

VerificationTest[
	MonitorTools`MonitorTable[ToUpperCase[i], {i, CharacterRange["a", "e"]}],
	{"A", "B", "C", "D", "E"},
	TestID -> "MonitorTable-Mirror-Table-with-list-of-values-2"
];

VerificationTest[
	MonitorTools`MonitorMap[If[# === "C", Abort[], #]&, CharacterRange["A", "E"]],
	{"A", "B"},
	{MonitorTools`MonitorMap::aborted},
	TestID -> "Abortability"
];

VerificationTest[
	MonitorTools`MonitorMap[Abort[]&, CharacterRange["A", "E"]],
	{},
	{MonitorTools`MonitorMap::aborted},
	TestID -> "Abortability-1"
];

VerificationTest[
	MonitorTools`MonitorAssociationMap[f, {1, 2, 3}],
	<| 1 -> f[1], 2 -> f[2], 3 -> f[3]|>,
	TestID -> "MonitorAssociationMap-Mirror-AssociationMap-List"
];

VerificationTest[
	MonitorTools`MonitorAssociationMap[If[# === 2, Abort[], f[#]]&, {1, 2, 3}],
	<| 1 -> f[1]|>,
	{MonitorTools`MonitorMap::aborted},
	TestID -> "MonitorAssociationMap-Abortability-List"
];

VerificationTest[
	MonitorTools`MonitorAssociationMap[Reverse, <|"A" -> 1, "B" -> 2, "C" -> 3|>],
	<|1 -> "A", 2 -> "B", 3 -> "C"|>,
	TestID -> "MonitorAssociationMap-Mirror-AssociationMap-Association"
];

VerificationTest[
	MonitorTools`MonitorAssociationMap[If[MatchQ[#, Rule[_, 2]], Abort[], Reverse[#]]&, <|"A" -> 1, "B" -> 2, "C" -> 3|>],
	<|1 -> "A"|>,
	{MonitorTools`MonitorMap::aborted},
	TestID -> "MonitorAssociationMap-Abortability-Association"
];

VerificationTest[
	MonitorTools`MonitorKeyMap[f, <|"A" -> 1, "B" -> 2, "C" -> 3|>],
	<|f["A"] -> 1, f["B"] -> 2, f["C"] -> 3|>,
	TestID -> "MonitorKeyMap-Mirror-KeyMap"
];

VerificationTest[
	MonitorTools`MonitorKeyMap[If[# === "B", Abort[], f[#]]&, <|"A" -> 1, "B" -> 2, "C" -> 3|>],
	<|f["A"] -> 1|>,
	{MonitorTools`MonitorMap::aborted},
	TestID -> "MonitorKeyMap-Abortability"
];

VerificationTest[
	MonitorTools`MonitorApplyAt[f, {"A" -> 1, "B" -> 2, "C" -> 3}],
	{f["A", 1], f["B", 2], f["C", 3]},
	TestID -> "MonitorApplyAt-Mirror-ApplyAt"
];

VerificationTest[
	MonitorTools`MonitorApplyAt[If[#1 === "B", Abort[], f[##]]&, {"A" -> 1, "B" -> 2, "C" -> 3}],
	{f["A", 1]},
	{MonitorTools`MonitorMap::aborted},
	TestID -> "MonitorApplyAt-Abortability"
];

VerificationTest[
	MonitorTools`MonitorKeyValueMap[f, <|"A" -> 1, "B" -> 2, "C" -> 3|>],
	{f["A", 1], f["B", 2], f["C", 3]},
	TestID -> "MonitorKeyValueMap-Mirror-KeyValueMap"
];

VerificationTest[
	MonitorTools`MonitorKeyValueMap[If[#1 === "B", Abort[], f[##]]&, <|"A" -> 1, "B" -> 2, "C" -> 3|>],
	{f["A", 1]},
	{MonitorTools`MonitorMap::aborted},
	TestID -> "MonitorKeyValueMap-Abortability"
];

VerificationTest[
	MonitorTools`MonitorSelect[Range[1, 10], EvenQ],
	{2, 4, 6, 8, 10},
	TestID -> "MonitorSelect-Two-Arguments"
];

VerificationTest[
	MonitorTools`MonitorSelect[Range[1, 10], False &],
	{},
	TestID -> "MonitorSelect-Two-Arguments-Failure-Case"
];

VerificationTest[
	MonitorTools`MonitorSelect[Range[1, 10], EvenQ, 3],
	{2, 4, 6},
	TestID -> "MonitorSelect-Three-Arguments"
];

VerificationTest[
	MonitorTools`MonitorSelect[Range[1, 10], False &, 3],
	{},
	TestID -> "MonitorSelect-Three-Arguments-Failure-Case"
];


VerificationTest[
	MonitorTools`MonitorCases[{1, {2}, 3}, _Integer],
	{1, 3},
	TestID -> "MonitorCases-Two-Arguments-Simple-Pattern"
];

VerificationTest[
	MonitorTools`MonitorCases[{{1}, 2, 3}, i_Integer -> "A"],
	{"A", "A"},
	TestID -> "MonitorCases-Two-Arguments-Rule-Pattern"
];

VerificationTest[
	MonitorTools`MonitorCases[{{1}, 2, 3}, i_Integer :> i^2],
	{4, 9},
	TestID -> "MonitorCases-Two-Arguments-RuleDelayed"
];

VerificationTest[
	MonitorTools`MonitorCases[List /@ Range[1, 3], _Integer],
	{},
	TestID -> "MonitorCases-Two-Arguments-Failure-Case"
];

VerificationTest[
	MonitorTools`MonitorCases[List /@ Range[1, 3], _Integer, Infinity],
	{1, 2, 3},
	TestID -> "MonitorCases-Three-Arguments"
];

VerificationTest[
	MonitorTools`MonitorCases[List /@ Range[1, 3], _String, Infinity],
	{},
	TestID -> "MonitorCases-Three-Arguments-FailureCase"
];

VerificationTest[
	MonitorTools`MonitorCases[List /@ Range[1, 10], _Integer?EvenQ, Infinity, 3],
	{2, 4, 6},
	TestID -> "MonitorCases-Four-Arguments"
];

VerificationTest[
	MonitorTools`MonitorCases[List /@ Range[1, 10], _String, Infinity, 3],
	{},
	TestID -> "MonitorCases-Four-Arguments-Failure-Case"
];

EndTestSection[];