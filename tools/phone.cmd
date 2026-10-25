@echo off
rem tools\phone.sh for PowerShell and cmd on Windows: runs it with Git Bash in this window.
rem (Given the .sh itself, Windows opens a separate Git Bash window that closes with the output.)
rem   tools\phone              export, then serve (ctrl-c to stop)
rem   tools\phone serve        serve the last export
set "RIFTGATE_BASH=%ProgramFiles%\Git\bin\bash.exe"
if not exist "%RIFTGATE_BASH%" (
	echo Git Bash not found at %RIFTGATE_BASH% 1>&2
	exit /b 1
)
pushd "%~dp0.."
"%RIFTGATE_BASH%" -l tools/phone.sh %*
set "RIFTGATE_RC=%ERRORLEVEL%"
popd
exit /b %RIFTGATE_RC%
