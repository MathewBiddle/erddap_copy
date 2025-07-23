---
title: 'introduction'
teaching: 10
exercises: 2
---

:::::::::::::::::::::::::::::::::::::: questions 

- How do you create xml snippets for ERDDAP?

::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: objectives

- Explain how to create xml snippets for ERDDAP
- Demonstrate how to include pieces of code, figures, and nested challenge blocks

::::::::::::::::::::::::::::::::::::::::::::::::

## Introduction

Now that you have [installed all the necessary software](index.html), you are ready to load a dataset into ERDDAP.

This page will walk through the various ways to build an xml snippet for datasets.xml

### Build datasets.xml

Here you have a few options for how to build the datasets.xml file. 

#### Using ERDDAP to copy an ERDDAP dataset

_Preferred option_

A Jupyter Notebook walking through the process documented below can be found in this repository at [create_EDDTableCopy_snippets.ipynb](https://github.com/MathewBiddle/erddap_copy/blob/main/create_EDDTableCopy_snippets.ipynb).

Caveats:
* Takes some time to load the first time around.
* This becomes an identical copy of the source data.

1. Build an xml snippet following the guidelines for using [`EDDTableCopy`](https://erddap.github.io/docs/server-admin/datasets#eddtablecopy) and [`EDDTableFromErddap`](https://erddap.github.io/docs/server-admin/datasets#eddfromerddap).
   1. What you will do is nest the `EDDTableFromErddap` inside of the `EDDTableCopy` to look for the data and copy over to create a new dataset on your local ERDDAP. 
   1. Keep an eye on how you set the `<extractDestinationNames>`. If you set it to something extremely granular (eg. time), it will create a local file for each unique instance of that value. Essentially what ERDDAP does is creates a file composed of all the rows that match the unique instance of that value. So, if you have a dataset from 2008 to 2015 collecting data every 10 mins, the system will copy that data over into files that have one unique `time` (ie. a bazillion files). Here, I know that the dataset is representative of a single station, so I set `<extractDestinationNames>station latitude longitude</extractDestinationNames>`, essentially creating one file on my local system.
   1. The dataset will be copied to `erddap/data/copy/[datasetID]/[station]/[latitude]/[longitude]` (eg. `erddap/data/copy/bodega-head-intertidal-shore-sta_EDDTableCopy/x-0/38.3187/-123.0742.nc`).
   1. `EDDTableCopy` knows to look at that location for the data and load it in automatically. 

Below is an example xml snippet:

https://github.com/MathewBiddle/erddap_copy/blob/c99ea4e0a0b758760f3ffeb044df0e63b9364a5b/xml_by_dataset/bodega-head-intertidal-shore-sta_EDDTableCopy.xml#L1-L9

#### Using ERDDAP to copy a remote file

If source data are not hosted on an ERDDAP already, one could use [`<cacheFromUrl>`](https://erddap.github.io/docs/server-admin/datasets?_highlight=cachefromurl#cachefromurl) feature to have ERDDAP:

1. Go to `<cacheFromUrl>` web address.
1. Look for files mathcing `<fileNameRegex>`.
1. Download the matching file to the directory specified in `<fileDir>`
1. Loads the downloaded file using the appropriate ERDDAP class.
1. Makes the data and metadata accessible on ERDDAP.

Below is an example xml snippet:

https://github.com/MathewBiddle/erddap_copy/blob/cd1e290369c42e5a54492afc6ff0640ba243eac6/xml_by_dataset/FC_cable_transport_2022.xml#L1-L88

#### Using ERDDAP to link to an existing ERDDAP dataset

Caveats:
* This only provides a link to the dataset on the source ERDDAP. It does not copy the data to the local system. If the source ERDDAP goes down or the dataset is unavailable, the local ERDDAP will respond with an unavailable dataset as well.
* This is a good initial test for building the `EDDTableCopy`. If you successfully get this to work, you can insert it within the `EDDTableCopy` to copy the data locally.

1. Build an xml snippet following the guidelines for using [`EDDTableFromErddap`](https://erddap.github.io/docs/server-admin/datasets#eddfromerddap).

Below is the example xml snippet: 

https://github.com/MathewBiddle/erddap_copy/blob/c99ea4e0a0b758760f3ffeb044df0e63b9364a5b/xml_by_dataset/bodega-head-intertidal-shore-sta_EDDTableFromErddap.xml#L1-L3

#### Manual hard-copy of data
This uses python to search for relevant datasets and download them as netCDF files to your local system. Then, builds the dataset.xml snippet for the dataset.

A python script walking through the process documented below can be found in this repository at [copy_erddap_data.py](https://github.com/MathewBiddle/erddap_copy/blob/main/copy_erddap_data.py).

Caveats:
* Metadata must be manually curated in the xml snippet.
* You take a little more ownership of the data.

1. Create a directory to copy data to.
   1. ```
      cd erddap-gold-standard/datasets/
      mkdir erddap_copy/
      cd erddap_copy/
      ```
1. Copy appropriate data in that directory.
   1. see [`copy_erddap_data.py`](https://github.com/MathewBiddle/erddap_copy/blob/main/copy_erddap_data.py)
      1. Here we download the netCDF version of the dataset because it contains all of the appropriate metadata along with the data. It is the most robust version of the dataset to download.
1. Run GenerateDatasetsXml.sh (You can script it! See this [script](https://github.com/MathewBiddle/erddap_copy/blob/main/GenerateDatasetsXml_script.sh). 
   1. ```
      ./GenerateDatasetsXml_script.sh
      ```
      1. Point GenerateDatasetsXml.sh to the netCDF file you just downloaded.
   1. This saves a draft xml file to **logs/GenerateDatasetXml.out**.   
1. Copy the xml snippet somewhere you can edit it
   1. ```cp logs/GenerateDatasetsXml.out xml_by_dataset/bodega-head-intertidal-shore-sta.xml```
1. Edit the xml to reflect any changes. You can adopt all of ERDDAPs recommendations by uncommenting out the xml comments.
   1. ```sed 's/<!-- /</g' bodega-head-intertidal-shore-sta.xml | sed 's/ -->/>/g' > bodega-head-intertidal-shore-sta_IOOS.xml```
   2. Review the metadata and xml formatting to ensure it is correct.
   1. Set `datasetID` to something reasonable. (e.g. "bodega-head-intertidal-shore-sta_IOOS")

Below is the example xml snippet: 

https://github.com/MathewBiddle/erddap_copy/blob/c99ea4e0a0b758760f3ffeb044df0e63b9364a5b/xml_by_dataset/bodega-head-intertidal-shore-sta_IOOS.xml#L1-L388

::::::::::::::::::::::::::::::::::::: keypoints 

- Use `.md` files for episodes when you want static content
- Use `.Rmd` files for episodes when you need to generate output
- Run `sandpaper::check_lesson()` to identify any issues with your lesson
- Run `sandpaper::build_lesson()` to preview your lesson locally

::::::::::::::::::::::::::::::::::::::::::::::::

