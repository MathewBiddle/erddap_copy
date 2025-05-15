# erddap_copy
A demonstration of how to copy datasets from an ERDDAP server to another ERDDAP server.

## Step-by-step
1. Identify service to replicate.
   1. ERDDAP ✅
1. Find dataset to replicate.
   1. <https://erddap.nanoos.org/erddap/info/index.html>
   1. <https://erddap.cencoos.org/erddap/index.html> 
1. Identify where to host replicate service
   1. AWS S3?
1. Establish service
   1. ```
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
   1. ```mkdir repo_copy/```
1. Copy data to that directory.
   1. see `copy_erddap_data.py` 
1. Run GenerateDatasetsXml.sh
   1. ```
      Which EDDType (default="EDDGridFromDap")
      ? EDDTableFromMultidimNcFiles
      Starting directory (default="")
      ? /dataset
      File name regex (e.g., ".*\.nc") (default="")
      ? .*\.nc
      Full file name of one file (or leave empty to use first matching fileName) (default="")
      ? ""
      DimensionsCSV (or "" for default) (default="")
      ? ""
      ReloadEveryNMinutes (e.g., 10080) (default="")
      ? ""
      PreExtractRegex (default="")
      ? ""
      PostExtractRegex (default="")
      ? ""
      ExtractRegex (default="")
      ? ""
      Column name for extract (default="")
      ? ""
      Remove missing value rows (true|false) (default="")
      ? ""
      Sort files by sourceNames (default="")
      ? ""
      infoUrl (default="")
      ? erddap.com
      institution (default="")
      ? US IOOS
      summary (default="")
      ? ""
      title (default="")
      ? ""
      standardizeWhat (-1 to get the class' default) (default="")
      ? ""
      treatDimensionsAs (default="")
      ? ""
      cacheFromUrl (default="")
      ? ""
      ```
