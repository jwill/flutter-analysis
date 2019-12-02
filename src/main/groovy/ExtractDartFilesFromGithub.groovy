// https://mvnrepository.com/artifact/net.lingala.zip4j/zip4j

import net.lingala.zip4j.*
import net.lingala.zip4j.model.*
import org.apache.commons.io.*
@Grapes([
        @Grab(group='net.lingala.zip4j', module='zip4j', version='2.2.6'),
        @Grab(group='commons-io', module='commons-io', version='2.6')
])
import org.apache.commons.io.*

void extractDartFiles (String FILE_URL) {
    def FILE_NAME = "../../../temp.zip"
    def CONNECT_TIMEOUT = 3000
    def READ_TIMEOUT = 30 * 1000

    // Download zip
    FileUtils.copyURLToFile(
            new URL(FILE_URL),
            // TODO make this in temp directory
            new File(FILE_NAME),
            CONNECT_TIMEOUT,
            READ_TIMEOUT);

    println "Processing ${FILE_URL}"
    def zipFile = new ZipFile(FILE_NAME)
    List<FileHeader> fileHeaders = zipFile.getFileHeaders();
    // Filter to only Dart files
    fileHeaders.stream().filter{header -> header.getFileName().contains("dart") }.forEach{
        zipFile.extractFile(it.getFileName(), '../../../files-to-process', UUID.randomUUID().toString()+".dart")

    }

}

String formatZipUrl(String first, String second) {
    return "https://github.com/${first}/${second}/archive/master.zip"
}



public static main(String[] args) {
    println(new File(".").canonicalPath)
    def repoList = new File("../../../repoList.csv").eachLine {
        def components = it.split(",")
        extractDartFiles(formatZipUrl(components[0], components[1]))
    }
}