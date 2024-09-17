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
    private Import::Function@ start_indexing_files;
    private Import::Function@ get_total_file_count_in_directory;
    private Import::Function@ get_indexed_file_count_in_directory;
    private Import::Function@ is_indexing_in_progress;
    private Import::Function@ current_indexed_file_Name;
    private Import::Function@ get_indexed_files;

    InputOutput(Import::Library@ lib) {
        if (lib !is null) {
            @start_indexing_files = lib.GetFunction("StartIndexingFiles");
            @is_indexing_in_progress = lib.GetFunction("is_IndexingInProgress");
            @get_total_file_count_in_directory = lib.GetFunction("get_TotalFilesToIndex");
            @get_indexed_file_count_in_directory = lib.GetFunction("get_CurrentIndexedFiles");
            @current_indexed_file_Name = lib.GetFunction("get_CurrentIndexedFileName");
            @get_indexed_files = lib.GetFunction("get_IndexedFiles");
        }
    }

    void StartIndexingFiles(const string& inPath) {
        if (start_indexing_files !is null) {
            start_indexing_files.Call(inPath);
        }
    }

    int get_TotalFileCountInDirectory() {
        if (get_total_file_count_in_directory !is null) {
            return get_total_file_count_in_directory.CallInt32();
        }
        return 0;
    }

    int get_IndexedFileCountInDirectory() {
        if (get_indexed_file_count_in_directory !is null) {
            return get_indexed_file_count_in_directory.CallInt32();
        }
        return 0;
    }

    string get_CurrentIndexedFileName() {
        if (current_indexed_file_Name !is null) {
            return current_indexed_file_Name.CallString();
        }
        return "";
    }

    bool IsIndexingInProgress() {
        if (is_indexing_in_progress !is null) {
            return is_indexing_in_progress.CallInt32() != 0;
        }
        return false;
    }

    Json::Value[] get_IndexedFiles() {
        if (get_indexed_files !is null) {
            string strJson = get_indexed_files.CallString();
            
            Json::Value json = StringToJson(strJson);

            if (json.GetType() == Json::Type::Null) {
                log("Failed to parse JSON.", LogLevel::Error, 87, "GetIndexedFiles");
                return Json::Array();
            }

            Json::Value resultArray = Json::Array();

            if (json.GetType() == Json::Type::Object) {
                resultArray.Add(json);
            } 
            else if (json.GetType() == Json::Type::Array) {
                for (uint i = 0; i < json.Length; i++) {
                    resultArray.Add(json[i]);
                }
            }

            return resultArray;
        }

        return Json::Array();
    }

    private Json::Value StringToJson(const string &in strJson) {
        Json::Value json;
        
        try {
            json = Json::Parse(strJson);
            
            if (json.GetType() == Json::Type::Null) {
                log("Failed to parse JSON: " + strJson, LogLevel::Error, 102, "StringToJson");
            }
        } catch {
            log("Exception occurred while parsing JSON: " + strJson, LogLevel::Error, 107, "StringToJson");
            return Json::Value();
        }

        return json;
    }
}
