# PowerShellスクリプト - 複数のPDFファイルを指定の設定で印刷

# 日付の設定
$today = Get-Date -Format "yyyy-MM-dd"

# 共通設定
$printerName = "OKI C811(PCL)"
$logDirectory = "F:\【Git】ShimodaPrint\System\work\DailyPrintSchedulePrintout\PDF\log"
$sumatraPath = "C:\Users\mng-1\AppData\Local\SumatraPDF\SumatraPDF.exe"

# 印刷タスクの定義
$printJobs = @(
    @{
        Directory = "F:\【Git】ShimodaPrint\System\work\DailyPrintSchedulePrintout\PDF\PrintSchedule"
        FileFormat = "_PrintSchedule.pdf"
        PaperSize = "a3"
        Copies = 2  # 前回からの設定
    },
    @{
        Directory = "F:\【Git】ShimodaPrint\System\work\DailyPrintSchedulePrintout\PDF\MainSchedule"
        FileFormat = "_MainSchedule.pdf"
        PaperSize = "a4"  # A4縦
        Copies = 1
    },
    @{
        Directory = "F:\【Git】ShimodaPrint\System\work\DailyPrintSchedulePrintout\PDF\PshortSchedule"
        FileFormat = "_PrintSchedule.pdf"
        PaperSize = "a4"  # A4縦
        Copies = 1
    }
)

# スクリプトの開始ログを生成
Start-Transcript -Path "$logDirectory\$today-log.txt"

# 各印刷タスクを実行
foreach ($job in $printJobs) {
    $pdfFile = "$($job.Directory)\$today$($job.FileFormat)"
    if (Test-Path $pdfFile) {
        Write-Output "ファイルが見つかりました: $pdfFile"
        for ($i = 0; $i -lt $job.Copies; $i++) {
            $arguments = "-print-to `"$printerName`" -print-settings `"`"paper=$($job.PaperSize)`"`" `"$pdfFile`""
            Start-Process -FilePath $sumatraPath -ArgumentList $arguments -NoNewWindow
            Write-Output "印刷コマンドが実行されました。プリンター設定：$($job.PaperSize)、片面印刷、回数：$(1 + $i)"
            Start-Sleep -Seconds 10 # プリンタが印刷を開始するまでの遅延
        }
    } else {
        Write-Output "ファイルは見つかりませんでした: $pdfFile"
    }
}

# スクリプトの終了ログを生成
Stop-Transcript
Write-Output "全工程が完了しました。"
