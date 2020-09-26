
package poca

import scala.concurrent.Future
import akka.http.scaladsl.server.Directives.{path, get, post, formFieldMap, complete, concat}
import akka.http.scaladsl.server.Route
import akka.http.scaladsl.model.{HttpEntity, HttpResponse, ContentTypes, StatusCodes}
import com.typesafe.scalalogging.LazyLogging
import TwirlMarshaller._


class Routes(users: Users) extends LazyLogging {
    implicit val executionContext = scala.concurrent.ExecutionContext.Implicits.global

    def getHello() = {
        logger.info("I got a request to greet.")
        HttpEntity(
            ContentTypes.`text/html(UTF-8)`,
            "<h1>Say hello to akka-http</h1>"
        )
    }

    def getSignup() = {
        logger.info("I got a request for signup.")
        html.signup()
    }

    def register(fields: Map[String, String]): Future[HttpResponse] = {
        logger.info("I got a request to register.")

        fields.get("username") match {
            case Some(username) => {
                val userCreation: Future[Unit] = users.createUser(username=username)

                userCreation.map(_ => {
                    HttpResponse(
                        StatusCodes.OK,
                        entity=s"Welcome '$username'! You've just been registered to our great marketplace.",
                    )
                }).recover({
                    case exc: UserAlreadyExistsException => {
                        HttpResponse(
                            StatusCodes.OK,
                            entity=s"The username '$username' is already taken. Please choose another username.",
                        )
                    }
                })
            }
            case None => {
                Future(
                    HttpResponse(
                        StatusCodes.BadRequest,
                        entity="Field 'username' not found."
                    )
                )
            }
        }
    }

    def getUsers() {
        logger.info("I got a request to get user list.")

        val userSeqFuture: Future[Seq[User]] = users.getAllUsers()

        userSeqFuture.map(userSeq => html.users(userSeq))
    }

    val routes: Route = 
        concat(
            path("hello") {
                get {
                    complete(getHello)
                }
            },
            path("signup") {
                get {
                    complete(getSignup)
                }
            },
            path("register") {
                (post & formFieldMap) { fields =>
                    complete(register(fields))
                }
            },
            path("users") {
                get {
                    complete(getUsers)
                }
            }
        )

}
