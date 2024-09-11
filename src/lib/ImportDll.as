Import::Library@ lib = null;
InputOutput@ io = null;

void PrepareDll() {
    log("Preparing I/O operations.", LogLevel::Info, 17, "PrepareDll");
    
    @lib = GetLibraryFunctions();
    if (lib is null) {
        log("Failed to load library functions.", LogLevel::Error, 21, "PrepareDll");
        return;
    }
    
    @io = InputOutput(lib);
}

Import::Library@ GetLibraryFunctions() {
    const string relativeDllPath = "src/lib/inout.dll";
    const string baseFolder = IO::FromDataFolder('');
    const string localDllFile = baseFolder + relativeDllPath;

    if (!IO::FileExists(localDllFile)) {
        IO::CreateFolder(Path::GetDirectoryName(localDllFile));

        try {
            IO::FileSource zippedDll(relativeDllPath);
            IO::File toItem(localDllFile, IO::FileMode::Write);
            toItem.Write(zippedDll.Read(zippedDll.Size()));
            toItem.Close();
        } catch {
            return null;
        }
    }

    return Import::GetLibrary(localDllFile);
}

class InputOutput {
    Import::Function@ index_files;
    Import::Function@ get_total_files;
    Import::Function@ get_files_processed;
    Import::Function@ is_indexing_in_progress;

    InputOutput(Import::Library@ lib) {
        if (lib !is null) {
            @index_files = lib.GetFunction("StartIndexing");
            @get_total_files = lib.GetFunction("GetTotalFilesToIndex");
            @get_files_processed = lib.GetFunction("GetFilesProcessed");
            @is_indexing_in_progress = lib.GetFunction("IsIndexingInProgress");
        }
    }

    void IndexFiles(const string &in folderPath) {
        if (index_files is null) return;
        index_files.Call(folderPath);
    }

    int GetTotalFiles() {
        if (get_total_files is null) return 0;
        return get_total_files.CallInt32();
    }

    int GetFilesProcessed() {
        if (get_files_processed is null) return 0;
        return get_files_processed.CallInt32();
    }

    bool IsIndexingInProgress() {
        if (is_indexing_in_progress is null) return false;
        return is_indexing_in_progress.CallBool();
    }
}

void StartIndexingProcess(const string &in path) {
    if (io is null) {
        log("I/O operations not initialized.", LogLevel::Error, 89, "StartIndexingProcess");
        return;
    }
    
    const string folderToIndex = path;
    io.IndexFiles(folderToIndex);
    
    while (io.IsIndexingInProgress()) {
        int processed = io.GetFilesProcessed();
        int total = io.GetTotalFiles();
        float progress = float(processed) / float(total);
        
        print("Progress: " + (progress * 100) + "%");
        sleep(100);
    }
    
    log("Indexing process completed.", LogLevel::Info, 105, "StartIndexingProcess");
}
