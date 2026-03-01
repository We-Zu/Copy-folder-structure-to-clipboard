param(
    [string]$FolderPath
)

# ========== 配置区 ==========
# 缩进宽度：每个层级增加的空格数（建议 4，若需更宽请修改此值）
$indentWidth = 4
# 日志文件路径（桌面，确保可写）
# $logFile = "$env:USERPROFILE\Desktop\CopyTree.log"
# 自定义文件夹名称前后缀（包裹文件夹名，默认空格）
$folderPrefix = '📁'
$folderSuffix = ' '
# 自定义文件名称前后缀（将包裹文件名，保留前面的 ▷ 符号，默认空格）
$filePrefix = '📄'
$fileSuffix = ' '



# ===========================

# function Write-Log($message) {
#     "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $message" | Out-File $logFile -Append
# }

# Write-Log "===== 开始 ====="
# Write-Log "接收到的路径: $FolderPath"

# 验证参数
if (-not $FolderPath) {
#     Write-Log "错误：未接收到文件夹路径"
    exit 1
}
if (-not (Test-Path -LiteralPath $FolderPath -PathType Container)) {
#     Write-Log "错误：路径不是有效文件夹 - $FolderPath"
    exit 1
}

# 递归函数：返回字符串数组（每行代表树的一行）
function Get-TreeLines {
    param(
        [string]$Path,
        [string]$Indent = ''          # 当前行的缩进前缀（不含树枝符号）
    )

    $lines = @()
    try {
        # 获取所有项目（包括隐藏和系统文件）
        $items = Get-ChildItem -LiteralPath $Path -Force -ErrorAction Stop
#         Write-Log "处理路径: $Path, 项目数: $($items.Count)"
    } catch {
#         Write-Log "访问错误: $_"
        return @("$Indent[访问错误: $_]")
    }

    # 分离文件夹和文件
    $folders = $items | Where-Object { $_.PSIsContainer }
    $files   = $items | Where-Object { -not $_.PSIsContainer }

    $total = $folders.Count + $files.Count
    $i = 0

    # 处理文件夹
    foreach ($folder in $folders) {
        $i++
        $isLast = ($i -eq $total)
        $prefix = if ($isLast) { '┗━' } else { '┣━' }
        $lines += "$Indent$prefix$folderPrefix$($folder.Name)$folderSuffix"

        # 递归子文件夹：生成下一级的缩进
        # 树枝符号：非最后一项用 "┃"，最后一项用空格
        $branch = if ($isLast) { ' ' } else { '┃' }
        # 下一级缩进 = 当前缩进 + 树枝符号 + 指定数量的空格
        $nextIndent = $Indent + $branch + (' ' * $indentWidth)
        $subLines = Get-TreeLines -Path $folder.FullName -Indent $nextIndent
        $lines += $subLines   # 直接追加数组
    }

    # 处理文件（文件名前加 ▷）
    foreach ($file in $files) {
        $i++
        $isLast = ($i -eq $total)
        $prefix = if ($isLast) { '┗━▷' } else { '┣━▷' }
        $lines += "$Indent$prefix$filePrefix$($file.Name)$fileSuffix"
    }

    return $lines
}

# 生成所有行：首行为路径，后跟树结构
$allLines = @($FolderPath) + (Get-TreeLines -Path $FolderPath -Indent '')
$output = $allLines -join "`r`n"

# 记录输出统计
$lineCount = $allLines.Count
$outputLength = $output.Length
# Write-Log "总行数: $lineCount, 总字符数: $outputLength"
if ($outputLength -gt 0) {
    $preview = $output.Substring(0, [Math]::Min(500, $outputLength))
#     Write-Log "输出预览(前500字符):`r`n$preview"
} else {
#     Write-Log "警告：输出为空！"
}

# 复制到剪贴板
try {
    $output | Set-Clipboard -ErrorAction Stop
#     Write-Log "复制到剪贴板成功"
} catch {
#     Write-Log "Set-Clipboard 失败: $_"
    try {
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.Clipboard]::SetText($output)
#         Write-Log "备用方法成功"
    } catch {
#         Write-Log "备用方法也失败: $_"
        exit 1
    }
}

# Write-Log "===== 完成 ====="
exit 0