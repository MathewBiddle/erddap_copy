---
title: 'Loading a dataset'
teaching: 10
exercises: 2
---

:::::::::::::::::::::::::::::::::::::: questions 

- How do you add an xml snippet to datasets.xml?
- How do you load/reload a dataset in ERDDAP™?

::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: objectives

- Explain how to copy an xml snippet into datasets.xml
- Demonstrate how to load/reload a dataset in ERDDAP™.

::::::::::::::::::::::::::::::::::::::::::::::::

## Adding the dataset to ERDDAP and review

Now that you've generated the xml snippet for ERDDAP™, we need to load that in.

Here, you can see an example [datasets.xml](https://github.com/ERDDAP/erddap/blob/main/development/jetty/config/datasets.xml).

## Insert the xml snippet into datasets.xml

One can simply copy and paste the xml snippet from the source into the datasets.xml file. Or, you can write a script to insert the xml into the datasets.xml.

For example, 

* https://github.com/MathewBiddle/sandbox/blob/main/xml_insert.py
* https://github.com/MathewBiddle/sandbox/blob/main/script2insert.py

```bash
python ../python_tools/script2insert.py
```
```output
ingesting ../erddap/content/datasets.xml
ingesting ../xml_by_dataset/bodega-head-intertidal-shore-sta_IOOS.xml
Inserting snippet for datasetID = bodega-head-intertidal-shore-sta_IOOS into ../erddap/content/datasets.xml
```
```bash
python ../python_tools/script2insert.py
```
```output
ingesting ../erddap/content/datasets.xml
ingesting ../xml_by_dataset/bodega-head-intertidal-shore-sta_EDDTableCopy.xml
Inserting snippet for datasetID = bodega-head-intertidal-shore-sta_EDDTableCopy into ../erddap/content/datasets.xml
```

## Flag dataset for reloading

A [Flag File](https://erddap.github.io/docs/server-admin/additional-information#flag) tells ERDDAP™ to try to reload a dataset as soon as possible.

```bash
erddap-gold-standard/xml_by_dataset$ touch ../erddap/data/hardFlag/bodega-head-intertidal-shore-sta_IOOS
erddap-gold-standard/xml_by_dataset$ touch ../erddap/data/hardFlag/bodega-head-intertidal-shore-sta_EDDTableCopy
```

## Review dataset on your ERDDAP™

Letting ERDDAP™ do the copying (`EDDTableCopy`):

* https://erddap.ioos.us/erddap/tabledap/bodega-head-intertidal-shore-sta_EDDTableCopy.html

ERDDAP™ providing a link to the source data (`EDDTableFromErddap`): 

* https://erddap.ioos.us/erddap/tabledap/bodega-head-intertidal-shore-sta_EDDTableFromErddap.html

Manual hard-copy of data (python + `EDDTableFromNcFiles`): 

* https://erddap.ioos.us/erddap/tabledap/bodega-head-intertidal-shore-sta_IOOS.html

::: challenge

Compare those to the source and see what's different.

http://erddap.cencoos.org/erddap/info/bodega-head-intertidal-shore-sta/index.html

:::

## If something breaks?

1. Check the logs at `/erddap/data/logs/log.txt` or the status page (eg. https://erddap.ioos.us/erddap/status.html)

::::::::::::::::::::::::::::::::::::: keypoints 

- The xml snippet built previously can be copied directly into datasets.xml
- ERDDAP™ has a nice `flag` feature to load/reload datasets.

::::::::::::::::::::::::::::::::::::::::::::::::

