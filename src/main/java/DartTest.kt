import org.antlr.v4.runtime.CharStreams
import org.antlr.v4.runtime.CommonTokenStream
import org.antlr.v4.runtime.tree.ParseTreeWalker
import org.mapdb.IndexTreeList
import java.io.File
import krangl.*
import org.antlr.v4.runtime.tree.ParseTreeListener
import org.knowm.xchart.*
import org.mapdb.DBMaker
import java.nio.file.Files
import java.nio.file.Paths
import javax.xml.crypto.Data

import org.knowm.xchart.style.Styler
import org.mapdb.DB
import java.util.*
import kotlin.collections.ArrayList
import kotlin.collections.HashMap


class ClassListener(var list: IndexTreeList<Any?>) : Dart2BaseListener() {
    override fun enterTypeWithParameters(ctx: Dart2Parser.TypeWithParametersContext?) {
        val identifier = ctx?.text
        if (identifier != null) {
            list.add(mapOf<String, String>("id" to identifier))
            println(identifier)
        }
    }
}

class IdentifierListener(val list: IndexTreeList<Any?>) : Dart2BaseListener() {
    var identifier: String? = ""
    var names = mutableMapOf<String, Any?>()
    override fun enterArgumentList(ctx: Dart2Parser.ArgumentListContext?) {

        println("Argument list")
        println(ctx?.text)
        println("-------")
        var namedArgument = ctx?.namedArgument()
        namedArgument?.stream()?.forEach {
            names.put(it.label().identifier().text, 1)
        }

        // There can be an expression or an arg list
        // Expr are usually things like
        // Text("Blah") or Icon(Icons.add)
        var exprList = ctx?.expressionList()
        println("Expression List:" + exprList?.text)
        if (exprList != null)
            names.put("defaultExpression", 1)

        println(names)
        // TODO Check if first letter is _ or lowercase and omit itif (names["idName"])
        list.add(names)
    }

    override fun exitPrimary(ctx: Dart2Parser.PrimaryContext?) {

    }

    override fun enterIdentifierNotFUNCTION(ctx: Dart2Parser.IdentifierNotFUNCTIONContext?) {
        names = mutableMapOf<String, Any?>()
        identifier = ctx?.IDENTIFIER()?.text
        println(ctx?.IDENTIFIER()?.text)
        if (identifier != null) {

            names.put("idName", identifier!!)

        }
    }

    override fun enterTypeIdentifier(ctx: Dart2Parser.TypeIdentifierContext?) {
        names = mutableMapOf<String, Any?>()

        identifier = ctx?.text
        println(identifier)
        names.put("idName", identifier!!)
    }

}

fun parseFile(filename: String, collection: IndexTreeList<Any?>, listenerType: String = "Identifier") {
    val file = File(filename)
    val dart2Lexer = Dart2Lexer(CharStreams.fromPath(file.toPath()))
    val tokens = CommonTokenStream(dart2Lexer)
    val parser = Dart2Parser(tokens)


    val tree = parser.libraryDefinition()

    val walker = ParseTreeWalker()

    var listener: ParseTreeListener
    when (listenerType) {
        // Used to parse the Material files for class names
        "Class" -> listener = ClassListener(collection)
        // Used to parse the identifiers and param lists
        "Identifier" -> listener = IdentifierListener(collection)
        else -> listener = IdentifierListener(collection)
    }
    walker.walk(listener, tree)
}

fun normalizeRows(collection: IndexTreeList<Any?>): DataFrame {
    // Normalize rows
    val keySet = mutableSetOf<String>()
    var dataFrameRowTemplate = hashMapOf<String, Any?>()

    // Find all the possible keys and add them to a keyset
    for (i in 0..collection.size - 1) {
        val row = collection.get(i) as DataFrameRow
        keySet.addAll(row.keys)
    }
    for (key in keySet) {
        dataFrameRowTemplate.set(key, null)
    }

    var newCollection = arrayListOf<DataFrameRow>()
    for (i in 0..collection.size - 1) {
        val row = collection.get(i) as DataFrameRow
        val rowClone = dataFrameRowTemplate.clone() as HashMap<String, Any?>
        for (key in row.keys) {
            rowClone.put(key, row[key])
        }
        println(rowClone)
        newCollection.add(rowClone)
    }
    return dataFrameOf(newCollection)
}

