import { Controller } from "@hotwired/stimulus"
import "tom-select"

export default class extends Controller {
    static targets = ["select", "nameInput", "typeInput"]   // ← add typeInput
    static values = {
        addLabel: { type: String, default: "+ Add new organisation" },
        modalId:   { type: String, default: "new-organisation-modal" },
        createUrl: { type: String }
    }

    connect() {
        if (this.element.classList.contains("org-select--loaded")) return;

        this.selectEl = this.hasSelectTarget ? this.selectTarget : this.element.querySelector("select");
        if (!this.selectEl) return;

        this.ts = new TomSelect(this.selectEl, {
            create: false,
            searchField: ["text"],
            sortField: { field: "text", direction: "asc" },
            persist: true,
            // IMPORTANT: allow many items (null = unlimited, default)
            maxItems: null,
            plugins: ['remove_button'],   // nice-to-have UX
            onItemAdd: () => this.ts.setTextboxValue("")
        });

        // ⬇️ Flush current selection as soon as the user starts typing again
        const isPrintable = (e) =>
            e.key.length === 1 && !e.ctrlKey && !e.metaKey && !e.altKey; // letters, numbers, symbols, space


        const ensureAddRow = () => {
            const dd = this.ts?.dropdown_content;
            if (!dd) return;
            let row = dd.querySelector(".ts-add-org-row");
            if (!row) {
                row = document.createElement("div");
                row.className = "option ts-add-org-row";
                row.setAttribute("role", "option");
                row.style.cursor = "pointer";
                row.textContent = this.addLabelValue;
                row.addEventListener("mousedown", (e) => {
                    e.preventDefault();
                    e.stopPropagation();
                    try { this.ts?.close(); this.ts?.blur(); } catch (_) {}
                    this.openModal();
                    });
            }
            dd.appendChild(row); // keep pinned at end
        };
        this.ts.on("dropdown_open", ensureAddRow);
        this.ts.on("type", ensureAddRow);
        this.ts.on("load", ensureAddRow);
        ensureAddRow();


        this.element.classList.add("org-select--loaded");
    }

    get modal() { return document.getElementById(this.modalIdValue); }

    openModal() {
        this.clearModalError();
        if (this.hasNameInputTarget) {
            this.nameInputTarget.value = "";
            this.nameInputTarget.addEventListener("keydown", this._blockEnter);
        }
        // in openModal()
        if (this.hasTypeInputTarget) {
            // lazily init TomSelect for the Type field just once
            if (!this.typeInputTarget.tomselect) {
                new TomSelect(this.typeInputTarget, {
                    create: false,
                    maxOptions: 1000,
                    searchField: ["text"],
                    sortField: { field: "text", direction: "asc" }
                });
            } else {
                // clear selection each time the modal opens
                this.typeInputTarget.tomselect.clear(true);
            }
        }
        const bs = window.bootstrap;
        if (bs) {
            new bs.Modal(this.modal).show();
        } else {
            this.modal.style.display = "block";
            }
}

        async createOrg() {
            if (!this.createUrlValue) {
                this.showModalError("Create URL is not set.");
                console.error("[org-select] Missing createUrlValue on controller element.");
                return;
            }
        const rawName = this.hasNameInputTarget ? this.nameInputTarget.value : "";
        const name = (rawName || "").trim().replace(/\s+/g, " ");
        if (!name) return this.showModalError("Please enter a name.");

        const type =
            this.hasTypeInputTarget
                ? (this.typeInputTarget.tomselect?.getValue() || this.typeInputTarget.value || "").toString().trim()
                : "";

        const token = document.querySelector("meta[name='csrf-token']")?.content;

        try {
            const res = await fetch(this.createUrlValue, {
                method: "POST",
                headers: { "Content-Type": "application/json", "X-CSRF-Token": token, "Accept": "application/json" },
                body: JSON.stringify({ organisation: { name, organisation_type: type } }) // ← include type
            });
            const data = await res.json();

            if (res.ok && data?.id) {
                this.ts.addOption({ value: String(data.id), text: data.name });
                this.ts.addItem(String(data.id), true);
                this.closeModal();
                this.showFormNotice(data.notice || "Organisation created.");
            } else if (res.status === 409 && data?.id) {
                this.ts.addOption({ value: String(data.id), text: data.name });
                this.ts.addItem(String(data.id), true);
                this.closeModal();
                this.showFormNotice(data.notice || "Organisation already exists. Selected it for you.");
            } else {
                this.showModalError((data?.errors || ["Could not create organisation."]).join(", "));
            }
        } catch {
            this.showModalError("Network error creating organisation.");
        }
    }



    closeModal() {
        const bs = window.bootstrap;
        if (bs) bs.Modal.getInstance(this.modal)?.hide(); else this.modal.style.display = "none";
        if (this.hasNameInputTarget) this.nameInputTarget.removeEventListener("keydown", this._blockEnter);
        this.clearModalError();
    }

    _blockEnter = (e) => {
        if (e.key === "Enter") { e.preventDefault(); this.createOrg(); }
    }

    showModalError(msg) {
        const el = document.getElementById(`${this.modalIdValue}-error`);
        if (el) { el.textContent = msg; el.classList.remove("d-none"); }
    }
    clearModalError() {
        const el = document.getElementById(`${this.modalIdValue}-error`);
        if (el) { el.textContent = ""; el.classList.add("d-none"); }
    }

    showFormNotice(msg) {
        const host = this.element;
        let n = host.querySelector(".org-select-notice");
        if (!n) {
            n = document.createElement("div");
            n.className = "alert alert-success py-1 px-2 mt-2 org-select-notice";
            host.appendChild(n);
        }
        n.textContent = msg;
        setTimeout(() => n?.remove(), 4000);
    }
}
