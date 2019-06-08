
# KLAVIATUURIKEELTE SEADISTAMINE
Set-WinUserLanguageList -LanguageList en-US,et -Force


# PROTSESSI AVAMINE VALITUD VAHELEHTEDEGA
Start-Process Chrome "google.ee" , "neti.ee"


Function Set-WallPaper($Value)
{
 Set-ItemProperty -path 'HKCU:\Control Panel\Desktop\' -name wallpaper -value $Value

 rundll32.exe user32.dll, UpdatePerUserSystemParameters
 }

Set-WallPaper ( "C:\Users\rakoit\Desktop\pilt.jpg" )


# Kustutan Downloads kausta
Remove-Item "C:\Users\rakoit\Downloads\" –Recurse


# IP addressi saamine
Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE -ComputerName . | Format-Table -Property IPAddress

# Tervita inimest
Add-Type -AssemblyName System.speech
$speak = New-Object System.Speech.Synthesis.SpeechSynthesizer
$speak.Speak('Hello')