fun getNonNullForDataFrame(dataFrame: DataFrame): DataFrame {
    val nonNullColumns = mutableSetOf<String>()

    for (col in dataFrame.cols) {
        var columnIsUsed = false
        for (row in dataFrame.rows) {

            if (row.get(col.name) != "") {
                columnIsUsed = true
                nonNullColumns.add(col.name)
                continue
            }
        }
    }

    return dataFrame.select(nonNullColumns)
}

fun getSubDataFrame(dataFrame: DataFrame, idName: String): DataFrame =
        dataFrame.filter { it["idName"] eq idName }

fun dataCleaning(frame: DataFrame): DataFrame {
    var df = frame
    // Data cleaning
    // remove rows with a blank idName
    df = df.filter {
        it["idName"].isMatching<String> {
            !equals("")
        }
    }
    // Select only rows that begin with an Uppercase letter
    // and don't begin with underscore
    df = df.filter {
        it["idName"].isMatching<String> {
            val c = this.toCharArray()[0].toChar()
            c.isUpperCase() && c != '_'
        }
    }
    // Exclude the ids containing Exception
    df = df.filter {
        it["idName"].isMatching<String> {
            !this.endsWith("Exception")
        }
    }
    return df
}

fun getMaterialClasses(collection: IndexTreeList<Any?>) {
    val uri = File("flutter-data").toURI()
    val walk = Files.walk(Paths.get(uri), 2)
    val it = walk.iterator()
    while (it.hasNext()) {
        val filename = it.next()
        println(filename)
        if (filename.toFile().isFile)
            parseFile(filename.toString(), collection, "Class")
    }

    var df = dataFrameOf(collection.toList() as ArrayList<DataFrameRow>)
    // Remove under score classes which are generally considered private
    df = df.filter {
        it["id"].isMatching<String> {
            !startsWith("_")
        }
    }
    df.writeCSV(File("material-widgets.csv"))
}

fun processUserFiles(collection: IndexTreeList<Any?>, db:DB): DataFrame {
    // Must be called after the db has been connected
    val fileList = Files.list(File("./files-to-process").toPath()).limit(100)
    var count = 0
    for (path in fileList) {
        println("File ${count++}...")
        println("Processing ${path}...")
        parseFile(path.toAbsolutePath().toString(), collection)
        db.commit()
        Files.move(path, File(File("./files-processed"), path.fileName.toString()).toPath())
    }

    val df = normalizeRows(collection)
    df.writeCSV(File("normalizedRows.csv"))
    return df
}

fun checkForFirstRun() {
    val widgetFile = File("material-widgets.csv")
    val recordFile = File("normalizedRows.csv")
    val filesToProcess = Files.list(File("./files-to-process").toPath()).count()
    // If either file doesn't exist then generate them
    if (!widgetFile.exists() || !recordFile.exists() || filesToProcess > 0) {
        // First run
        val db = DBMaker.fileDB("testMapDB.db").make()
        if (!widgetFile.exists()) {
            val widgetCollection = db.indexTreeList("widgetList").createOrOpen()
            getMaterialClasses(widgetCollection)
        }
        if (!recordFile.exists() || filesToProcess > 0) {
            println("Processing new files...")
            val recordCollection = db.indexTreeList("recordList").createOrOpen()
            processUserFiles(recordCollection, db)
        }

        //persist changes on disk
        db.commit()

        //close to protect from data corruption
        db.close()
    }
}

