# POCA 2020

Our product is a marketplace connecting buyers to sellers. Similar products are: Amazon.com, Rakuten, Cdiscount.com, Veepee...

Online shopping is not original at all but it has a rich domain with interesting choices to make. Let's view it as a playground where we can either borrow ideas from our competitors or build our own vision of what a marketplace should be!

## Install instructions

Make sure you have scala installed.

## Run the tests

```
sbt clean coverage test
```

## Generate coverage report

After running the tests:

```
sbt coverageReport
```

Then look at [target/scala-2.13/scoverage-report/index.html](target/scala-2.13/scoverage-report/index.html) for the HTML report.

## Run the software

```
sbt run
```
