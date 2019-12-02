@Grab('org.jsoup:jsoup:1.12.1')
import  org.jsoup.nodes.*
import org.jsoup.*
def doc = Jsoup.connect("https://flutter.dev/docs/reference/widgets").get();
println(doc.title());
def widgetCards = doc.select(".card");
def list = []
for (widget in widgetCards) {
    def title = widget.select(".card-body .card-title").text()
    list.add(title)
    println(title)
}
println(list.size())

// List from https://api.flutter.dev/flutter/material/material-library.html
def doc2 = Jsoup.connect("https://api.flutter.dev/flutter/material/material-library.html").get()
def o = doc2.select("ol")
println(o)

static void main(String args) {
    println "hi"
}