
package poca

import scala.concurrent.{Future, Await}
import scala.concurrent.duration.Duration
import com.typesafe.scalalogging.LazyLogging


object CreateTables extends LazyLogging {

    def main(args: Array[String]): Unit = {
        implicit val executionContext = scala.concurrent.ExecutionContext.Implicits.global
        val db = MyDatabase.db
        var exitCode = 0

        val creationFuture: Future[Unit] = new Users().createTable

        val successCase: Future[Unit] = creationFuture.
            map(_ => logger.info("Done creating table Users"))

        val failureCase: Future[Unit] = creationFuture.
            failed.
            map(exc => {
                logger.error("Could not create table Users: " + exc)
                exitCode = 1
            }
        )

        val combinedFuture = for {
            _ <- successCase
            _ <- failureCase
        } yield akka.Done

        Await.ready(combinedFuture, Duration.Inf)

        db.close

        System.exit(exitCode)
    }
}
