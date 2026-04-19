import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["output"]

  connect() {
    console.log("Public Yo Controller Connected")
    if (this.hasOutputTarget) {
      this.outputTarget.textContent = "Hello from Yo Controller!"
    } else {
      console.log("No output target found for public Yo controller")
    }
  }
}
