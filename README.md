# erddap_copy
A demonstration of how to copy datasets from an ERDDAP server to another ERDDAP server.

## Step-by-step
1. Identify service to replicate.
   1. ERDDAP ✅
1. Find dataset to replicate.
   1. <https://erddap.nanoos.org/erddap/info/index.html>
   1. <https://erddap.cencoos.org/erddap/index.html>  <-- picking the dataset <http://erddap.cencoos.org/erddap/info/bodega-head-intertidal-shore-sta/index.html>
1. Identify where to host replicate service
   1. AWS S3?
1. Establish service/machine
   1. What are the requirements?
   2. Here is the system currently have deployed:
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
        
1. Install Git on the instance 
   1. https://git-scm.com/
1. Install Docker on the instance
   1. https://www.docker.com/
1. Install Docker compose
   1. https://docs.docker.com/compose/install/ 
1. Optional - install miniforge
   1. https://github.com/conda-forge/miniforge?tab=readme-ov-file#install 
1. Clone erddap-gold-standard repo
   1. ```git clone https://github.com/ioos/erddap-gold-standard.git```
1. Create a directory on service to copy data to.
   1. ```
      cd erddap-gold-standard/datasets/
      mkdir repo_copy/
      cd repo_copy/
      ```
1. Copy appropriate data in that directory.
   1. see [`copy_erddap_data.py`](https://github.com/MathewBiddle/erddap_copy/blob/main/copy_erddap_data.py)
      1. Here we download the netCDF version of the dataset because it contains all of the appropriate metadata along with the data. It is the most robust version of the dataset to download.
1. Run GenerateDatasetsXml.sh (see this [script](https://github.com/MathewBiddle/erddap_copy/blob/main/GenerateDatasetsXml_script.sh). 
   1. ```
      ./GenerateDatasetsXml_script.sh
      ```
   1. Point GenerateDatasetsXml.sh to the netCDF file you just downloaded.
   2. This saves a draft xml file to **logs/GenerateDatasetXml.out**.   
1. Copy the xml snippet somewhere you can edit it
   1. ```cp logs/GenerateDatasetsXml.out xml_by_dataset/bodega-head-intertidal-shore-sta.xml```
1. Edit the xml to reflect any changes. You can adopt all of ERDDAPs recommendations by uncommenting out the xml comments.
   1. ```sed 's/<!-- /</g' bodega-head-intertidal-shore-sta.xml | sed 's/ -->/>/g' > bodega-head-intertidal-shore-sta_IOOS.xml```
   2. Review the metadata and xml formatting to ensure it is correct.
   1. Set `datasetID` to something reasonable. (e.g. "bodega-head-intertidal-shore-sta_IOOS")
1. Insert the edited xml snippet into datasets.xml
   1. See https://github.com/MathewBiddle/sandbox/blob/main/xml_insert.py and https://github.com/MathewBiddle/sandbox/blob/main/script2insert.py
   1. ```
      $ python ../python_tools/script2insert.py
      ingesting ../erddap/content/datasets.xml
      ingesting ../xml_by_dataset/bodega-head-intertidal-shore-sta_IOOS.xml
      Inserting snippet for datasetID = bodega-head-intertidal-shore-sta_IOOS into ../erddap/content/datasets.xml
     ```
1. Flag dataset for reloading
   1. ```
      erddap-gold-standard/xml_by_dataset$ touch ../erddap/data/hardFlag/bodega-head-intertidal-shore-sta_IOOS
      ```
1. Review dataset on your ERDDAP!
   1. https://erddap.ioos.us/erddap/tabledap/bodega-head-intertidal-shore-sta_IOOS.html
