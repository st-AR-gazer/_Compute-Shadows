#include <iostream>
#include <thread>
#include <atomic>
#include <mutex>
#include <filesystem>
#include <vector>
#include <chrono>
#include "json.hpp" // header-only

namespace fs = std::filesystem;

struct IndexedFileInfo {
    std::string filePath;
    uintmax_t fileSize;
    std::chrono::system_clock::time_point lastModified;
    std::chrono::system_clock::time_point creationTime;
    std::string fileType;
    bool isDirectory;
    bool canRead;
    bool canWrite;
    bool canExecute;
    uintmax_t hardLinkCount;

    IndexedFileInfo(const std::string& path, uintmax_t size, std::chrono::system_clock::time_point modTime, 
                    std::chrono::system_clock::time_point createTime, const std::string& type, bool isDir,
                    bool read, bool write, bool execute, uintmax_t hardLinks)
        : filePath(path), fileSize(size), lastModified(modTime), creationTime(createTime), fileType(type), 
          isDirectory(isDir), canRead(read), canWrite(write), canExecute(execute), hardLinkCount(hardLinks) {}
};

std::atomic<bool> isIndexing(false);
std::mutex indexMutex;
std::vector<IndexedFileInfo> indexedFiles;

int CountFiles(const std::string& directory) {
    int count = 0;
    for (const auto& entry : fs::recursive_directory_iterator(directory)) {
        if (fs::is_regular_file(entry)) {
            count++;
        }
    }
    return count;
}

void GetFilePermissions(const fs::path& path, bool& canRead, bool& canWrite, bool& canExecute) {
    fs::perms p = fs::status(path).permissions();
    canRead = (p & fs::perms::owner_read) != fs::perms::none;
    canWrite = (p & fs::perms::owner_write) != fs::perms::none;
    canExecute = (p & fs::perms::owner_exec) != fs::perms::none;
}

void IndexFiles(const std::string& directory) {
    isIndexing = true;
    std::lock_guard<std::mutex> lock(indexMutex);

    indexedFiles.clear();
    for (const auto& entry : fs::recursive_directory_iterator(directory)) {
        if (fs::is_regular_file(entry)) {
            std::string filePath = entry.path().string();
            uintmax_t fileSize = fs::file_size(entry.path());
            auto lastModified = fs::last_write_time(entry.path());

            auto lastModifiedTime = std::chrono::system_clock::time_point(
                std::chrono::duration_cast<std::chrono::system_clock::duration>(lastModified.time_since_epoch())
            );

            auto creationTime = lastModifiedTime;
            std::string fileType = entry.path().extension().string();
            uintmax_t hardLinkCount = fs::hard_link_count(entry);

            bool canRead, canWrite, canExecute;
            GetFilePermissions(entry.path(), canRead, canWrite, canExecute);

            indexedFiles.emplace_back(filePath, fileSize, lastModifiedTime, creationTime, fileType,
                                      false, canRead, canWrite, canExecute, hardLinkCount);
        }
    }

    isIndexing = false;
}

extern "C" __declspec(dllexport) void StartIndexingFiles(const char* directory) {
    std::thread indexThread(IndexFiles, std::string(directory));
    indexThread.detach();
}

extern "C" __declspec(dllexport) bool IsFileIndexingActive() {
    return isIndexing.load();
}

extern "C" __declspec(dllexport) int GetTotalFileCountInDirectory(const char* directory) {
    return CountFiles(std::string(directory));
}

extern "C" __declspec(dllexport) int GetIndexedFileCountInDirectory() {
    std::lock_guard<std::mutex> lock(indexMutex);
    return static_cast<int>(indexedFiles.size());
}

extern "C" __declspec(dllexport) const char* GetCurrentIndexedFileName(int index) {
    static std::string currentFileName;
    std::lock_guard<std::mutex> lock(indexMutex);

    if (index < 0 || index >= indexedFiles.size()) return nullptr;

    currentFileName = indexedFiles[index].filePath;
    return currentFileName.c_str();
}

extern "C" __declspec(dllexport) const char* GetIndexedFileInfoJSON(int index) {
    static std::string jsonString;
    std::lock_guard<std::mutex> lock(indexMutex);

    if (index < 0 || index >= indexedFiles.size()) return nullptr;

    IndexedFileInfo& info = indexedFiles[index];

    nlohmann::json jsonObj = {
        {"filePath", info.filePath},
        {"fileSize", info.fileSize},
        {"lastModified", std::chrono::duration_cast<std::chrono::seconds>(
                             info.lastModified.time_since_epoch()).count()},
        {"creationTime", std::chrono::duration_cast<std::chrono::seconds>(
                            info.creationTime.time_since_epoch()).count()},
        {"fileType", info.fileType},
        {"isDirectory", info.isDirectory},
        {"canRead", info.canRead},
        {"canWrite", info.canWrite},
        {"canExecute", info.canExecute},
        {"hardLinkCount", info.hardLinkCount}
    };

    jsonString = jsonObj.dump(); 
    return jsonString.c_str();
}
