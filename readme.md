# 开启iis服务器目录浏览美化

## IIS 配置建议

1. 确保网页根目录文件夹存在且有读取权限
2. 在 `web.config` 中配置允许的文件类型
3. 如需限制访问，可添加身份验证

```xml
<configuration>
    <system.webServer>
        <directoryBrowse enabled="false" />
    </system.webServer>
</configuration>
```

4. 网站目录结构如下：

```
网站根目录/
├── Default.aspx      ← 关键文件
├── Default_exclude.json            ← 存放需排除的文件/文件夹
├── Default_exclude.xml（可选）      ← 存放需排除的文件/文件夹
├── {others}
└── web.config
```

####  配置 IIS 默认文档

1. 打开 **IIS 管理器**
2. 选择需要配置的网站
3. 双击 **默认文档**
4. 确保 `Default.aspx` 在列表中，如没有则添加

#### web.config 文件

在网站根目录打开 `web.config` ，确认如下关键内容是否一致：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <!-- <system.web>
        <compilation debug="true" targetFramework="4.7.2" />
        <httpRuntime targetFramework="4.7.2" />
    </system.web> -->
    <system.webServer>
        <defaultDocument>
        <files>
            <clear />
            <add value="Default.aspx" />
        </files>
        </defaultDocument>
        <directoryBrowse enabled="false" />
    </system.webServer>
</configuration>
```

#### 检查应用程序池设置

1. 打开 **IIS 管理器** → **应用程序池**
2. 找到对应网站的应用程序池
3. 右键 → **高级设置**
4. 确保：
   - `.NET CLR 版本` = `v4.0`
   - `托管管道模式` = `Integrated`

#### 设置文件夹权限

```powershell
# 给 IIS 用户授予读取权限
icacls "{your_folder_path}" /grant "IIS_IUSRS:(OI)(CI)R"
```

## 启用 ASP.NET 功能

1. 打开 **控制面板** → **程序和功能**
2. **启用或关闭 Windows 功能**
3. 展开 **Internet Information Services**
4. 确保勾选：
   - `ASP.NET 4.8`
   - `.NET Extensibility 4.8`
   - `ISAPI Extensions`
   - `ISAPI Filters`

### 🛠️ 快速验证

创建 [`test.aspx`](test.aspx) 测试文件验证 ASP.NET 是否工作：


访问 `http://{your_website_url}/test.aspx`，如果正常显示则 ASP.NET 配置正确。

### 📋 检查清单

-  `Downloads` 文件夹已创建
-  `Default.aspx` 在默认文档列表中
-  `web.config` 文件存在且配置正确
-  应用程序池使用 .NET 4.x
-  IIS_IUSRS 有文件夹读取权限
-  ASP.NET 功能已启用

完成以上检查后，重启 IIS

## 配置排除内容

### 方案一

在网站根目录内创建 [`Default_exclude.json`](Default_exclude.json) ，根据需求新增需要排除的文件或文件夹

```json
{
  // 需要排除的文件
  "excludedFiles": [
    "{file_name}"
  ],
  // 需要排除的文件夹
  "excludedFolders": [
    "{folder_name}"
  ]
}
```

### 方案二

1. 创建 `Default_exclude.xml`

2. 把 [Default.aspx](Default.aspx) 中的 `private void LoadExcludeConfig()` 函数修改为 [`Default_exclude_xml.aspx`](Default_exclude_xml.aspx) 中的函数，以读取 XML 文件


### 📋 方案对比

| 方案     | 优点                    | 缺点                | 推荐度 |
| :------- | :---------------------- | :------------------ | :----- |
| **JSON** | 格式标准，易读          | .NET 4.0 需手动解析 | ⭐⭐⭐⭐   |
| **XML**  | .NET 原生支持，结构清晰 | 文件稍大            | ⭐⭐⭐⭐   |

## 配置 Default.aspx

在网站根目录内创建 `Default.aspx` ，将 [`Default.aspx`](Default.aspx) 中的内容拷贝至本地 `Default.aspx` 内，并另存为 `UTF-8 with BOM` 编码**（重要）**，覆盖原 `Default.aspx`