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

EndTestSection[];