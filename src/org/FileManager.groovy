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

    public void copy(String from, String to) {
        Path source = Paths.get(ensureNonRelativePath(from))
        Path target = Paths.get(ensureNonRelativePath(to))
        Files.copy(source, target)
    }

    public void copy(String name, String from, String to) {
        this.copy(from + "/" + name, to + "/" + name)
    }

    public void copy(String oldName, String newName, String from, String to) {
        this.copy(from + "/" + oldName, to + "/" + newName)
    }

    public void move(String from, String to) {
        Path source = Paths.get(ensureNonRelativePath(from))
        Path target = Paths.get(ensureNonRelativePath(to))
        Files.move(source, target)
    }

    public void move(String name, String from, String to) {
        this.move(from + "/" + name, to + "/" + name)
    }

    public void move(String oldName, String newName, String from, String to) {
        this.move(from + "/" + oldName, to + "/" + newName)
    }

    public void newDir(String path) {
        try {
            Files.createDirectory(Paths.get(ensureNonRelativePath(path)));
        } catch(FileAlreadyExistsException e){
            // The directory exist. Skip this part
        }
    }

    public void newDir(String name, String path) {
        this.newDir(path + "/" + name)
    }

    public void del(String path) {
        Path rootPath = Paths.get(ensureNonRelativePath(path))
        Files.walk(rootPath).sorted(Comparator.reverseOrder()).forEach(Files.&delete)
    }

    public void del(String name, String path) {
        this.del(path + "/" + name)
    }

    public boolean exists(String path) {
        Path rootPath = Paths.get(ensureNonRelativePath(path))
        return Files.exists(rootPath)
    }

    private String ensureNonRelativePath(String path) {
        if (path[0] != '/') {
            return this.workspacePath + "/" + path
        }
        return path
    }
}