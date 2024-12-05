# DPSPrintout.ps1
# 休日には処理を行わないようにするスクリプト

# コーディングをUTF-8 BOMに指定
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8BOM'

# CSVファイルからの日付データの形式を確認
$csvPath = Join-Path $PSScriptRoot "timedCHK.csv"
$csvData = Import-Csv -Path $csvPath

# 日付の形式を調整
$today = Get-Date -Format "yyyy/M/d"  # ゼロ埋めしない形式
$today2 = Get-Date -Format "yyyy-MM-dd"  # ゼロ埋めしない形式


# ファイルの存在確認
if (-Not (Test-Path $csvPath)) {
    Write-Output "指定されたパスにファイルが見つかりません。処理を終了します: $csvPath"
    exit
}

# CSVから休日の日付を読み込む
$holidayDates = $csvData | Select-Object -ExpandProperty "holiday"

# 今日が休日か確認
if ($today -in $holidayDates) {
    Write-Output "今日は休日です。処理を終了します。"
    exit
}

# 休日でなければ通常の印刷処理を続行
Write-Output "今日は休日ではありません。処理を続行します。"
# ---------------------------------------------------
# 桐プログラムを実行する
# ---------------------------------------------------
# スクリプトのディレクトリを取得
$scriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent

# OpsHub.cmx のパスを組み立てる
$OpsHubPath = Join-Path -Path $scriptDirectory -ChildPath "DailyPrintSchedulePrintout.cmx"

# OpsHub.cmx を実行する
Start-Process -FilePath $OpsHubPath

# close_kiri.ps1
Start-Sleep -Seconds 180
Stop-Process -Name "KIRI10" -Force