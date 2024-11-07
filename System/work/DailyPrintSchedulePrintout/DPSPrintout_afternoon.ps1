# DPSPrintout.ps1
# �X�N���v�g�̖ړI: �w������x���̏ꍇ�͏������s�킸�A�x���łȂ���Ύw�肳�ꂽPDF��������܂��B

# �X�N���v�g�̃f�B���N�g�����擾
$scriptDirectory = $PSScriptRoot

# OpsHub.cmx �̃p�X��g�ݗ��Ă�
$OpsHubPath = Join-Path -Path $scriptDirectory -ChildPath "DailyPrintSchedulePrintout.cmx"

# OpsHub.cmx �����s����
Start-Process -FilePath $OpsHubPath

# close_kiri.ps1 �ɑ������鏈�������s��A�v���Z�X�������I��
Start-Sleep -Seconds 180
Stop-Process -Name "KIRI10" -Force

# ���t�̐ݒ�
$today = Get-Date -Format "yyyy-MM-dd"

# ���ʐݒ�
$printerName = "OKI C811(PCL)"
$logDirectory = Join-Path $scriptDirectory "PDF\log"
$sumatraPath = Join-Path $env:LOCALAPPDATA "SumatraPDF\SumatraPDF.exe"

# ���O�f�B���N�g���̊m�F�ƍ쐬
if (-Not (Test-Path $logDirectory)) {
    New-Item -ItemType Directory -Path $logDirectory -Force
}

# ����^�X�N�̒�`
$printJobs = @(
    @{
        Directory = Join-Path $scriptDirectory "PDF\PrintSchedule"
        FileFormat = "_PrintSchedule.pdf"
        PaperSize = "a3"
        Copies = 4
    }
)

# �X�N���v�g�̊J�n���O�𐶐�
Start-Transcript -Path (Join-Path $logDirectory "$today-log.txt")

# �e����^�X�N�����s
foreach ($job in $printJobs) {
    $pdfFile = Join-Path $job.Directory "$today$job.FileFormat"
    if (Test-Path $pdfFile) {
        Write-Output "�t�@�C����������܂���: $pdfFile"
        for ($i = 0; $i -lt $job.Copies; $i++) {
            $arguments = "-print-to `"$printerName`" -print-settings `"`"paper=$job.PaperSize`"`" `"$pdfFile`""
            Start-Process -FilePath $sumatraPath -ArgumentList $arguments -NoNewWindow
            Write-Output "����R�}���h�����s����܂����B�v�����^�[�ݒ�F$job.PaperSize�A�Жʈ���A�񐔁F$(1 + $i)"
            Start-Sleep -Seconds 10 # �v�����^��������J�n����܂ł̒x��
        }
    } else {
        Write-Output "�t�@�C���͌�����܂���ł���: $pdfFile"
    }
}

# �X�N���v�g�̏I�����O�𐶐�
Stop-Transcript
Write-Output "�S�H�����������܂����B"
