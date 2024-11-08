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
# ---------------------------------------------------
# 複数のPDFファイルを指定の設定で印刷
# ---------------------------------------------------
# 共通設定
$printerName = "OKI C811(PCL)"
# スクリプトのディレクトリからログディレクトリの相対パスを設定
$logDirectory = Join-Path $PSScriptRoot "PDF\log"

# ログディレクトリの存在確認
if (-Not (Test-Path $logDirectory)) {
    New-Item -ItemType Directory -Path $logDirectory -Force
    Write-Output "ログディレクトリが存在しなかったため、新しく作成しました: $logDirectory"
}

$sumatraPath = Join-Path $env:LOCALAPPDATA "SumatraPDF\SumatraPDF.exe"

# 印刷タスクの定義
$printJobs = @(
    @{
        Directory = Join-Path $PSScriptRoot "PDF\PrintSchedule"
        FileFormat = "_PrintSchedule.pdf"
        PaperSize = "a3"
        Copies = 4
    },
    @{
        Directory = Join-Path $PSScriptRoot "PDF\MainSchedule"
        FileFormat = "_MainSchedule.pdf"
        PaperSize = "a4"
        Copies = 1
    },
    @{
        Directory = Join-Path $PSScriptRoot "PDF\PshortSchedule"
        FileFormat = "_PrintSchedule.pdf"
        PaperSize = "a4"
        Copies = 1
    }
)

# スクリプトの開始ログを生成
Start-Transcript -Path "$logDirectory\$today-log.txt"

# 各印刷タスクを実行
foreach ($job in $printJobs) {
    $pdfFile = "$($job.Directory)\$today2$($job.FileFormat)"
    if (Test-Path $pdfFile) {
        Write-Output "ファイルが見つかりました: $pdfFile"
        for ($i = 0; $i -lt $job.Copies; $i++) {
            $arguments = "-print-to `"$printerName`" -print-settings `"`"paper=$($job.PaperSize)`"`" `"$pdfFile`""
            Start-Process -FilePath $sumatraPath -ArgumentList $arguments -NoNewWindow
            Write-Output "印刷コマンドが実行されました。プリンター設定：$($job.PaperSize)、片面印刷、回数：$(1 + $i)"
            Start-Sleep -Seconds 10
        }
    } else {
        Write-Output "ファイルは見つかりませんでした: $pdfFile"
    }
}

# スクリプトの終了ログを生成
Stop-Transcript
Write-Output "全工程が完了しました。"
