
import akka.http.scaladsl.server.Directives.{path, get, complete, concat}
import akka.http.scaladsl.server.Route
import akka.http.scaladsl.model.{HttpEntity, ContentTypes}
import com.typesafe.scalalogging.LazyLogging
import TwirlMarshaller._


object Routes extends LazyLogging {
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
            }
        )

}
