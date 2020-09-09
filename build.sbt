lazy val root = (project in file(".")).
  settings(
    inThisBuild(List(
      organization := "com.poca",
      scalaVersion := "2.13.1"
    )),
    name := "poca-2020"
  )

libraryDependencies += "org.scalatest" %% "scalatest" % "3.1.0" % Test
