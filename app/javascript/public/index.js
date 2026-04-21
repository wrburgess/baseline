import "@hotwired/turbo-rails"
import { Application } from "@hotwired/stimulus"

// Initialize Stimulus for public
const application = Application.start()

// Enable debug mode in development
application.debug = true

window.Stimulus = application

// Import all public controllers
import "./controllers"

// Log that public JS is loaded
// console.log("Public JavaScript bundle loaded")
