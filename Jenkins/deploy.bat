@echo off
set "usage=Usage: %0 ^<pull request ID^> ^<Password^>"
if "%1"=="" (
	echo %usage%
	exit /b 1
)
if "%2"=="" (
	echo %usage%
	exit /b 1
)
if "%apsimx%"=="" set "apsimx=%~dp0.."

rem Generate API docs
cd "%apsimx%\Docs\docfx"
docfx

if errorlevel 1 (
	echo Error generating API documentation
	exit /b 1
)

rem Upload API docs to website
rem FTPing every file would be very slow. An rsync/ssh-based solution would be ideal,
rem unfortunately port 22 is locked down and that's apparently not going to change. 😡
rem This build machine is going to be retired "soon", so in the long term this problem
rem should disappear. In the short term, we will FTP(!) up a zip archive, and then expect
rem the server to magically unzip it.

cd "%apsimx%\Docs"
7z a apsimx-docs.zip apsimx-docs
@curl -s -u !APSIM_SITE_CREDS! -T apsimx-docs.zip ftp://apsimdev.apsim.info/APSIM/
rem rsync -arz apsimx-docs/ admin@apsimdev.apsim.info:/cygdrive/d/Websites/APSIM/apsimx-docs/

rem Add build to builds database
@curl -f "https://apsimdev.apsim.info/APSIM.Builds.Service/Builds.svc/AddBuild?pullRequestNumber=%1&ChangeDBPassword=%2"
if errorlevel 1 exit /b 1

rem Trigger a netlify build
if "%NETLIFY_BUILD_HOOK%"=="" (
	echo Error - netlify build hook not supplied
	exit /b 1
)

@curl -X POST -d {} https://api.netlify.com/build_hooks/%NETLIFY_BUILD_HOOK%
if errorlevel 1 (
	echo Error triggering netlify build
	exit /b 1
)
