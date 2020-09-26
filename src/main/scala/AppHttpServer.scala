
package poca

import akka.actor.typed.ActorSystem
import akka.actor.typed.scaladsl.Behaviors
import akka.http.scaladsl.Http
import scala.concurrent.{Future, Await}
import scala.concurrent.duration.Duration
import com.typesafe.scalalogging.LazyLogging


object AppHttpServer extends LazyLogging {

    def main(args: Array[String]): Unit = {
        implicit val actorsSystem = ActorSystem(guardianBehavior=Behaviors.empty, name="my-system")
        implicit val actorsExecutionContext = actorsSystem.executionContext

        MyDatabase.initialize("mydb")
        val db = MyDatabase.db
        var users = new Users()
        val routes = new Routes(users)

        val bindingFuture = Http().newServerAt("0.0.0.0", 8080).bind(routes.routes)

        val serverStartedFuture = bindingFuture.map(binding => {
            val address = binding.localAddress
            logger.info(s"Server online at http://${address.getHostString}:${address.getPort}/")
        })

        val waitOnFuture = serverStartedFuture.flatMap(unit => Future.never)
        
        scala.sys.addShutdownHook { 
            actorsSystem.terminate
            db.close
        }

        Await.ready(waitOnFuture, Duration.Inf)
    }
}
