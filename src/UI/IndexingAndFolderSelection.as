// Variables and imports specific to this tab
Json::Value[] selectedFiles;
dictionary filesMarkedForCalculation;
SelectedShadowsQuality shadowsQuality = SelectedShadowsQuality::High;

void RenderTab_IndexingAndFolderSelection() {
    UI::Text("Indexing and Folder Selection");
    UI::Separator();
    UI::Text("Index Maps Folder");

    if (UI::Button("Start Indexing Maps Folder")) {
        io.StartIndexingFiles(IO::FromUserGameFolder("Maps/"));
    }

    if (io.IsIndexingInProgress()) {
        int processed = io.get_IndexedFileCountInDirectory();
        int total = io.get_TotalFileCountInDirectory();
        float progress = float(processed) / float(total);
        
        UI::Text("Indexing in progress... " + processed + " / " + total);
        UI::ProgressBar(progress);
    } else {
        UI::Text("Indexing completed.");
    }

    UI::Separator();
    UI::Text("Shadows Quality");

    if (UI::BeginCombo("Shadows Quality", ShadowQualityToString(shadowsQuality))) {
        if (UI::Selectable("None", shadowsQuality == SelectedShadowsQuality::None)) shadowsQuality = SelectedShadowsQuality::None;
        else if (UI::Selectable("Very Fast", shadowsQuality == SelectedShadowsQuality::VeryFast)) shadowsQuality = SelectedShadowsQuality::VeryFast;
        else if (UI::Selectable("Fast", shadowsQuality == SelectedShadowsQuality::Fast)) shadowsQuality = SelectedShadowsQuality::Fast;
        else if (UI::Selectable("Default", shadowsQuality == SelectedShadowsQuality::Default)) shadowsQuality = SelectedShadowsQuality::Default;
        else if (UI::Selectable("High", shadowsQuality == SelectedShadowsQuality::High)) shadowsQuality = SelectedShadowsQuality::High;
        else if (UI::Selectable("Ultra", shadowsQuality == SelectedShadowsQuality::Ultra)) shadowsQuality = SelectedShadowsQuality::Ultra;

        UI::EndCombo();
    }

    UI::Separator();
    UI::Text("Select Folder(s) to Calculate Shadows");

   if (UI::Button("Confirm Selection")) {
        g_isSelectingFiles = true;
        SaveSelectedFiles();
    }

    RenderFolderTree();
}

void RenderFolderTree() {
    Json::Value[] files = io.get_IndexedFiles();

    for (uint i = 0; i < files.Length; i++) {
        string filePath = string(files[i]["filePath"]);
        string folderPath = _IO::Directory::GetParentDirectoryName(filePath);
        
        if (_IO::Directory::IsDirectory(filePath)) {
            if (UI::TreeNode(filePath)) {
                RenderFolderTree();
                UI::TreePop();
            }
        } else if (filePath.EndsWith(".Map.Gbx")) {
            bool selected = filesMarkedForCalculation.Exists(filePath);
            if (UI::Checkbox(filePath, selected)) {
                MarkFileForCalculation(filePath, selected, folderPath);
            }
        }
    }
}

void MarkFileForCalculation(const string &in filePath, bool selected, const string &in folderPath) {
    if (selected) {
        filesMarkedForCalculation.Set(filePath, folderPath);
    } else {
        filesMarkedForCalculation.Delete(filePath);
    }
}

void SaveSelectedFiles() {
    selectedFiles.Resize(0);

    array<string> fileKeys = filesMarkedForCalculation.GetKeys();
    for (uint i = 0; i < fileKeys.Length; i++) {
        Json::Value fileObj = Json::Object();
        string filePath = fileKeys[i];
        string folderPath;
        filesMarkedForCalculation.Get(filePath, folderPath);

        fileObj["filePath"] = filePath;
        fileObj["folderPath"] = folderPath;
        fileObj["shadowQuality"] = int(shadowsQuality);

        selectedFiles.InsertLast(fileObj);
    }
}
