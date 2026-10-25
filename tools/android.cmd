@echo off
rem tools\android.sh for PowerShell and cmd on Windows: runs it with Git Bash in this window.
rem (Given the .sh itself, Windows opens a separate Git Bash window that closes with the output.)
rem   tools\android            export, install, launch
rem   tools\android install    install and launch the last export
rem   tools\android log        the game's output from the phone (ctrl-c to stop)
set "RIFTGATE_BASH=%ProgramFiles%\Git\bin\bash.exe"
if not exist "%RIFTGATE_BASH%" (
	echo Git Bash not found at %RIFTGATE_BASH% 1>&2
	exit /b 1
)
pushd "%~dp0.."
"%RIFTGATE_BASH%" -l tools/android.sh %*
set "RIFTGATE_RC=%ERRORLEVEL%"
popd
exit /b %RIFTGATE_RC%
