import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

// Finds a sensible "field group" wrapper to hide/show
function findFieldContainer(el) {
    if (!el) return null
    const candidates = [".form-group", ".mb-3", ".field", ".form-check", ".input", "li.input"]
    for (const sel of candidates) {
        const c = el.closest(sel)
        if (c) return c
    }
    const labelWrap = el.closest("label")
    if (labelWrap) return labelWrap.parentElement || labelWrap
    return el.parentElement || null
}

export default class extends Controller {
    connect() {
        // Controller is on the checkbox itself
        this.checkbox =
            this.element.matches('input[type="checkbox"]')
                ? this.element
                : this.element.querySelector('input[type="checkbox"]')

        if (!this.checkbox) return

        // Track previous state to detect transitions
        this.previousChecked = !!this.checkbox.checked

        // Apply initial hide/show WITHOUT triggering modal
        requestAnimationFrame(() => this.applyUI(this.checkbox.checked))
    }

    toggle(event) {
        const checked = !!event.target.checked
        const root = this.element.closest("form") || document

        // Always update UI
        this.applyUI(checked)

        // ✅ Only open modal when user actually changed from contact -> user
        const userInitiated = event?.isTrusted === true // real user event
        const transitionedContactToUser = (this.previousChecked === true && checked === false)

        if (userInitiated && transitionedContactToUser) {
            const userId = root.dataset.userId
            if (userId) {
                const url = `/users/${userId}/password_modal?force_set_password=1`
                Turbo.visit(url, { frame: "password-modal" })
            }
        }

        this.previousChecked = checked
    }

    applyUI(checked) {
        const root = this.element.closest("form") || document
        // Hide/show "Change password" (login-only UI)
        root.querySelectorAll(".contact-login-only").forEach(el => {
            el.style.display = checked ? "none" : ""
        })
        // 1) Hide/show credential inputs
        root.querySelectorAll(".contact-credentials").forEach(el => {
            const group = findFieldContainer(el)
            if (group) group.style.display = checked ? "none" : ""

            if (["password", "password_confirmation"].includes(el.name)) {
                if (checked) el.removeAttribute("required")
                else el.setAttribute("required", "required")
            }
            if (checked) el.value = ""
        })

        // 2) Reach Permission field
        const permInput =
            root.querySelector('input[type="checkbox"][name$="[is_contact_restricted]"]') ||
            root.querySelector(".contact-permission-input")

        if (permInput) {
            const permGroup = findFieldContainer(permInput)
            if (permGroup) permGroup.style.display = checked ? "" : "none"
            if (!checked) permInput.checked = false
        }

        // 3) Panels
        root.querySelectorAll('[data-contact-toggle-target="panel"]').forEach(el => {
            const group = findFieldContainer(el)
            if (group) group.style.display = checked ? "" : "none"

            if (!checked) {
                if (el.tagName === "SELECT") el.value = ""
                else if (el.type === "checkbox") el.checked = false
            }
        })
    }
}
