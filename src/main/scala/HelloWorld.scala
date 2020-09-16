
import akka.actor.typed.ActorSystem
import akka.actor.typed.scaladsl.Behaviors
import akka.http.scaladsl.Http

import scala.io.StdIn

object HttpServerRoutingMinimal {

    def main(args: Array[String]): Unit = {

        implicit val system = ActorSystem(guardianBehavior=Behaviors.empty, name="my-system")
        // needed for the future flatMap/onComplete in the end
        implicit val executionContext = system.executionContext

        val bindingFuture = Http().newServerAt("localhost", 8080).bind(Routes.routes)

        println(s"Server online at http://localhost:8080/\nPress RETURN to stop...")
        StdIn.readLine() // let it run until user presses return
        bindingFuture
        .flatMap(_.unbind()) // trigger unbinding from the port
        .onComplete(_ => system.terminate()) // and shutdown when done
    }
}
