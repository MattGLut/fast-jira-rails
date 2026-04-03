#!/usr/bin/env pwsh
# FastJira Test Runner
# Usage: .\test.ps1 [RSpec args]
# Examples:
#   .\test.ps1                        # Run full suite
#   .\test.ps1 spec/models/           # Run model specs only
#   .\test.ps1 spec/system/           # Run system specs only
#   .\test.ps1 --format documentation # Verbose output

param(
    [Parameter(ValueFromRemainingArguments)]
    [string[]]$RSpecArgs
)

$env:RI_FORCE_PATH_FOR_DLL = "1"
$env:PATH = "C:\Ruby33-x64\bin;C:\Ruby33-x64\lib\ruby\3.3.0\x64-mingw-ucrt;C:\Ruby33-x64\msys64\ucrt64\bin;C:\Ruby33-x64\msys64\usr\bin;" + $env:PATH

bundle exec rspec @RSpecArgs
