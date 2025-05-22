# erddap_copy
A demonstration of how to copy datasets from an ERDDAP server to another ERDDAP server.

## A word of caution
* Always check with the ERDDAP administrator for the dataset you are attempting to copy.
* Ensure you preserve associated metadata and contacts for citability.
* Use this with extreme _caution_. Data duplication is no joke.

## Step-by-step

### Stand up ERDDAP
1. Identify service to replicate.
   1. ERDDAP ✅
1. Find dataset to replicate.
   1. <https://erddap.nanoos.org/erddap/info/index.html>
   1. <https://erddap.cencoos.org/erddap/index.html>
      1. picking the dataset to start <http://erddap.cencoos.org/erddap/info/bodega-head-intertidal-shore-sta/index.html>
1. Identify where to host replicate service
   1. AWS EC2
1. Establish service/machine
   1. What are the requirements?
      1. Linux
      2. sudo privileges. 
      3. To make the ERDDAP public (TBD need to flush this out)
         1. Domain Name Service
   3. Here is the system currently have deployed:
      ```
      Architecture:        x86_64
      CPU op-mode(s):      32-bit, 64-bit
      Byte Order:          Little Endian
      CPU(s):              2
      On-line CPU(s) list: 0,1
      Thread(s) per core:  2
      Core(s) per socket:  1
      Socket(s):           1
      NUMA node(s):        1
      Vendor ID:           GenuineIntel
      CPU family:          6
      Model:               85
      Model name:          Intel(R) Xeon(R) Platinum 8175M CPU @ 2.50GHz
      Stepping:            4
      CPU MHz:             2499.994
      BogoMIPS:            4999.98
      Hypervisor vendor:   KVM
      Virtualization type: full
      L1d cache:           32K
      L1i cache:           32K
      L2 cache:            1024K
      L3 cache:            33792K
      NUMA node0 CPU(s):   0,1
      Flags:               fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ss ht syscall nx pdpe1gb rdtscp lm constant_tsc rep_good nopl xtopology nonstop_tsc cpuid tsc_known_freq pni pclmulqdq ssse3 fma cx16 pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand hypervisor lahf_lm abm 3dnowprefetch invpcid_single pti fsgsbase tsc_adjust bmi1 avx2 smep bmi2 erms invpcid mpx avx512f avx512dq rdseed adx smap clflushopt clwb avx512cd avx512bw avx512vl xsaveopt xsavec xgetbv1 xsaves ida arat pku ospke
      $ sudo dmidecode -t bios
      # dmidecode 3.2
      Getting SMBIOS data from sysfs.
      SMBIOS 2.7 present.
      
      
      Handle 0x0000, DMI type 0, 24 bytes
      BIOS Information
              Vendor: Amazon EC2
              Version: 1.0
              Release Date: 10/16/2017
              Address: 0xF0000
              Runtime Size: 64 kB
              ROM Size: 64 kB
              Characteristics:
                      PCI is supported
                      EDD is supported
                      ACPI is supported
                      System is a virtual machine
              BIOS Revision: 1.0
        ```
        
1. Install Git 
   1. https://git-scm.com/
1. Install Docker 
   1. https://www.docker.com/
1. Install Docker compose
   1. https://docs.docker.com/compose/install/ 
1. _Optional_ - install miniforge
   1. https://github.com/conda-forge/miniforge?tab=readme-ov-file#install 
1. Clone [erddap-gold-standard](https://github.com/ioos/erddap-gold-standard) repo
   1. ```git clone https://github.com/ioos/erddap-gold-standard.git```
   2. Edit `docker_compose.yml` to reflect the DNS and any port forwarding to make your ERDDAP public.
      
### Build datasets.xml

Here you have a few options for how to build the datasets.xml file. 

#### Using ERDDAP to link to an existing ERDDAP dataset

Caveats:
* This only provides a link to the dataset on the source ERDDAP. It does not copy the data to the local system. If the source ERDDAP goes down or the dataset is unavailable, the local ERDDAP will respond with an unavailable dataset as well.
* This is a good initial test for building the `EDDTableCopy`. If you successfully get this to work, you can insert it within the `EDDTableCopy` to copy the data locally.

1. Build an xml snippet following the guidelines for using [`EDDTableFromErddap`](https://erddap.github.io/docs/server-admin/datasets#eddfromerddap).

Below is the example xml snippet: 

https://github.com/MathewBiddle/erddap_copy/blob/c99ea4e0a0b758760f3ffeb044df0e63b9364a5b/xml_by_dataset/bodega-head-intertidal-shore-sta_EDDTableFromErddap.xml#L1-L3


#### Using ERDDAP to copy dataset

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

Below is the example xml snippet:

https://github.com/MathewBiddle/erddap_copy/blob/c99ea4e0a0b758760f3ffeb044df0e63b9364a5b/xml_by_dataset/bodega-head-intertidal-shore-sta_EDDTableCopy.xml#L1-L9

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

### Adding the dataset to ERDDAP and review

1. Insert the xml snippet into datasets.xml
   1. See https://github.com/MathewBiddle/sandbox/blob/main/xml_insert.py and https://github.com/MathewBiddle/sandbox/blob/main/script2insert.py
   1. ```
      $ python ../python_tools/script2insert.py
      ingesting ../erddap/content/datasets.xml
      ingesting ../xml_by_dataset/bodega-head-intertidal-shore-sta_IOOS.xml
      Inserting snippet for datasetID = bodega-head-intertidal-shore-sta_IOOS into ../erddap/content/datasets.xml
      $
      $ python ../python_tools/script2insert.py
      ingesting ../erddap/content/datasets.xml
      ingesting ../xml_by_dataset/bodega-head-intertidal-shore-sta_EDDTableCopy.xml
      Inserting snippet for datasetID = bodega-head-intertidal-shore-sta_EDDTableCopy into ../erddap/content/datasets.xml
     ```
1. Flag dataset for reloading
   1. ```
      erddap-gold-standard/xml_by_dataset$ touch ../erddap/data/hardFlag/bodega-head-intertidal-shore-sta_IOOS
      erddap-gold-standard/xml_by_dataset$ touch ../erddap/data/hardFlag/bodega-head-intertidal-shore-sta_EDDTableCopy
      ```
1. Review dataset on your ERDDAP!
   1. Letting ERDDAP do the copying: https://erddap.ioos.us/erddap/tabledap/bodega-head-intertidal-shore-sta_EDDTableCopy.html
   1. ERDDAP providing a link to the source data (not actually hosting data on source ERDDAP): https://erddap.ioos.us/erddap/tabledap/bodega-head-intertidal-shore-sta_EDDTableFromErddap.html
   1. Manual hard-copy of data: https://erddap.ioos.us/erddap/tabledap/bodega-head-intertidal-shore-sta_IOOS.html
   1. Compare those to the source and see what's different. http://erddap.cencoos.org/erddap/info/bodega-head-intertidal-shore-sta/index.html
1. If something breaks?
   1. Check the logs at `/erddap/data/logs/log.txt` or the status page (eg. https://erddap.ioos.us/erddap/status.html)
