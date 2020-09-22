/*
    Initialization code for the database, although simple, is extracted to its own file in order to avoid mixing up the execution context used for the database with the other execution contexts of the application.
*/

import slick.jdbc.PostgresProfile.api._

object DatabaseInitializer {
    def apply() = {
        implicit val executionContext = scala.concurrent.ExecutionContext.Implicits.global
        Database.forConfig("mydb")
    }
}
