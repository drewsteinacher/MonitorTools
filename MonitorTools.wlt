BeginTestSection["MonitorTools"];

VerificationTest[
	Get["MonitorTools.wl"],
	Null,
	TestID -> "Get-Package"
];

VerificationTest[
	MonitorMap[Sin, {1, 2, 3}],
	{Sin[1], Sin[2], Sin[3]},
	TestID -> "Mirror-Map"
];

EndTestSection[];