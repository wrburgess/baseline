import { application } from "../../controllers/application"
import YoController from "./yo_controller"

// Register the controller with the application instance
application.register("yo", YoController)
