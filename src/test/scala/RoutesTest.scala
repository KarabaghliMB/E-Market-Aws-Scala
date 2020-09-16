
import akka.actor.testkit.typed.scaladsl.ActorTestKit
import akka.http.scaladsl.model.{HttpRequest, StatusCodes, ContentTypes}
import akka.http.scaladsl.testkit.ScalatestRouteTest
import org.scalatest.Matchers
import org.scalatest.funsuite.AnyFunSuite


class RoutesTest extends AnyFunSuite with Matchers with ScalatestRouteTest {

    // the Akka HTTP route testkit does not yet support a typed actor system (https://github.com/akka/akka-http/issues/2036)
    // so we have to adapt for now
    lazy val testKit = ActorTestKit()
    implicit def typedSystem = testKit.system
    override def createActorSystem(): akka.actor.ActorSystem =
        testKit.system.classicSystem

    test("Route GET /hello should say hello") {
        val request = HttpRequest(uri = "/hello")
        request ~> routes ~> check {
            status should ===(StatusCodes.OK)

            contentType should ===(ContentTypes.`application/json`)

            entityAs[String] should ===("""Hello mate!""")
        }
    }
}
