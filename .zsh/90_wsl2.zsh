if [[ $(uname -r) == *'microsoft'* ]]; then

function wsl2help() {
    
}

function open-explorer() {
    explorer.exe $(wslpath -aw $1)
}

function imgcp() {
    powershell_script='
[Reflection.Assembly]::LoadWithPartialName("System.Drawing");
[Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms");

$filename = $Args[0];
$file = get-item($filename);
$img = [System.Drawing.Image]::Fromfile($file);
[System.Windows.Forms.Clipboard]::SetImage($img);
    '

    ps1="$(uuidgen).ps1"
    echo $powershell_script > $ps1
    powershell.exe "./${ps1} $1"
    rm -f $ps1
}

function pasteimg() {
    if [ "$1" != "" ]; then
        file=$1
    else
        file="image.png"
    fi

    powershell.exe "(Get-Clipboard -Format Image).Save('${file}')"
}

fi