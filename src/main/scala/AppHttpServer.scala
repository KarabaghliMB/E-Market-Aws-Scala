
package poca

import akka.actor.typed.ActorSystem
import akka.actor.typed.scaladsl.Behaviors
import akka.http.scaladsl.Http
import scala.concurrent.{Future, Await}
import scala.concurrent.duration.Duration
import com.typesafe.scalalogging.LazyLogging
import com.typesafe.config.{ConfigFactory, ConfigValueFactory}


object AppHttpServer extends LazyLogging {

    def main(args: Array[String]): Unit = {
        implicit val actorsSystem = ActorSystem(guardianBehavior=Behaviors.empty, name="my-system")
        implicit val actorsExecutionContext = actorsSystem.executionContext

        val isRunningOnCloud = sys.env.getOrElse("DB_HOST", "") != ""
        var rootConfig = ConfigFactory.load()
        val dbConfig = if (isRunningOnCloud) {
            val dbHost = sys.env.getOrElse("DB_HOST", "")
            val dbPassword = sys.env.getOrElse("DB_PASSWORD", "")

            val originalConfig = rootConfig.getConfig("cloudDB")
            originalConfig.
                withValue("properties.serverName", ConfigValueFactory.fromAnyRef(dbHost)).
                withValue("properties.password", ConfigValueFactory.fromAnyRef(dbPassword))
        } else {
            rootConfig.getConfig("localDB")
        }
        MyDatabase.initialize(dbConfig)
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
