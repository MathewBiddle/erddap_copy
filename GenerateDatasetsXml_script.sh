#!/bin/bash
docker run --rm -it \
  -v "$(pwd)/datasets:/datasets" \
  -v "$(pwd)/logs:/erddapData/logs" \
  -v "$(pwd)/erddap/content:/usr/local/tomcat/content/erddap" \
  axiom/docker-erddap:2.25.1-jdk21-openjdk \
  bash -c "cd webapps/erddap/WEB-INF/ && bash GenerateDatasetsXml.sh EDDTableFromMultidimNcFiles /datasets/erddap_copy/ .*\\.nc \"\" \"\" \"\" \"\" \"\" \"\" \"\" \"\" \"\" erddap.com USIOOS \"\" \"\" \"\" \"\" \"\""
  
