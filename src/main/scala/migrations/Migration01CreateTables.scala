
package poca

import scala.concurrent.{Future, Await}
import scala.concurrent.duration.Duration
import com.typesafe.scalalogging.LazyLogging
import slick.jdbc.PostgresProfile.api._


class Migration01CreateTables(db: Database) extends Migration with LazyLogging {
    override def apply(): Unit = {
        implicit val executionContext = scala.concurrent.ExecutionContext.Implicits.global
        var exitCode = 0

        val creationFuture: Future[Unit] = new Users().createTable

        Await.result(creationFuture, Duration.Inf)
        logger.info("Done creating table Users")
    }
}
