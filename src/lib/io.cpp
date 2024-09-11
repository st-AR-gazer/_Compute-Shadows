#include <iostream>
#include <thread>
#include <atomic>
#include <mutex>
#include <filesystem>
#include <vector>
#include <chrono>

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
std::atomic<int> filesProcessed(0);
int totalFilesToIndex = 0;

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
    filesProcessed = 0;

    totalFilesToIndex = CountFiles(directory);

    for (const auto& entry : fs::recursive_directory_iterator(directory)) {
        if (fs::is_regular_file(entry)) {
            std::string filePath = entry.path().string();
            bool isDirectory = fs::is_directory(entry);
            uintmax_t fileSize = isDirectory ? 0 : fs::file_size(entry.path());
            auto lastModified = fs::last_write_time(entry.path());

            auto lastModifiedTime = std::chrono::system_clock::time_point(std::chrono::duration_cast<std::chrono::system_clock::duration>(
                lastModified.time_since_epoch()
            ));

            auto creationTime = lastModifiedTime;

            std::string fileType = entry.path().extension().string();
            uintmax_t hardLinkCount = fs::hard_link_count(entry);

            bool canRead, canWrite, canExecute;
            GetFilePermissions(entry.path(), canRead, canWrite, canExecute);

            indexedFiles.emplace_back(filePath, fileSize, lastModifiedTime, creationTime, fileType, 
                                      isDirectory, canRead, canWrite, canExecute, hardLinkCount);

            filesProcessed++;
        }
    }

    isIndexing = false;
}

extern "C" __declspec(dllexport) void StartIndexing(const char* directory) {
    std::thread indexThread(IndexFiles, std::string(directory));
    indexThread.detach();
}

extern "C" __declspec(dllexport) bool IsIndexingInProgress() {
    return isIndexing.load();
}

extern "C" __declspec(dllexport) const IndexedFileInfo* GetIndexedFiles(int* fileCount) {
    std::lock_guard<std::mutex> lock(indexMutex);
    *fileCount = static_cast<int>(indexedFiles.size());
    return indexedFiles.data();
}

extern "C" __declspec(dllexport) int GetTotalFilesToIndex() {
    return totalFilesToIndex;
}

extern "C" __declspec(dllexport) int GetFilesProcessed() {
    return filesProcessed.load();
}
