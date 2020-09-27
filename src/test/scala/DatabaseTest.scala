
import scala.util.{Success, Failure}
import scala.concurrent.{Future, Await}
import scala.concurrent.duration.Duration
import slick.jdbc.PostgresProfile.api._
import slick.jdbc.meta._
import org.scalatest.{Matchers, BeforeAndAfterAll, BeforeAndAfterEach}
import org.scalatest.funsuite.AnyFunSuite
import com.typesafe.scalalogging.LazyLogging
import com.typesafe.config.{ConfigFactory, ConfigValueFactory}
import ch.qos.logback.classic.{Level, Logger}
import org.slf4j.LoggerFactory
import poca.{MyDatabase, Users, User, UserAlreadyExistsException, Routes, RunMigrations}


class DatabaseTest extends AnyFunSuite with Matchers with BeforeAndAfterAll with BeforeAndAfterEach with LazyLogging {
    val rootLogger: Logger = LoggerFactory.getLogger("com").asInstanceOf[Logger]
    rootLogger.setLevel(Level.INFO)
    val slickLogger: Logger = LoggerFactory.getLogger("slick").asInstanceOf[Logger]
    slickLogger.setLevel(Level.INFO)

    // In principle, mutable objets should not be shared between tests, because tests should be independent from each other. However for performance the connection to the database should not be recreated for each test. Here we prefer to share the database.
    override def beforeAll() {
        val isRunningOnCI = sys.env.getOrElse("CI", "") != ""
        val configName = if (isRunningOnCI) "myTestDBforCI" else "myTestDB"
        val config = ConfigFactory.load().getConfig(configName)
        MyDatabase.initialize(config)
    }
    override def afterAll() {
        MyDatabase.db.close
    }

    override def beforeEach() {
        val resetSchema = sqlu"drop schema public cascade; create schema public;"
        val resetFuture: Future[Int] = MyDatabase.db.run(resetSchema)
        Await.result(resetFuture, Duration.Inf)
        new RunMigrations(MyDatabase.db)()
    }

    test("Users.createUser should create a new user") {
        val users: Users = new Users()

        val createUserFuture: Future[Unit] = users.createUser("toto")
        Await.ready(createUserFuture, Duration.Inf)

        // Check that the future succeeds
        createUserFuture.value should be(Some(Success(())))

        val getUsersFuture: Future[Seq[User]] = users.getAllUsers()
        var allUsers: Seq[User] = Await.result(getUsersFuture, Duration.Inf)

        allUsers.length should be(1)
        allUsers.head.username should be("toto")
    }

    test("Users.createUser returned future should fail if the user already exists") {
        val users: Users = new Users()

        val createUserFuture: Future[Unit] = users.createUser("toto")
        Await.ready(createUserFuture, Duration.Inf)

        val createDuplicateUserFuture: Future[Unit] = users.createUser("toto")
        Await.ready(createDuplicateUserFuture, Duration.Inf)

        createDuplicateUserFuture.value match {
            case Some(Failure(exc: UserAlreadyExistsException)) => {
                exc.getMessage should equal ("A user with username 'toto' already exists.")
            }
            case _ => fail("The future should fail.")
        }
    }

    test("Users.getUserByUsername should return no user if it does not exist") {
        val users: Users = new Users()

        val createUserFuture: Future[Unit] = users.createUser("toto")
        Await.ready(createUserFuture, Duration.Inf)

        val returnedUserFuture: Future[Option[User]] = users.getUserByUsername("somebody-else")
        val returnedUser: Option[User] = Await.result(returnedUserFuture, Duration.Inf)

        returnedUser should be(None)
    }

    test("Users.getUserByUsername should return a user") {
        val users: Users = new Users()

        val createUserFuture: Future[Unit] = users.createUser("toto")
        Await.ready(createUserFuture, Duration.Inf)

        val returnedUserFuture: Future[Option[User]] = users.getUserByUsername("toto")
        val returnedUser: Option[User] = Await.result(returnedUserFuture, Duration.Inf)

        returnedUser match {
            case Some(user) => user.username should be("toto")
            case None => fail("Should return a user.")
        }
    }

    test("Users.getAllUsers should return a list of users") {
        val users: Users = new Users()

        val createUserFuture: Future[Unit] = users.createUser("riri")
        Await.ready(createUserFuture, Duration.Inf)

        val createAnotherUserFuture: Future[Unit] = users.createUser("fifi")
        Await.ready(createAnotherUserFuture, Duration.Inf)

        val returnedUserSeqFuture: Future[Seq[User]] = users.getAllUsers()
        val returnedUserSeq: Seq[User] = Await.result(returnedUserSeqFuture, Duration.Inf)

        returnedUserSeq.length should be(2)
    }
}
