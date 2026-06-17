import { Controller } from "@hotwired/stimulus"

// data-controller="auto-dismiss"
// data-auto-dismiss-ms-value="4000"   (optional; default 4000)
// data-auto-dismiss-remove-value="true" (optional)
export default class extends Controller {
    static values = { ms: { type: Number, default: 4000 }, remove: { type: Boolean, default: true } }

    connect() {
        this._timer = setTimeout(() => this.dismiss(), this.msValue)
    }

    disconnect() {
        clearTimeout(this._timer)
    }

    dismiss() {
        // fade out if the class exists, otherwise just remove/hide
        this.element.classList.add("we-fade-out")
        // remove after transition
        const onEnd = () => {
            this.element.removeEventListener("transitionend", onEnd)
            if (this.removeValue) this.element.remove()
            else this.element.setAttribute("hidden", "hidden")
        }
        this.element.addEventListener("transitionend", onEnd)
        // fallback in case transitionend never fires
        setTimeout(onEnd, 500)
    }
}
