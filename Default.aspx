<%@ Page Language="C#" AutoEventWireup="true" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Web" %>

<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Download - File List</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            max-width: 1200px;
            min-width: 418px;
            margin: 0 auto; 
            padding: 20px; 
            background: #f5f5f5; 
        }
        .container { 
            background: white; 
            padding: 30px; 
            border-radius: 8px; 
            box-shadow: 0 2px 10px rgba(0,0,0,0.1); 
        }
        h1 { 
            color: #333; 
            border-bottom: 2px solid #0078d4; 
            padding-bottom: 10px; 
        }
        .path-info {
            background: #e8f4fc;
            padding: 10px 15px;
            border-radius: 4px;
            margin: 15px 0;
            font-family: monospace;
            color: #0078d4;
        }
        .file-table {
            width: 100%;
            border-collapse: collapse;
            border-spacing: 0 10px;  /**/
            margin-top: 20px;
        }
        .file-table th {
            background: #0078d4;
            color: white;
            padding: 12px;
            text-align: left;
            /* border: none;   */
        }
        .file-table td {
            padding: 10px 12px;
        }
        .file-item { 
            transition: all 0.2s; 
        }
        .file-item:hover { 
            background: #f0f0f0; 
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);  
            transform: translateX(5px);
            /* transform: scale(1.005); */
        }
        /* .file-item td {
            border-radius: 6px;         给单元格添加圆角
            border: 1px solid #eee;     可选：添加边框
        } */
        .file-item td:first-child {  
            border-top-left-radius: 8px;
            border-bottom-left-radius: 8px;
        }

        .file-item td:last-child {  
            border-top-right-radius: 8px;
            border-bottom-right-radius: 8px;
        }
        .file-icon {
            margin-right: 8px;
        }
        .file-name {
            color: #0078d4;
            text-decoration: none;
        }
        .file-name:hover {
            text-decoration: underline;
        }
        .folder-name {
            color: #d4a017;
            font-weight: bold;
        }
        .size-info {
            color: #666;
        }
        .date-info {
            color: #888;
            font-size: 0.9em;
        }
        .search-box {
            margin: 15px 0;
        }
        .search-box input {
            padding: 8px 12px;
            border: 1px solid #ddd;
            border-radius: 4px;
            width: 268px;
        }
        .search-box button {
            padding: 8px 16px;
            background: #0078d4;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        .stats {
            margin-top: 15px;
            padding: 10px;
            background: #f9f9f9;
            border-radius: 4px;
            color: #666;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>📁 文件列表</h1>
        
        <div class="path-info">
            📍 当前路径：<%= GetCurrentPath() %>
        </div>

        <!-- 调试信息（生产环境请删除） -->
        <div style="background: #fff3cd; padding: 10px; margin: 10px 0; border: 1px solid #ffc107;">
            <strong>调试信息：</strong><br/>
            Request.ApplicationPath: <%= Request.ApplicationPath %><br/>
            Request.PhysicalApplicationPath: <%= Request.PhysicalApplicationPath %><br/>
            Server.MapPath("~/"): <%= Server.MapPath("~/") %><br/>
            GetCurrentPhysicalPath(): <%= GetCurrentPhysicalPath() %>
        </div>
        
        <div class="search-box">
            <input type="text" id="searchInput" placeholder="搜索文件名..." />
            <button onclick="searchFiles()">搜索</button>
        </div>
        
        <table class="file-table">
            <thead>
                <tr>
                    <th style="width: 50%;">名称</th>
                    <th style="width: 20%;">大小</th>
                    <th style="width: 30%;">修改日期</th>
                </tr>
            </thead>
            <tbody>
                <% 
                    string[] files = GetFiles();
                    string[] folders = GetFolders();
                    
                    // 显示上级目录
                    if (!IsRootPath()) { 
                        string currentPath = GetCurrentPath().TrimStart('/');  // 去掉前导斜杠
                        int lastSlash = currentPath.LastIndexOf('/');
                        string parentPath = lastSlash > 0 ? currentPath.Substring(0, lastSlash) : "";
                %>
                <tr class="file-item">
                    <td>
                        <span class="file-icon">📁</span>
                        <a href="<%= Request.ApplicationPath %>?path=<%= Server.UrlEncode(parentPath) %>" class="folder-name">..</a>
                    </td>
                    <td class="size-info">-</td>
                    <td class="date-info">-</td>
                </tr>
                <% } %>
                
                <% 
                    // 显示文件夹
                    string folderPath = GetCurrentPath().TrimStart('/');
                    foreach (string folder in folders)
                    {
                        string nextPath = string.IsNullOrEmpty(folderPath) 
                            ? folder 
                            : folderPath + "/" + folder;
                %>
                <tr class="file-item">
                    <td>
                        <span class="file-icon">📁</span>
                        <a href="<%= Request.ApplicationPath %>?path=<%= Server.UrlEncode(nextPath) %>" class="folder-name"><%= folder %></a>
                    </td>
                    <td class="size-info">-</td>
                    <td class="date-info">-</td>
                </tr>
                <% } %>
                
                <% 
                    // 显示文件
                    foreach (string file in files)
                    {
                        string filePath = Path.Combine(GetCurrentPhysicalPath(), file);
                        FileInfo fileInfo = new FileInfo(filePath);
                        string fileSize = FormatFileSize(fileInfo.Length);
                        string fileDate = fileInfo.LastWriteTime.ToString("yyyy-MM-dd HH:mm");
                        string fileIcon = GetFileIcon(file);
                %>
                <tr class="file-item">
                    <td>
                        <span class="file-icon"><%= fileIcon %></span>
                        <a href="<%= Request.ApplicationPath %>/<%= file %>" class="file-name" download><%= file %></a>
                    </td>
                    <td class="size-info"><%= fileSize %></td>
                    <td class="date-info"><%= fileDate %></td>
                </tr>
                <% } %>
            </tbody>
        </table>
        
        <div class="stats">
            共 <%= folders.Length %> 个文件夹，<%= files.Length %> 个文件
        </div>
    </div>
    
    <script>
        function searchFiles() {
            const input = document.getElementById('searchInput');
            const filter = input.value.toUpperCase();
            const table = document.querySelector('.file-table');
            const tr = table.getElementsByTagName('tr');
            
            for (let i = 1; i < tr.length; i++) {
                const td = tr[i].getElementsByTagName('td')[0];
                if (td) {
                    const txtValue = td.textContent || td.innerText;
                    tr[i].style.display = txtValue.toUpperCase().indexOf(filter) > -1 ? '' : 'none';
                }
            }
        }
    </script>
</body>
</html>

<script runat="server">
    // 排除的文件列表
    private string[] excludedFiles = null;
    // 排除的文件夹列表
    private string[] excludedFolders = null;
    
    // 加载排除配置
    private void LoadExcludeConfig()
    {
        if (excludedFiles != null && excludedFolders != null)
        {
            return;
        }
        
        try
        {
            string configPath = Server.MapPath("~/Default_exclude.json");
            if (File.Exists(configPath))
            {
                string json = File.ReadAllText(configPath);
                // 简单解析 JSON（兼容 .NET 4.0）
                excludedFiles = ExtractJsonArray(json, "excludedFiles");
                excludedFolders = ExtractJsonArray(json, "excludedFolders");
            }
        }
        catch
        {
            // 配置加载失败，使用默认值
        }
        
        // 默认排除列表（配置加载失败时使用）
        if (excludedFiles == null)
        {
            excludedFiles = new string[] { "web.config", "Default.aspx", "Default_exclude.json" };
        }
        if (excludedFolders == null)
        {
            excludedFolders = new string[] { "other", "temp" };
        }
    }
    
    // 简单 JSON 数组提取（兼容 .NET 4.0）
    private string[] ExtractJsonArray(string json, string key)
    {
        List<string> result = new List<string>();
        string searchKey = "\"" + key + "\"";
        int keyIndex = json.IndexOf(searchKey);
        if (keyIndex < 0) return result.ToArray();
        
        int arrayStart = json.IndexOf('[', keyIndex);
        int arrayEnd = json.IndexOf(']', arrayStart);
        if (arrayStart < 0 || arrayEnd < 0) return result.ToArray();
        
        string arrayContent = json.Substring(arrayStart + 1, arrayEnd - arrayStart - 1);
        string[] items = arrayContent.Split(',');
        foreach (string item in items)
        {
            string clean = item.Trim().Trim('"').Trim();
            if (!string.IsNullOrEmpty(clean))
            {
                result.Add(clean);
            }
        }
        return result.ToArray();
    }

    // 获取当前物理路径
    private string GetCurrentPhysicalPath()
    {
        // string basePath = Server.MapPath("~/");
        // 使用 Request.ApplicationPath 获取虚拟目录路径
        // string appPath = Request.ApplicationPath;
        // string basePath = Server.MapPath(appPath);
        // string pathParam = Request.QueryString["path"];
        // 优先使用 Request.PhysicalApplicationPath（更可靠）
        string basePath = Request.PhysicalApplicationPath;
    
        // 如果为空，回退到 Server.MapPath
        if (string.IsNullOrEmpty(basePath))
        {
            basePath = Server.MapPath(Request.ApplicationPath);
        }
    
        // 确保路径末尾有分隔符
        if (!basePath.EndsWith(Path.DirectorySeparatorChar.ToString()))
        {
            basePath += Path.DirectorySeparatorChar;
        }
        
        string pathParam = Request.QueryString["path"];
        
        if (string.IsNullOrEmpty(pathParam) || pathParam == "..")
        {
            return basePath;
        }
        
        // 统一路径分隔符
        pathParam = pathParam.Replace('/', Path.DirectorySeparatorChar);
        string fullPath = Path.Combine(basePath, pathParam);
        
        // 安全验证
        if (!fullPath.StartsWith(basePath))
        {
            return basePath;
        }
        
        return fullPath;
    }
    
    // 获取当前显示路径
    private string GetCurrentPath()
    {
        string pathParam = Request.QueryString["path"];
        if (string.IsNullOrEmpty(pathParam))
        {
            return "/";
        }
        // 确保只添加一个前导斜杠
        return "/" + pathParam.TrimStart('/');
    }
    
    // 判断是否为根路径
    private bool IsRootPath()
    {
        string pathParam = Request.QueryString["path"];
        return string.IsNullOrEmpty(pathParam) || pathParam.Trim('/') == "";
    }
    
    // 检查文件是否应该排除
    private bool IsFileExcluded(string fileName)
    {
        LoadExcludeConfig();
        string lowerName = fileName.ToLower();
        foreach (string excluded in excludedFiles)
        {
            if (lowerName == excluded.ToLower())
            {
                return true;
            }
        }
        return false;
    }
    
    // 检查文件夹是否应该排除
    private bool IsFolderExcluded(string folderName)
    {
        LoadExcludeConfig();
        string lowerName = folderName.ToLower();
        foreach (string excluded in excludedFolders)
        {
            if (lowerName == excluded.ToLower())
            {
                return true;
            }
        }
        return false;
    }
    
    // 获取文件列表
    private string[] GetFiles()
    {
        try
        {
            string[] files = Directory.GetFiles(GetCurrentPhysicalPath());
            List<string> filteredFiles = new List<string>();
            foreach (string file in files)
            {
                string fileName = Path.GetFileName(file);
                if (!IsFileExcluded(fileName))
                {
                    filteredFiles.Add(fileName);
                }
            }
            filteredFiles.Sort();
            return filteredFiles.ToArray();
        }
        catch
        {
            return new string[0];
        }
    }
    
    // 获取文件夹列表
    private string[] GetFolders()
    {
        try
        {
            string[] folders = Directory.GetDirectories(GetCurrentPhysicalPath());
            List<string> filteredFolders = new List<string>();
            foreach (string folder in folders)
            {
                string folderName = Path.GetFileName(folder);
                if (!IsFolderExcluded(folderName))
                {
                    filteredFolders.Add(folderName);
                }
            }
            filteredFolders.Sort();
            return filteredFolders.ToArray();
        }
        catch
        {
            return new string[0];
        }
    }
    
    // 格式化文件大小（已修复）
    private string FormatFileSize(long bytes)
    {
        string[] sizes = { "B", "KB", "MB", "GB", "TB" };
        int order = 0;
        double size = bytes;
        
        while (size >= 1024 && order < sizes.Length - 1)
        {
            order++;
            size /= 1024;
        }
        
        return string.Format("{0:0.##} {1}", size, sizes[order]);
    }
    
    // 获取文件图标（已修复）
    private string GetFileIcon(string fileName)
    {
        string extension = Path.GetExtension(fileName).ToLower();
        
        // 修改为传统 switch 语句
        switch (extension)
        {
            case ".pdf":
                return "📄";
            case ".doc":
            case ".docx":
                return "📝";
            case ".xls":
            case ".xlsx":
                return "📊";
            case ".ppt":
            case ".pptx":
                return "📽️";
            case ".zip":
            case ".rar":
            case ".7z":
                return "📦";
            case ".jpg":
            case ".jpeg":
            case ".png":
            case ".gif":
                return "🖼️";
            case ".mp3":
            case ".wav":
                return "🎵";
            case ".mp4":
            case ".avi":
                return "🎬";
            case ".exe":
                return "⚙️";
            case ".txt":
                return "📃";
            case ".html":
            case ".htm":
                return "🌐";
            case ".css":
                return "🎨";
            case ".js":
                return "📜";
            default:
                return "📄";
        }
    }
</script>