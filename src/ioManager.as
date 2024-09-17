namespace IOManager {
    Json::Value indexedHierarchy;
    bool isIndexing = false;

    void Initialize() {
        log("IOManager Initialized.", LogLevel::Info);
        indexedHierarchy = Json::Object();
    }

    void StartIndexing(const string &in folderPath) {
        startnew(CoroutineFuncUserdataString(coro_StartIndexing), folderPath);
    }

    void coro_StartIndexing(const string &in folderPath) {
        log("Starting hierarchical indexing for folder: " + folderPath, LogLevel::Info);
        isIndexing = true;
        indexedHierarchy = Json::Object();
        IndexFolderRecursively(folderPath, indexedHierarchy);
        isIndexing = false;
        log("Indexing completed.", LogLevel::Info);
    }

    void IndexFolderRecursively(const string &in folderPath, Json::Value@ folderJson) {
        folderJson["path"] = folderPath;
        folderJson["files"] = Json::Array();
        folderJson["folders"] = Json::Array();
        
        string[]@ files = IO::IndexFolder(folderPath, false);
        
        Json::Value filesArray = Json::Array();
        Json::Value foldersArray = Json::Array();
        
        for (uint i = 0; i < files.Length; i++) {
            string filePath = files[i];

            if (_IO::Directory::IsDirectory(filePath)) {
                Json::Value subfolder = Json::Object();
                IndexFolderRecursively(filePath, subfolder);
                foldersArray.Add(subfolder);
            } else {
                Json::Value fileJson = Json::Object();
                fileJson["filePath"] = filePath;
                fileJson["fileSize"] = int(IO::FileSize(filePath));
                fileJson["fileCreatedTime"] = int(IO::FileCreatedTime(filePath));
                fileJson["fileModifiedTime"] = int(IO::FileModifiedTime(filePath));
                filesArray.Add(fileJson);
            }

            if (i % 137 == 0) {
                yield();
            }
        }

        folderJson["files"] = filesArray;
        folderJson["folders"] = foldersArray;
    }

    Json::Value GetIndexedHierarchy() {
        return indexedHierarchy;
    }

    int GetTotalFileCount() {
        return CountFilesInHierarchy(indexedHierarchy);
    }

    bool IsIndexingInProgress() {
        return isIndexing;
    }

    // FIXME: Hierarchical count check always returns 0
    int CountFilesInHierarchy(Json::Value@ folder) {
        int totalCount = 0;
        
        if (folder.GetType() != Json::Type::Object) return 0;

        if (folder.HasKey("files") && folder["files"].GetType() == Json::Type::Array) {
            totalCount += folder["files"].Length;
        }

        if (folder.HasKey("folders") && folder["folders"].GetType() == Json::Type::Array) {
            Json::Value subfolders = folder["folders"];
            for (uint i = 0; i < subfolders.Length; i++) {
                totalCount += CountFilesInHierarchy(subfolders[i]);
            }
        }

        return totalCount;
    }
}
