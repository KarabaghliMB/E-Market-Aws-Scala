/*
    Initialization code for the database, although simple, is extracted to its own file in order to avoid mixing up the execution context used for the database with the other execution contexts of the application.

    The access to the database is made available as a singleton.
*/

import slick.jdbc.PostgresProfile.api._

object MyDatabase {
    implicit val executionContext = scala.concurrent.ExecutionContext.Implicits.global
    val db = Database.forConfig("mydb")
}
