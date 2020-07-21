#cs ----------------------------------------------------------------------------

   Name:			FuckThatVAC (AutoIt VAC-Bypass-Loader)
   AutoIt Version:	3.3.14.5
   Author:        	@zxsleebu
   Github:			https://github.com/zxsleebu


   Script Function:
	  Template AutoIt script.

#ce ----------------------------------------------------------------------------
#include "Injector.au3"
#RequireAdmin

; Defining some variables

$steamPath = "C:\Program Files (x86)\Steam\steam.exe"
$vacBypassPath = "VAC-Bypass.dll"
$process = "steam.exe"
$launchOptions = "-nocrashdialog -nocrashmonitor -silent -norepairfiles -noverifyfiles -nodircheck"

; Breaking internet connection
RunWait('ipconfig /release', @TempDir, @SW_HIDE)

; Killing Steam process
RunWait('taskkill /f /im steam.exe', @TempDir, @SW_HIDE)
RunWait('taskkill /f /im steamservice.exe', @TempDir, @SW_HIDE)
RunWait('taskkill /f /im streaming_client.exe', @TempDir, @SW_HIDE)
RunWait('taskkill /f /im steamerrorreporter.exe', @TempDir, @SW_HIDE)
RunWait('taskkill /f /im GameOverlayUI.exe', @TempDir, @SW_HIDE)

; Running the process that will make you smile
Run("FuckThatVAC-Stop.exe", @TempDir, @SW_HIDE)

$inject = CreateProcessEx($steamPath, $vacBypassPath, $launchOptions)