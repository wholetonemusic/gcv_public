import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ 'select', 'submit', 'guitarform' ]

  connect() {
    if (this.submitTargets.forEach((submitTarget) => submitTarget.disabled == false))
    {
      this.submitTargets.forEach((submitTarget) => submitTarget.disabled = true)
    }
  }

  category_select(event) {
    const guitars = [
      "Electric-Solid-Body-Guitar",
      "Electric-Semi-Hollow-Body-Guitar",
      "Electric-Hollow-Body-Guitar",
      "Acoustic-Electric-Guitar",
      "Dreadnought-Acoustic-Guitar",
      "Classical-Acoustic-Guitar"
    ]
    const pedaletcs = [
      "Pedal",
      "Amplifier",
      "Parts-Accessories",
      "Rec-Gear",
      "Others"
    ]

    if (guitars.includes(event.target.selectedOptions[0].value)
    ) {
      this.submitTargets.forEach((submitTarget) => submitTarget.disabled = false)
      this.guitarformTarget.hidden = false
    } else if (pedaletcs.includes(event.target.selectedOptions[0].value)
    ) {
      this.submitTargets.forEach((submitTarget) => submitTarget.disabled = false)
      this.guitarformTarget.hidden = true
    }
  }
}
