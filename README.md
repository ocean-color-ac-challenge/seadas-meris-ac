## MERIS atmospheric correction effects using SeaDAS

This tutorial builds upon the SeaDAS NASA project. More context information is available from the [project web page](http://seadas.gsfc.nasa.gov).

### Getting started

The Getting started guide to implement a "MERIS Level 1 to Level 2 atmospheric correction effects using SeaDAS" application on Terradue's Developer Cloud Sandbox platform, a set of Cloud services to develop, test and exploit scalable, distributed Earth Science processors.

To run this application, you will need a Developer Cloud Sandbox that can be requested from [Terradue's Portal](http://www.terradue.com/partners), provided user registration approval. 

#### Installation

You can install the application in two ways, via mvn or via rpm

* install via mvn

Log on the developer sandbox and run these commands in a shell:

```bash
sudo yum -y install seadas
git clone git@github.com:ocean-color-ac-challenge/seadas-meris-ac.git
cd seadas-meris-ac
mvn install
```

This will install the seadas-meris-ac application and the SeaDAS processor from NASA.

* Download and install via rpm

Click on the latest release available in the releases page, then copy the file to your sandbox:

```bash
scp seadas-meris-ac-0.1-ciop.noarch.rpm <your sandbox ip>:
```
Log on the developer sandbox and run this command in a shell:

```bash
sudo yum -y install seadas-meris-ac
```

#### Submitting the workflow

Run this command in a shell:

```bash
ciop-simwf
```

Or invoke the Web Processing Service via the Sandbox dashboard providing a start/stop date in the format YYYY/MM/DD (e.g. 2012-04-01 and 2012-04-03), the bounding box (upper left lat/lon, lower right lat/lon) and the par (input param file) location.

### Community and Documentation

To learn more and find information go to 

* [Developer Cloud Sandbox](http://docs.terradue.com/developer-sandbox) service 

### Authors (alphabetically)

* Fabrice Brito
* Fabio D'Andria

### License

Copyright 2014 Terradue Srl

Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
