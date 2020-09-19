# POCA 2020

Our product is a marketplace connecting buyers to sellers. Similar products are: Amazon.com, Rakuten, Cdiscount.com, Veepee...

Online shopping is not original at all but it has a rich domain with interesting choices to make. Let's view it as a playground where we can either borrow ideas from our competitors or build our own vision of what a marketplace should be!

## Install instructions

To use the software, Docker is needed.

For development, scala, sbt and terraform are also needed.

## Run the tests

```
sbt clean coverage test coverageReport
```

This also creates a coverage report at [target/scala-2.13/scoverage-report/index.html](target/scala-2.13/scoverage-report/index.html).


## Run the software

Fetch the software from Docker Hub:

```
docker run poca/poca-2020:latest
```

Run from the local directory:
```
sbt run
```

## Package to a Docker image

```
sbt docker:publishLocal
```

Then the image with name `poca-2020` and tag `latest` is listed. (There is also an image `poca-2020:0.1.0-SNAPSHOT` that is identical).

```
docker image ls
```

Run the docker image locally:

```
docker run -p 8080:8080 poca-2020:latest
```

To remove old images:

```
docker image prune
```

## Deployment

In the directory `teraform`, to initialize the project:

```
terraform init
```

To plan the deployment:

```
terraform plan
```

To deploy:

```
terraform apply
```

To destroy:

```
terraform destroy
```
