using System.Xml;

// 加载排除配置（XML 版本）
private void LoadExcludeConfig()
{
    if (excludedFiles != null && excludedFolders != null)
    {
        return;
    }
    try
    {
        string configPath = Server.MapPath("~/Default_exclude.xml");
        if (File.Exists(configPath))
        {
            XmlDocument doc = new XmlDocument();
            doc.Load(configPath);
            
            List<string> files = new List<string>();
            XmlNodeList fileNodes = doc.SelectNodes("//Files/Item");
            foreach (XmlNode node in fileNodes)
            {
                files.Add(node.InnerText);
            }
            excludedFiles = files.ToArray();
            
            List<string> folders = new List<string>();
            XmlNodeList folderNodes = doc.SelectNodes("//Folders/Item");
            foreach (XmlNode node in folderNodes)
            {
                folders.Add(node.InnerText);
            }
            excludedFolders = folders.ToArray();
        }
    }
    catch { }
    if (excludedFiles == null)
    {
        excludedFiles = new string[] { "web.config", "Default.aspx" };
    }
    if (excludedFolders == null)
    {
        excludedFolders = new string[] { "other", "temp" };
    }
}