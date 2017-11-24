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

EndTestSection[];