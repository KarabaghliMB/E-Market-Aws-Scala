
package poca

import scala.concurrent.Future
import slick.jdbc.PostgresProfile.api._
import java.util.UUID

case class User(userId: String, username: String)

final case class UserAlreadyExistsException(private val message: String="", private val cause: Throwable=None.orNull)
    extends Exception(message, cause) 
final case class InconsistentStateException(private val message: String="", private val cause: Throwable=None.orNull)
    extends Exception(message, cause) 

class Users {
    class UsersTable(tag: Tag) extends Table[(String, String)](tag, "users") {
        def userId = column[String]("userId", O.PrimaryKey)
        def username = column[String]("username")
        def * = (userId, username)
    }

    implicit val executionContext = scala.concurrent.ExecutionContext.Implicits.global
    val db = MyDatabase.db
    val users = TableQuery[UsersTable]

    def createUser(username: String): Future[Unit] = {
        val existingUsersFuture = getUserByUsername(username)

        existingUsersFuture.flatMap(existingUsers => {
            if (existingUsers.isEmpty) {
                val userId = UUID.randomUUID.toString()
                val newUser = User(userId=userId, username=username)
                val newUserAsTuple: (String, String) = User.unapply(newUser).get

                val dbio: DBIO[Int] = users += newUserAsTuple
                var resultFuture: Future[Int] = db.run(dbio)

                // We do not care about the Int value
                resultFuture.map(_ => ())
            } else {
                throw new UserAlreadyExistsException(s"A user with username '$username' already exists.")
            }
        })
    }

    def getUserByUsername(username: String): Future[Option[User]] = {
        val query = users.filter(_.username === username)

        val userListFuture = db.run(query.result)

        userListFuture.map((userList: Seq[(String, String)]) => {
            userList.length match {
                case 0 => None
                case 1 => Some(User tupled userList.head)
                case _ => throw new InconsistentStateException(s"Username $username is linked to several users in database!")
            }
        })
    }

    def getAllUsers(): Future[Seq[User]] = {
        val userListFuture = db.run(users.result)

        userListFuture.map((userList: Seq[(String, String)]) => {
            userList.map(User tupled _)
        })
    }
}
