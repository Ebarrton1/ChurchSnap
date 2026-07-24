$ErrorActionPreference = "Stop"

$expectedBranch = "churchsnap-release-readiness-hardening"
$currentBranch = git branch --show-current

if ($currentBranch -ne $expectedBranch) {
    throw "Expected branch '$expectedBranch', but current branch is '$currentBranch'."
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
Write-Host "=== INSTALL RULE-TEST DEPENDENCIES ==="

npm install `
    --prefix ".\firebase\rules-tests" `
    --save-dev `
    "@firebase/rules-unit-testing" `
    "firebase"

Write-Host ""
Write-Host "=== JAVASCRIPT SYNTAX CHECK ==="

node --check `
    ".\firebase\rules-tests\release_readiness.rules.test.cjs"

Write-Host ""
Write-Host "=== FIREBASE EMULATOR RULE TESTS ==="

firebase emulators:exec `
    --project "demo-churchsnap-release-readiness" `
    --only "firestore,storage" `
    "npm --prefix firebase/rules-tests test"

Write-Host ""
Write-Host "=== CREATED TEST FILES ==="

Get-ChildItem `
    -Path ".\firebase\rules-tests" `
    -File |
    Select-Object Name, Length, LastWriteTime

Write-Host ""
Write-Host "=== GIT STATUS ==="

git status --short
