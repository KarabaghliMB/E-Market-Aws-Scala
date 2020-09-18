
import akka.http.scaladsl.server.Directives.{path, get, complete}
import akka.http.scaladsl.server.Route
import akka.http.scaladsl.model.{HttpEntity, ContentTypes}
import com.typesafe.scalalogging.LazyLogging


object Routes extends LazyLogging {
    def getHello() = {
        logger.info("I got a request to greet.")
        HttpEntity(
            ContentTypes.`text/html(UTF-8)`,
            "<h1>Say hello to akka-http</h1>"
        )
    }

    val routes: Route = 
        path("hello") {
            get {
                complete(getHello)
            }
        }
}
