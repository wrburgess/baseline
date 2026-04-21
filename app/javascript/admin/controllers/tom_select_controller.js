import { Controller } from '@hotwired/stimulus'
import TomSelect from 'tom-select'

const selectSettings = {
  allowEmptyOption: true,
  plugins: ['remove_button', 'input_autogrow', 'clear_button']
}

export default class extends Controller {
  static targets = ['tomselect']

  connect() {
    this.tomselectTargets.forEach((element) => {
      new TomSelect(element, selectSettings)
    })
  }
}
