BeginTestSection["SimpleTestSuite"];

VerificationTest[
	1 + 1,
	2,
	TestID -> "passing-test-1"
];

VerificationTest[
	2 + 2,
	4,
	TestID -> "passing-test-2"
];

VerificationTest[
	3 + 3,
	6,
	TestID -> "passing-test-3"
];


EndTestSection[];
