$ErrorActionPreference = "Stop"

$currentBranch = (git branch --show-current).Trim()

if ([string]::IsNullOrWhiteSpace($currentBranch)) {
    throw "Firebase Rules tests must run from a named Git branch."
}

$requiredFiles = @(
    ".\firestore.rules",
    ".\storage.rules",
    ".\firebase.json",
    ".\firebase\rules-tests\package.json",
    ".\firebase\rules-tests\release_readiness.rules.test.cjs"
)

foreach ($requiredFile in $requiredFiles) {
    if (-not (Test-Path -LiteralPath $requiredFile)) {
        throw "Required file not found: $requiredFile"
    }
}

foreach ($command in @("node", "npm", "java", "firebase")) {
    if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
        throw "Required command not found: $command"
    }
}

Write-Host ""
Write-Host "Current branch: $currentBranch"

Write-Host ""
Write-Host "=== INSTALL RULE-TEST DEPENDENCIES ==="

npm install `
    --prefix ".\firebase\rules-tests" `
    --save-dev `
    "@firebase/rules-unit-testing" `
    "firebase"

if ($LASTEXITCODE -ne 0) {
    throw "The Rules test dependency installation failed."
}

Write-Host ""
Write-Host "=== JAVASCRIPT SYNTAX CHECK ==="

node --check `
    ".\firebase\rules-tests\release_readiness.rules.test.cjs"

if ($LASTEXITCODE -ne 0) {
    throw "The JavaScript syntax check failed."
}

Write-Host ""
Write-Host "=== FIREBASE EMULATOR RULE TESTS ==="

firebase emulators:exec `
    --project "demo-churchsnap-release-readiness" `
    --only "firestore,storage" `
    "npm --prefix firebase/rules-tests test"

if ($LASTEXITCODE -ne 0) {
    throw "The Firebase authorization test suite failed."
}

Write-Host ""
Write-Host "=== GIT STATUS ==="

git status --short
