import  org.jsoup.nodes.*
import org.jsoup.*
import java.io.File
import java.util.*

// This is here for historical purposes, I didn't actually use the output from it

fun main() {
    val doc = Jsoup.connect("https://flutter.dev/docs/reference/widgets").get();
    println(doc.title());
    val widgetCards = doc.select(".card");
    val list = arrayListOf<String>()
    for (widget in widgetCards) {
        val title = widget.select(".card-body .card-title").text()
        list.add(title)
        println(title)
    }
    println(""+list.size)
    File("widgetNames.txt").writeText(list.toString())
}