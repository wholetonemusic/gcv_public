import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  open() {
    console.log("Hello, Stimulus!", this.element)
  }
}

