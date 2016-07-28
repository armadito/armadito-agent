@echo off

for /f "tokens=2*" %%a in ('REG QUERY "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\FusionInventory-Agent" /v InstallLocation') do set "FusionPath=%%~b"

if defined FusionPath (
	if not exist "%FusionPath%\\perl\\bin\\perl.exe" (
		echo FusionInventory Agent embedded perl not found.
		exit /b
	) else (
		"%FusionPath%\\perl\\bin\\perl.exe" armadito-agent %*
		exit /b
	)
) else (
    echo FusionInventory Agent installLocation not found.
	exit /b
)
