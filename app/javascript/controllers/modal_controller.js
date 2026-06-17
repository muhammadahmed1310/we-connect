import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["container", "backdrop", "card"]

    connect() {
        // prevent background scroll and add a consistent flag
        document.body.classList.add("we-modal-open")
        this.boundEsc = this.onKeydown.bind(this)
        document.addEventListener("keydown", this.boundEsc)
    }

    disconnect() {
        // cleanup if the element was removed by Turbo or manually
        document.body.classList.remove("we-modal-open")
        document.removeEventListener("keydown", this.boundEsc)
    }

    close(event) {
        event?.preventDefault()

        // If this was the forced modal, revert checkbox (user cancelled conversion)
        const force = this.element.querySelector('input[name="force_set_password"]')?.value === "1"
        if (force) {
            const cb = document.querySelector('input[type="checkbox"][name$="[is_contact_only]"]')
            if (cb) {
                cb.checked = true
                cb.dispatchEvent(new Event("change", { bubbles: true }))
            }
        }

        const frame = document.getElementById("password-modal")
        if (frame && frame.contains(this.element)) {
            frame.innerHTML = ""
            return
        }
        this.element.remove()
    }

    stop(e) {
        // Don’t let clicks inside the card bubble to the backdrop
        e.stopPropagation()
    }

    onKeydown(e) {
        if (e.key === "Escape") this.close()
    }
}
