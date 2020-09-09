class HelloWorldTest extends org.scalatest.funsuite.AnyFunSuite {
  test("HelloWorld.prepareMessage") {
    assert(HelloWorld.prepareMessage === "Hello, world!")
  }
}
