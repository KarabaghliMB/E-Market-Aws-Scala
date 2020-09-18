# POCA 2020

Our product is a marketplace connecting buyers to sellers. Similar products are: Amazon.com, Rakuten, Cdiscount.com, Veepee...

Online shopping is not original at all but it has a rich domain with interesting choices to make. Let's view it as a playground where we can either borrow ideas from our competitors or build our own vision of what a marketplace should be!

## Install instructions

Make sure you have scala and sbt installed.

## Run the tests

```
sbt clean coverage test coverageReport
```

This also creates a coverage report at [target/scala-2.13/scoverage-report/index.html](target/scala-2.13/scoverage-report/index.html).


## Run the software

```
sbt run
```

## Package to a Docker image

Make sure Docker is installed locally.

```
sbt docker:publishLocal
```

Then the image with name `poca-2020` and tag `0.1.0-SNAPSHOT` is listed:

```
docker image ls
```

Run the docker image locally:

```
docker run -p 8080:8080 poca-2020:0.1.0-SNAPSHOT
```

To remove old images:

```
docker image prune
```
