@echo off
if not exist APSIM.Shared (
	git clone https://github.com/APSIMInitiative/APSIM.Shared APSIM.Shared
)
git -C APSIM.Shared pull origin master

if "%1"=="macos" (
	docker build -t createosxinstallation ApsimX\\Docker\\osx\\CreateInstallation
	docker run -e APSIM_SITE_CREDS -e ISSUE_NUMBER -v %cd%\ApsimX:C:\ApsimX -v %cd%\APSIM.Shared:C:\APSIM.Shared createosxinstallation %1
) else (
	docker build -m 16g -t createinstallation ApsimX\\Docker\\CreateInstallation
	docker run -m 16g --cpu-count %NUMBER_OF_PROCESSORS% --cpu-percent 100 -e APSIM_SITE_CREDS -e NUMBER_OF_PROCESSORS -e ISSUE_NUMBER -v %cd%\ApsimX:C:\ApsimX -v %cd%\APSIM.Shared:C:\APSIM.Shared createinstallation %1
)
