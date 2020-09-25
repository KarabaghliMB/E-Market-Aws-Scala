
import scala.concurrent.{Future, Await}
import scala.concurrent.duration.Duration
import slick.jdbc.PostgresProfile.api._
import slick.jdbc.meta._
import org.scalatest.{Matchers, BeforeAndAfterAll, BeforeAndAfterEach}
import org.scalatest.funsuite.AnyFunSuite
import com.typesafe.scalalogging.LazyLogging


class DatabaseTest extends AnyFunSuite with Matchers with BeforeAndAfterAll with BeforeAndAfterEach with LazyLogging {

    // In principle, mutable objets should not be shared between tests, because tests should be independent from each other. However for performance the connection to the database should not be recreated for each test. Here we prefer to share the database.
    override def beforeAll() {
        val isRunningOnCI = sys.env.getOrElse("CI", "") != ""
        val configName = if (isRunningOnCI) "myTestDBforCI" else "myTestDB"
        MyDatabase.initialize(configName)
    }
    override def afterAll() {
        MyDatabase.db.close
    }

    override def beforeEach() {
        val resetSchema = sqlu"drop schema public cascade; create schema public;"
        val resetFuture: Future[Int] = MyDatabase.db.run(resetSchema)
        Await.ready(resetFuture, Duration.Inf)
    }

    test("Users.createTable should create a table named 'users'") {
        val createFuture: Future[Unit] = Users.createTable

        Await.ready(createFuture, Duration.Inf)

        val tableRequest = MyDatabase.db.run(MTable.getTables("users"))
        val tableList = Await.result(tableRequest, Duration.Inf)

        tableList.length should be(1)
    }
}
