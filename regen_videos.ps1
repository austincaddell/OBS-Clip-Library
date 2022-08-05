param([switch]$Elevated)
function Test-Admin {
$currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())

$currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}
if ((Test-Admin) -eq $false)
{
if ($elevated) {
# tried to elevate, did not work, aborting
} else {
Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
}
Exit
}
'running with full privileges'
$directory = Split-Path $MyInvocation.MyCommand.Path -Parent
$folder = $directory + "\videos"

#cd $folder

$files = Get-ChildItem $folder -Name -Depth 1

'echo $files'

$tabs = ""
$pre_command_string = "var myvids = [" + $tabs
$command_string = ""
$post_command_string = ""
$complete_command_string = ""

$i = 0

while($i -lt $files.Length ){

    $command_string = $command_string + "'" + $files[$i] + "'," + $tabs

    $i = $i + 1
}




#foreach ($file in $files){
#    
#    $command_string = $command_string + "'" + $file.PSChildName + "',`n" + $tabs
#
#}

$command_string = $command_string.Substring(0,$command_string.Length-1)

$post_command_string = "]"

$complete_command_string = $pre_command_string + $command_string + $post_command_string

'writing file'
echo ((Get-Content -path ("$directory" + "\index.html") -Raw) -Replace 'var myvids = \[(.*?)\]', $complete_command_string) | Set-Content -Path ("$directory" + "\index.html")
exit