fun main(args: Array<String>) {
    checkForFirstRun()
    if (!Files.exists(Paths.get("cleaned-data.csv"))) {
        println("Preparing cleaned data from normalizedRows")
        var df = DataFrame.readCSV(File("normalizedRows.csv"))
        //println(df)
        df = df.moveLeft("idName")

        df = dataCleaning(df)

        var df2 = DataFrame.readCSV(File("material-widgets.csv"))
        df2 = df2.filter {
            it["id"].isMatching<String> {
                !startsWith("_")
            }
        }
        // Remove ids that don't appear in the Material Widgets dataframe
        val widgetList = df2.rows.map { it.getValue("id") }.toList()
        var result = df.filter {
            it["idName"].isMatching<String> {
                widgetList.contains(this)
            }
        }
        result.writeCSV(File("cleaned-data.csv"))
    }

    var result = DataFrame.readCSV(File("cleaned-data.csv"))

   // println(getSubDataFrame(df, "Text"))



    //println(df2)


    // Remove properties that were culled with the non-Material stuff
    //result = getNonNullForDataFrame(result)

    //println(df)
    println(result)

    // Count frequency of elements
    val f = result.groupBy("idName").count().sortedByDescending("n").take(10)
    val f2 = result.groupBy("idName").count().sortedByDescending("n").take(20)
    //f.print(maxRows = 100)

    // total in the top 20
    val f3 = f2.summarize(
            "total" to {it["n"].sum()}
    )
    println(f3)

    // Find the percentage touched by the top 20
    val f4 = f3["total"].get(0) as Int / result.rows.count().toDouble()
    println("Percentage:" + f4)

    // Chart of Top 20 Widgets
    makeChart("./pngs/Top20FlutterWidgets", "Top 20 Widget Frequencies in Flutter Apps", "Widget Name",
            "Frequency", f2["idName"].values(), f2["n"].values())
    // Chart of Top 10 Widgets
    makeChart("./pngs/Top10FlutterWidgets", "Top 10 Widget Frequencies in Flutter Apps", "Widget Name",
            "Frequency", f["idName"].values(), f["n"].values())

    // Generate Property charts for all of the top ten
    for(idName in f["idName"].values()) {
        val tempDF = createPropertiesDataFrame(idName.toString(), result)
        makeChart("./pngs/${idName}Frequencies", idName.toString(), "Property Name", "Frequency",
                tempDF["propertyName"].values(), tempDF["count"].values())

    }
    println(result.rows.count())

}

// Returns the frequencies of named parameters on a given widget
fun createPropertiesDataFrame(idName: String, sourceDataFrame: DataFrame) : DataFrame {
    var dataFrame = sourceDataFrame.filter { it["idName"] eq idName }
    // drop the idName column
    dataFrame = dataFrame.selectIf { !it.name.equals("idName") }

    // Compose frequency list
    val rows = mutableListOf<DataFrameRow>()
    for (col in dataFrame.cols) {
        val row = mutableMapOf<String, Any?>()
        row["propertyName"] = col.name
        var count = 0;
        col.values().forEach {
            if ((it as String).equals("1"))
                count++
        }
        row["count"] = count
        if (count > 0)
            rows.add(row)
    }
    return dataFrameOf(rows)
}

fun makeChart(filename: String, title: String, xLabel: String, yLabel: String,
              xValues: Array<*>, yValues: Array<*>, showSwingWrapper: Boolean = false) {
    // Chart the top ten widgets
    val xData = xValues.asList()
    val yData = yValues.asList() as MutableList<Number>

// Create Chart
    val chart = CategoryChartBuilder().title(title).height(1080).width(1920)
            .xAxisTitle(xLabel).yAxisTitle(yLabel).build()

    // Customize Chart
    chart.getStyler().setLegendPosition(Styler.LegendPosition.InsideNW)
    chart.getStyler().setHasAnnotations(true)

    chart.addSeries("widgets", xData, yData as List<Number>)
// Show it
    if (showSwingWrapper)
        SwingWrapper(chart).displayChart()
    BitmapEncoder.saveBitmap(chart, File(filename).canonicalPath, BitmapEncoder.BitmapFormat.PNG);
}