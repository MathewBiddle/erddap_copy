---
title: 'Introduction'
teaching: 10
exercises: 2
---

:::::::::::::::::::::::::::::::::::::: questions 

- How do you create xml snippets for ERDDAP™?

::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: objectives

- Explain how to create xml snippets for ERDDAP™ to copy data.
- Demonstrate how to generate various xml snippets.

::::::::::::::::::::::::::::::::::::::::::::::::

## Build datasets.xml

Now that you have [installed all the necessary software](index.html), you are ready to load a dataset into ERDDAP™. 

Setting up a dataset in ERDDAP™ isn't just a matter of pointing to the dataset's directory or URL. You have to write a chunk of XML for datasets.xml which describes the dataset.

This page will walk through the various ways to build an xml snippet for datasets.xml to copy or link to data from another location.

For more information on datasets.xml, see the official [ERDDAP™ documentation](https://erddap.github.io/docs/server-admin/datasets).

You can see an example datasets.xml [here](https://github.com/ERDDAP/erddap/blob/main/development/jetty/config/datasets.xml).

## Using ERDDAP™ to link to an existing ERDDAP™ dataset

::: callout
## Caveats

* This only provides a link to the dataset on the source ERDDAP™. It does not copy the data to the local system. If the source ERDDAP™ goes down or the dataset is unavailable, the local ERDDAP™ will respond with an unavailable dataset as well.
* This is a good initial test for building the `EDDTableCopy`. If you successfully get this to work, you can insert it within the `EDDTableCopy` to copy the data locally.
:::

Build an xml snippet following the guidelines for using [`EDDTableFromErddap`](https://erddap.github.io/docs/server-admin/datasets#eddfromerddap).

:::: spoiler
### Below is the example xml snippet: 

```xml
<dataset type="EDDTableFromErddap" datasetID="bodega-head-intertidal-shore-sta_EDDTableFromErddap" active="true">
  <sourceUrl>http://erddap.cencoos.org/erddap/tabledap/bodega-head-intertidal-shore-sta</sourceUrl>
</dataset>
```

[source file](https://github.com/MathewBiddle/erddap_copy/blob/c99ea4e0a0b758760f3ffeb044df0e63b9364a5b/xml_by_dataset/bodega-head-intertidal-shore-sta_EDDTableFromErddap.xml#L1-L3)
::::

## Using ERDDAP™ to copy an ERDDAP™ dataset

::: prereq
## Preferred

This is a preferred option as it keeps the data synchronized with the source file. It also keeps a local copy of the data in case the source has changed.
:::

A Jupyter Notebook walking through the process documented below can be found in this repository at [create_EDDTableCopy_snippets.ipynb](https://github.com/MathewBiddle/erddap_copy/blob/main/create_EDDTableCopy_snippets.ipynb).


::: callout
## Caveats

* Takes some time to load the first time around because we are copying data around.
* This becomes an identical copy of the source data, updated at a frequency identified in `<reloadEveryNMinutes>` and `<onChange>`
:::


1. Build an xml snippet following the guidelines for using [`EDDTableCopy`](https://erddap.github.io/docs/server-admin/datasets#eddtablecopy) and [`EDDTableFromErddap`](https://erddap.github.io/docs/server-admin/datasets#eddfromErddap).
   1. This is nesting the `EDDTableFromErddap` inside of the `EDDTableCopy` to look for the data and copy over to create a new dataset on your local ERDDAP™. 
   1. The dataset will be copied to `erddap/data/copy/[datasetID]/[station]/[latitude]/[longitude]` (eg. `erddap/data/copy/bodega-head-intertidal-shore-sta_EDDTableCopy/x-0/38.3187/-123.0742.nc`).
   1. `EDDTableCopy` knows to look at that location for the data and load it in automatically. 

::: caution
Keep an eye on how you set the `<extractDestinationNames>`. If you set it to something extremely granular (eg. time), it will create a local file for each unique instance of that value. Essentially what ERDDAP™ does is creates a file composed of all the rows that match the unique instance of that value. So, if you have a dataset from 2008 to 2015 collecting data every 10 mins, the system will copy that data over into files that have one unique `time` (ie. a bazillion files). Here, I know that the dataset is representative of a single station, so I set `<extractDestinationNames>station latitude longitude</extractDestinationNames>`, essentially creating one file on my local system.
:::

:::: spoiler
### Below is an example xml snippet:

```xml
<dataset type="EDDTableCopy" datasetID="bodega-head-intertidal-shore-sta_EDDTableCopy" active="true">
  <reloadEveryNMinutes>10080</reloadEveryNMinutes>
  <extractDestinationNames>station latitude longitude</extractDestinationNames>
  <checkSourceData>true</checkSourceData>
  <dataset type="EDDTableFromErddap" datasetID="bodega-head-intertidal-shore-sta1" active="true">
    <!-- Bodega Head Intertidal Shore Station -->
    <sourceUrl>http://erddap.cencoos.org/erddap/tabledap/bodega-head-intertidal-shore-sta</sourceUrl>
  </dataset>
</dataset>
```

[source file](https://github.com/MathewBiddle/erddap_copy/blob/c99ea4e0a0b758760f3ffeb044df0e63b9364a5b/xml_by_dataset/bodega-head-intertidal-shore-sta_EDDTableCopy.xml#L1-L9)
::::

## Using ERDDAP™ to copy a remote file

If source data are not hosted on an ERDDAP™ already, one could use [`<cacheFromUrl>`](https://erddap.github.io/docs/server-admin/datasets?_highlight=cachefromurl#cachefromurl) feature to have ERDDAP™:

1. Go to `<cacheFromUrl>` web address.
1. Look for files mathcing `<fileNameRegex>`.
1. Download the matching file to the directory specified in `<fileDir>`
1. Loads the downloaded file using the appropriate ERDDAP™ class.
1. Makes the data and metadata accessible on ERDDAP™.

:::: spoiler
### Below is an example xml snippet:

```xml
<dataset type="EDDTableFromColumnarAsciiFiles" datasetID="FC_cable_transport_2022" active="true">
    <reloadEveryNMinutes>10080</reloadEveryNMinutes>
    <updateEveryNMillis>10000</updateEveryNMillis>
    <cacheFromUrl>https://www.ncei.noaa.gov/data/oceans/archive/arc0211/0276841/1.1/data/0-data/</cacheFromUrl>
    <fileDir>/datasets/NCEI_data/test/</fileDir>
    <fileNameRegex>.*\.txt</fileNameRegex>    
    <recursive>true</recursive>
    <pathRegex>.*</pathRegex>
    <metadataFrom>last</metadataFrom>
    <charset>ISO-8859-1</charset>
    <columnNamesRow>21</columnNamesRow>
    <firstDataRow>23</firstDataRow>
    <standardizeWhat>0</standardizeWhat>
    <sortFilesBySourceNames></sortFilesBySourceNames>
    <fileTableInMemory>false</fileTableInMemory>
    <addAttributes>
        <att name="cdm_data_type">Other</att>
        <att name="Conventions">COARDS, CF-1.10, ACDD-1.3</att>
        <att name="infoUrl">https://www.ncei.noaa.gov/access/metadata/landing-page/bin/iso?id=gov.noaa.nodc:0276841</att>
        <att name="institution">NCEI</att>
        <att name="keywords">Year, data, day, flag, local, month, percent, source, transport, year</att>
        <att name="license">[standard]</att>
        <att name="sourceUrl">https://www.ncei.noaa.gov/data/oceans/archive/arc0211/0276841/1.1/data/0-data/FC_cable_transport_2022.dat.txt</att>
        <att name="standard_name_vocabulary">CF Standard Name Table v70</att>
        <att name="subsetVariables">Year, Flag</att>
        <att name="summary">TEST: Transport estimate of the Florida Current using voltage data of the submarine cable from West Palm Beach, FL to Eight Mile Rock, Grand Bahama Island</att>
        <att name="title">TEST: Transport estimate of the Florida Current using voltage data of the submarine cable from West Palm Beach, FL to Eight Mile Rock, Grand Bahama Island</att>
    </addAttributes>
    <dataVariable>
        <sourceName>%  Year</sourceName>
        <destinationName>Year</destinationName>
        <dataType>short</dataType>
        <addAttributes>
            <att name="_FillValue" type="short">32767</att>
            <att name="long_name">&#37;  Year</att>
            <att name="startColumn" type="int">0</att>
            <att name="stopColumn" type="int">9</att>
        </addAttributes>
    </dataVariable>
    <dataVariable>
        <sourceName>Month</sourceName>
        <destinationName>Month</destinationName>
        <dataType>byte</dataType>
        <addAttributes>
            <att name="_FillValue" type="byte">127</att>
            <att name="long_name">Month</att>
            <att name="startColumn" type="int">9</att>
            <att name="stopColumn" type="int">16</att>
        </addAttributes>
    </dataVariable>
    <dataVariable>
        <sourceName>Day</sourceName>
        <destinationName>Day</destinationName>
        <dataType>byte</dataType>
        <addAttributes>
            <att name="_FillValue" type="byte">127</att>
            <att name="long_name">Day</att>
            <att name="startColumn" type="int">16</att>
            <att name="stopColumn" type="int">22</att>
        </addAttributes>
    </dataVariable>
    <dataVariable>
        <sourceName>Transport</sourceName>
        <destinationName>Transport</destinationName>
        <dataType>float</dataType>
        <addAttributes>
            <att name="long_name">Transport</att>
            <att name="startColumn" type="int">22</att>
            <att name="stopColumn" type="int">34</att>
            <att name="units">Sv</att>
        </addAttributes>
    </dataVariable>
    <dataVariable>
        <sourceName>Flag</sourceName>
        <destinationName>Flag</destinationName>
        <dataType>byte</dataType>
        <addAttributes>
            <att name="_FillValue" type="byte">127</att>
            <att name="colorBarMaximum" type="double">150.0</att>
            <att name="colorBarMinimum" type="double">0.0</att>
            <att name="long_name">Flag</att>
            <att name="startColumn" type="int">34</att>
            <att name="stopColumn" type="int">39</att>
            <att name="flag_values">0, 1, 2</att>
            <att name="flag_meanings">good_data estimated_without_error no_data</att>
        </addAttributes>
    </dataVariable>
</dataset>
```

[source file](https://github.com/MathewBiddle/erddap_copy/blob/cd1e290369c42e5a54492afc6ff0640ba243eac6/xml_by_dataset/FC_cable_transport_2022.xml#L1-L88)
::::

## Manual hard-copy of data
This uses python to search for relevant datasets and download them as netCDF files to your local system. Then, builds the dataset.xml snippet for the dataset.

A python script walking through the process documented below can be found in this repository at [copy_erddap_data.py](https://github.com/MathewBiddle/erddap_copy/blob/main/copy_erddap_data.py).

::: callout
## Caveats

* Metadata must be manually curated in the xml snippet.
* You take more ownership of the data.
:::

Create a directory to copy data to.
```bash
cd erddap-gold-standard/datasets/
mkdir erddap_copy/
cd erddap_copy/
```

Copy appropriate data in that directory.

1. See [`copy_erddap_data.py`](https://github.com/MathewBiddle/erddap_copy/blob/main/copy_erddap_data.py)
   1. Here we download the netCDF version of the dataset because it contains all of the appropriate metadata along with the data. It is the most robust version of the dataset to download.
      
Run `GenerateDatasetsXml.sh` (You can script it! See this [script](https://github.com/MathewBiddle/erddap_copy/blob/main/GenerateDatasetsXml_script.sh)). 
```bash
./GenerateDatasetsXml_script.sh
```
Point `GenerateDatasetsXml.sh` to the netCDF file you just downloaded.

1. This saves a draft xml file to **logs/GenerateDatasetXml.out**.
   
Copy the xml snippet somewhere you can edit it:
```bash
cp logs/GenerateDatasetsXml.out xml_by_dataset/bodega-head-intertidal-shore-sta.xml
```

Edit the xml to reflect any changes. You can adopt all of ERDDAP™ recommendations by uncommenting out the xml comments.
```bash
sed 's/<!-- /</g' bodega-head-intertidal-shore-sta.xml | sed 's/ -->/>/g' > bodega-head-intertidal-shore-sta_IOOS.xml
```

Review the metadata and xml formatting to ensure it is correct.

Set `datasetID` to something reasonable. (e.g. "bodega-head-intertidal-shore-sta_IOOS")

:::::: spoiler
### Below is an example xml snippet: 

[source file](https://github.com/MathewBiddle/erddap_copy/blob/c99ea4e0a0b758760f3ffeb044df0e63b9364a5b/xml_by_dataset/bodega-head-intertidal-shore-sta_IOOS.xml#L1-L388)
::::::

::::::::::::::::::::::::::::::::::::: keypoints 

- ERDDAP™ has a variety of ways to copy or link to data.
- To keep data in sync with the source, the preferred method is to use EDDTableCopy.

::::::::::::::::::::::::::::::::::::::::::::::::

