# flutter-analysis

This is the code accompanying the article 
["Which Flutter widgets you should learn first…according to SCIENCE."](https://medium.com/@ecspike/which-flutter-widgets-you-should-learn-first-according-to-science-a92079358866)

To run the code, you will need **Java** installed.

## Quick Start
Out of the box, you have the dataset of the 18 Github projects and 4 Google DevRel Flutter samples already 
parsed and cleaned.

```gradlew run``` will run the code in DartTest.kt using the provided dataset.

It reads in the cleaned CSV files and gives you space to play with the data. krangl deeply models dplyr from R so 
if you are comfortable with DataFrames, you should feel at home.

krangl has a [10 minute start guide here](https://krangl.gitbook.io/docs/getting-started/10_minutes).

The default is to always read from CSV files for portability and query speed. In addition to the CSVs, all the data is stored in its most raw 
form as a MapDB database. MapDB collections can be used like normal Java Collections but back their data to disk.

## The Data
The projects were a sample from those listed on [https://github.com/tortuvshin/open-source-flutter-apps](https://github.com/tortuvshin/open-source-flutter-apps).

The exact projects are listed in this file in the form of username, projectID: https://github.com/jwill/flutter-analysis/blob/master/repoList.csv

There are also a few of the Flutter team's samples, those are [here](https://github.com/jwill/flutter-analysis/tree/master/files-to-process).

## Example Queries

```getSubDataFrame(dataFrame, idName)``` returns a DataFrame consisting of rows with that Widget id. 
That's just another way to write the native krangl: 

```dataFrame.filter { it["idName"] eq idName }```
<hr>

```result.groupBy("idName").count().sortedByDescending("n").take(10)```
Groups the dataframe by the widget name, tabulates a count and sort by descending count.

More examples on the [krangl Github](https://github.com/holgerbrandl/krangl/blob/master/README.md)

## Adding More Projects

You can add new files in a couple ways.

1. Drop the dart files in the `files-to-process` directory.

**OR**

2. Add a new row to the repoList.csv file in the form of ```githubID,projectID```.
3. Run ```gradlew downloadAndExtractProject``` to extract and anonymize the dart files.

After either option you must run

4. Delete ```cleaned-data.csv```. 

On the next run it will add your new files to the database and generate a (somewhat) cleaned CSV of them.

## Starting Fresh

You can start with a totally clean DB by:
 1. Deleting ```normalizedRows.csv```, ```cleaned-data.csv``` and ```mapDB.dp```
 2. Dropping your files into ```files-to-process```.
 3. Running ```gradlew run```
