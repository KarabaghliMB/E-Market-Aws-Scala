
import akka.http.scaladsl.server.Directives.{path, get, complete}
import akka.http.scaladsl.server.Route
import akka.http.scaladsl.model.{HttpEntity, ContentTypes}


object Routes {
    val routes: Route = 
        path("hello") {
            get {
                complete(
                    HttpEntity(
                        ContentTypes.`text/html(UTF-8)`,
                        "<h1>Say hello to akka-http</h1>"
                    )
                )
            }
        }
}
