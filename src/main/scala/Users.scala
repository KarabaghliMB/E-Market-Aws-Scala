import scala.concurrent.Future
import slick.jdbc.PostgresProfile.api._
import java.util.UUID

case class User(userId: String, username: String)

class Users(tag: Tag) extends Table[(String, String)](tag, "users") {
    def userId = column[String]("userId", O.PrimaryKey)
    def username = column[String]("username")
    def * = (userId, username)
}

object Users {
    implicit val executionContext = scala.concurrent.ExecutionContext.Implicits.global
    val db = MyDatabase.db
    val users = TableQuery[Users]

    def createTable: Future[Unit] = {
        val dbio: DBIO[Unit] = users.schema.create
        db.run(dbio)
    }

    def createUser(username: String): Future[Unit] = {
        val userId = UUID.randomUUID.toString()
        val newUser = User(userId=userId, username=username)
        val newUserAsTuple: (String, String) = User.unapply(newUser).get

        val dbio: DBIO[Int] = users += newUserAsTuple
        var resultFuture: Future[Int] = db.run(dbio)

        // We do not care about the Int value
        resultFuture.map(_ => ())
    }

    def getAllUsers(): Future[Seq[User]] = {
        val userListFuture = db.run(users.result)

        userListFuture.map((userList: Seq[(String, String)]) => {
            userList.map(User tupled _)
        })
    }
}
