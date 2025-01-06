# 01_DataOrganization.ps1

# スクリプトのディレクトリを取得
$scriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent

# OpsHub.cmx のパスを組み立てる
$OpsHubPath = Join-Path -Path $scriptDirectory -ChildPath "DailyOpsHub.cmx"

# OpsHub.cmx を実行する
Start-Process -FilePath $OpsHubPath

# close_kiri.ps1
Start-Sleep -Seconds 1800
Stop-Process -Name "KIRI10" -Force