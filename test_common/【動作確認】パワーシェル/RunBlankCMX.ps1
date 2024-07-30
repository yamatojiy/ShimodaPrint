# run_cmx_files.ps1
$folderPath = "F:\【Git】ShimodaPrint\test_common\【動作確認】パワーシェル"  # フォルダのパスを指定
$files = Get-ChildItem -Path $folderPath -Filter "*.cmx"

foreach ($file in $files) {
    Start-Process -FilePath $file.FullName
}
