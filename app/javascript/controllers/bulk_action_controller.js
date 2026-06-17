// app/javascript/controllers/bulk_action_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["selectAll", "checkbox"]

    toggleAll(event) {
        const selectAll = event.target
        const phaseId = selectAll.dataset.phase

        let checkboxes

        if (phaseId) {
            // Scoped to a phase box (used in expedition tasks)
            checkboxes = this.checkboxTargets.filter(cb => cb.dataset.phase === phaseId)
        } else {
            // Generic index page (like /users)
            // Try scoping to the same table or parent container
            const container = selectAll.closest("table") || document
            checkboxes = container.querySelectorAll('input.bulk-checkbox')
        }

        checkboxes.forEach(cb => {
            cb.checked = selectAll.checked
        })

        console.log("☑️ toggleAll triggered", {
            selectAll,
            phaseId,
            count: checkboxes.length
        })
    }
    connect() {
        window.__bulkSubmitInProgress__ = false

        // Close modal cleanly after successful Turbo form submit,
        // then reset the form + TomSelect and remove any leftover backdrops.
        document.addEventListener("turbo:submit-end", (e) => {
            if (!e.detail.success) return

            const modalEl = e.target.closest(".modal") || document.querySelector(".modal.show")
            if (modalEl && window.bootstrap?.Modal) {
                (window.bootstrap.Modal.getInstance(modalEl) || new window.bootstrap.Modal(modalEl)).hide()
            }

            // Reset form so selections don't linger next open
            const form = modalEl?.querySelector("form")
            if (form) form.reset()

            // Clear TomSelects inside the modal (if any)
            modalEl?.querySelectorAll('select[data-controller="tom-select"]').forEach((sel) => {
                if (sel.tomselect) {
                    sel.tomselect.clear(true)
                    sel.tomselect.close()
                    sel.tomselect.blur()
                } else {
                    sel.selectedIndex = -1
                }
            })

            // Defensive cleanup to restore page scroll
            document.querySelectorAll(".ts-dropdown").forEach(n => n.remove())
            document.querySelectorAll(".modal-backdrop").forEach(el => el.remove())
            document.body.classList.remove("modal-open")
            document.body.style.removeProperty("overflow")
        })
    }
    submitFromMenu(event) {
        event.preventDefault()
        event.stopPropagation()

        if (window.__bulkSubmitInProgress__) return
        const action = event.currentTarget.dataset.bulkActionActionValue
        const form = document.querySelector("#bulk-action-form")
        const container = form?.closest(".we-box") || document

        const checkboxes = container.querySelectorAll('input.bulk-checkbox:checked')
        const selectedIds = Array.from(checkboxes).map(cb => cb.value)
        const isOnUsersPage = window.location.pathname === "/users"

        console.log("📦 Action:", action, "✅ Selected IDs:", selectedIds)

        const requiresSelection = ["delete", "edit", "complete", "change_role"].includes(action) ||
            (action === "add_to_expedition" && isOnUsersPage)

        if (requiresSelection && selectedIds.length === 0) {
            alert("Please select at least one item.")
            return
        }

        console.log("🔔 requiresSelection:", requiresSelection, "selectedIds.length:", selectedIds.length)

        const ensureHiddenFields = (formSelector) => {
            const form = document.querySelector(formSelector)
            if (!form) return

            form.querySelectorAll('input[name="selected_ids[]"]').forEach(e => e.remove())

            selectedIds.forEach(id => {
                const input = document.createElement("input")
                input.type = "hidden"
                input.name = "selected_ids[]"
                input.value = id
                form.appendChild(input)
            })

            console.log("🧾 Injected hidden fields:", Array.from(form.querySelectorAll('input[name="selected_ids[]"]')).map(i => i.value))
        }

        if (action === "add") {
            ensureHiddenFields("#bulk-action-form")
            document.getElementById("bulk_action_field").value = action
            window.__allowBulkSubmit__ = true
            window.__bulkSubmitInProgress__ = true
            form.submit()
            return
        }

        // helper (optional)
        const showModal = (id) => {
            const el = document.getElementById(id)
            if (!el) return
            if (window.bootstrap?.Modal) {
                new window.bootstrap.Modal(el).show()
            } else {
                console.warn("🚨 Bootstrap Modal is not available")
            }
        }

        if (action === "add_to_expedition") {
            ensureHiddenFields("#add_to_expedition form") // inject selected_ids[]
            showModal("add_to_expedition")
            return
        }

        if (action === "add_to_organisation") {
            ensureHiddenFields("#add_to_organisation form") // inject selected_ids[]
            showModal("add_to_organisation")
            return
        }


        if (action === "change_role") {
            ensureHiddenFields("#change_role form")
            const modalEl = document.getElementById("change_role")
            if (modalEl && window.bootstrap?.Modal) {
                new window.bootstrap.Modal(modalEl).show()
            } else {
                console.warn("🚨 Bootstrap Modal is not available", window.bootstrap)
            }
            return
        }

        ensureHiddenFields("#bulk-action-form")
        document.getElementById("bulk_action_field").value = action
        window.__allowBulkSubmit__ = true
        window.__bulkSubmitInProgress__ = true

        console.log("⏳ Submitting form in 10ms with IDs:", selectedIds)
        setTimeout(() => {
            form.submit()
        }, 10)
    }

}
