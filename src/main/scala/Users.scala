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
    val db = MyDatabase.db
    val users = TableQuery[Users]

    def createTable: Future[Unit] = {
        val dbio: DBIO[Unit] = users.schema.create
        db.run(dbio)
    }
}
