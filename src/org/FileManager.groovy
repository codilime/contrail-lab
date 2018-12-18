#!groovy

package org

import groovy.transform.SourceURI
import java.nio.file.Files
import java.nio.file.Path
import java.nio.file.Paths
import java.nio.file.FileSystem
import java.nio.file.FileSystems
import java.nio.file.FileAlreadyExistsException
import java.nio.file.StandardCopyOption


class FileManager {
    private String workspacePath

    FileManager(String workspacePath) {
        this.workspacePath = workspacePath
    }

    public void Copy(String from, String to) {
        Path source = Paths.get(EnsureNonRelativePath(from))
        Path target = Paths.get(EnsureNonRelativePath(to))
        Files.copy(source, target)
    }

    public void Move(String from, String to) {
        Path source = Paths.get(EnsureNonRelativePath(from))
        Path target = Paths.get(EnsureNonRelativePath(to))
        Files.move(source, target)
    }

    public void NewDir(String path) {
        try {
            Files.createDirectory(Paths.get(EnsureNonRelativePath(path)));
        } catch(FileAlreadyExistsException e){
            // The directory exists. Skip this part
        }
    }

    public void NewFile(String path) {
        try {
            Files.createFile(Paths.get(EnsureNonRelativePath(path)));
        } catch(FileAlreadyExistsException e){
            // The file exists. Skip this part
        }
    }

    public void NewDir(String name, String path) {
        this.NewDir(path + "/" + name)
    }

    public void NewFile(String name, String path) {
        this.NewFile(path + "/" + name)
    }

    public void Del(String path) {
        Path rootPath = Paths.get(EnsureNonRelativePath(path))
        Files.walk(rootPath).sorted(Comparator.reverseOrder()).forEach(Files.&delete)
    }

    public boolean Exists(String path) {
        Path rootPath = Paths.get(EnsureNonRelativePath(path))
        return Files.exists(rootPath)
    }

    public String GetFileName(String path) {
        return Paths.get(path).getFileName().toString()
    }

    public String GetFileLocation(String path) {
        return Paths.get(path).getParent().toString()
    }

    public String GetWorkspace() {
        return workspacePath
    }

    private String EnsureNonRelativePath(String path) {
        if (path[0] != '/') {
            return this.workspacePath + "/" + path
        }
        return path
    }
}