
enablePlugins(JavaAppPackaging)
enablePlugins(DockerPlugin)

lazy val root = (project in file(".")).
  settings(
    inThisBuild(List(
      organization := "com.poca",
      scalaVersion := "2.13.1"
    )),
    name := "poca-2020"
  )

libraryDependencies ++= Seq(
  "org.scalatest" %% "scalatest" % "3.1.0" % Test,
  "com.typesafe.akka" %% "akka-stream" % "2.6.8",
  "com.typesafe.akka" %% "akka-actor-typed" % "2.6.8",
  "com.typesafe.akka" %% "akka-http" % "10.2.0",
  "com.typesafe.akka" %% "akka-http-testkit" % "10.2.0",
  "com.typesafe.akka" %% "akka-actor-testkit-typed" % "2.6.8",
  "com.typesafe.scala-logging" %% "scala-logging" % "3.9.2",
  "ch.qos.logback" % "logback-classic" % "1.2.3"
)

dockerExposedPorts ++= Seq(8080)
//dockerRepository = "[repository.host[:repository.port]]"
//dockerUsername = ""
