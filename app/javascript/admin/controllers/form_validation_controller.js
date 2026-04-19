import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.classList.add('needs-validation')
    this.element.noValidate = true
  }

  submit(event) {
    if (!this.element.checkValidity()) {
      event.preventDefault()
      event.stopPropagation()
    }

    this.element.classList.add('was-validated')
  }
}
