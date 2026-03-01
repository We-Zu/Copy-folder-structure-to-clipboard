# 复制文件夹结构到剪贴板
用AI生成了一个win10资源管理器文件夹右键复制文件树到剪贴板的脚本，可以生成文件树，自定义生成的文件和文件夹的头和尾。
配置方法：
1.将脚本保存到自定义路径（例如 C:\Program Files\右键菜单脚本\复制文件夹结构到剪贴板.ps1）。
2.修改注册表创建文件夹右键菜单
2.1注册表创建项：计算机\HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\shell\CopyTreeToClipboard\command
2.2修改CopyTreeToClipboard字符串数值数据为要显示的右键菜单名称，如：复制文件夹结构到剪贴板
2.3修改command字符串数值数据为：powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File "自定义的脚本路径" -FolderPath "%1"

目前只在win10 22H2上测试过。
