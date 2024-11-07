# DPSPrintout.ps1
# スクリプトの目的: 指定日が休日の場合は処理を行わず、休日でなければ指定されたPDFを印刷します。

# スクリプトのディレクトリを取得
$scriptDirectory = $PSScriptRoot

# OpsHub.cmx のパスを組み立てる
$OpsHubPath = Join-Path -Path $scriptDirectory -ChildPath "DailyPrintSchedulePrintout.cmx"

# OpsHub.cmx を実行する
Start-Process -FilePath $OpsHubPath

# close_kiri.ps1 に相当する処理を実行後、プロセスを強制終了
Start-Sleep -Seconds 180
Stop-Process -Name "KIRI10" -Force

# 日付の設定
$today = Get-Date -Format "yyyy-MM-dd"

# 共通設定
$printerName = "OKI C811(PCL)"
$logDirectory = Join-Path $scriptDirectory "PDF\log"
$sumatraPath = Join-Path $env:LOCALAPPDATA "SumatraPDF\SumatraPDF.exe"

# ログディレクトリの確認と作成
if (-Not (Test-Path $logDirectory)) {
    New-Item -ItemType Directory -Path $logDirectory -Force
}

# 印刷タスクの定義
$printJobs = @(
    @{
        Directory = Join-Path $scriptDirectory "PDF\PrintSchedule"
        FileFormat = "_PrintSchedule.pdf"
        PaperSize = "a3"
        Copies = 4
    }
)

# スクリプトの開始ログを生成
Start-Transcript -Path (Join-Path $logDirectory "$today-log.txt")

# 各印刷タスクを実行
foreach ($job in $printJobs) {
    $pdfFile = Join-Path $job.Directory "$today$job.FileFormat"
    if (Test-Path $pdfFile) {
        Write-Output "ファイルが見つかりました: $pdfFile"
        for ($i = 0; $i -lt $job.Copies; $i++) {
            $arguments = "-print-to `"$printerName`" -print-settings `"`"paper=$job.PaperSize`"`" `"$pdfFile`""
            Start-Process -FilePath $sumatraPath -ArgumentList $arguments -NoNewWindow
            Write-Output "印刷コマンドが実行されました。プリンター設定：$job.PaperSize、片面印刷、回数：$(1 + $i)"
            Start-Sleep -Seconds 10 # プリンタが印刷を開始するまでの遅延
        }
    } else {
        Write-Output "ファイルは見つかりませんでした: $pdfFile"
    }
}

# スクリプトの終了ログを生成
Stop-Transcript
Write-Output "全工程が完了しました。"
