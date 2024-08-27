import { html } from "lit";
import "../sakai-rubric-readonly.js";
import { SakaiRubricsHelpers } from "./SakaiRubricsHelpers.js";
import { SakaiRubricsList } from "./SakaiRubricsList.js";

const rubricName = "name";
const rubricTitle = "title";
const rubricCreator = "creator";
const rubricModified = "modified";

export class SakaiRubricsSharedList extends SakaiRubricsList {

  rubricIdToDelete = null;
  rubricTitleToDelete = null;

  static properties = {

    siteId: { attribute: "site-id", type: String },
    enablePdfExport: { attribute: "enable-pdf-export", type: Boolean },

    _rubrics: { state: true },
  };

  constructor() {

    super();

    this.getSharedRubrics();
  }

  shouldUpdate() {
    return this._rubrics;
  }

  render() {

    return html`
      <div role="tablist">
      ${this._rubrics.map(r => html`
        <sakai-rubric-readonly .rubric=${r}
        @copy-to-site=${this.copyToSite}
        @delete-rubric=${this.showDeleteModal}
        @delete-shared-rubric=${this.rubricUnshared}
        ?enablePdfExport=${this.enablePdfExport}>
        </sakai-rubric-readonly>
      `)}
      </div>
      <!-- Modal de Confirmación -->
      <div class="modal fade" id="delete-modal" tabindex="-1" aria-labelledby="delete-modal-label" aria-hidden="true">
        <div class="modal-dialog">
          <div class="modal-content">
            <div class="modal-header">
              <h5 class="modal-title" id="delete-modal-label">${this._i18n.delete_item_title.replace("{}", this.rubricTitleToDelete || "")}</h5>
              <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
              <p>${this._i18n.confirm_remove.replace("{}", this.rubricTitleToDelete || "")}</p>
            </div>
            <div class="modal-footer">
              <button type="button" class="btn btn-danger" @click="${this.confirmDelete}">${this._i18n.remove_label}</button>
              <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">${this._i18n.cancel}</button>
            </div>
          </div>
        </div>
      </div>
    `;
  }

  refresh() {
    this.getSharedRubrics();
  }

  refreshPage() {
    window.location.reload();
  }

  getSharedRubrics() {

    const url = "/api/rubrics/shared";
    fetch(url, { credentials: "include" })
    .then(r => {

      if (r.ok) {
        return r.json();
      }
      throw new Error("Network error while getting shared rubrics");
    })
    .then(rubrics => this._rubrics = rubrics)
    .catch (error => console.error(error));
  }

  showDeleteModal(e) {
    e.stopPropagation();
    this.rubricIdToDelete = e.detail.id;
    this.rubricTitleToDelete = e.detail.title;
    this.requestUpdate();
    const modal = new bootstrap.Modal(document.getElementById("delete-modal"));
    modal.show();
  }

  copyToSite(e) {

    SakaiRubricsHelpers.get(`/api/sites/${this.siteId}/rubrics/${e.detail}/copyToSite`, {})
      .then(() => this.dispatchEvent(new CustomEvent("copy-share-site")));
  }

  confirmDelete(e) {
    e.stopPropagation();
    const url = `/api/rubrics/shared/${this.rubricIdToDelete}`;
    fetch(url, {
      method: "DELETE",
      credentials: "include",
      headers: { "Content-Type": "application/json" }
    })
    .then(r => {
      if (!r.ok) {
        throw new Error(`Failed to delete shared rubric with id ${this.rubricIdToDelete}`);
      }
      this._rubrics = this._rubrics.filter(rubric => rubric.id !== this.rubricIdToDelete);
      this.requestUpdate();
      this.refreshPage();
      const modal = bootstrap.Modal.getInstance(document.getElementById("delete-modal"));
      modal.hide();
    })
    .catch(error => console.error(error));
  }

  rubricUnshared(e) {
    e.stopPropagation();
    this.rubricIdToDelete = e.detail.id;


    const data = { "published": false };

    fetch(`/api/rubrics/published/${this.rubricIdToDelete}`, {
      method: "POST",
      credentials: "include",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(data)
    })
   .then(response => {
     if (!response.ok) {
       throw new Error("Error en la solicitud:" + response.statusText);
     }
     return response.json();
   })
     .then(() => this.refreshPage())
     .catch(error => console.error("Error en la solicitud:", error));
  }

  sortRubrics(rubricType, ascending) {

    switch (rubricType) {
      case rubricName:
        this._rubrics.sort((a, b) => ascending ? a.title.localeCompare(b.title) : b.title.localeCompare(a.title));
        break;
      case rubricTitle:
        this._rubrics.sort((a, b) => ascending ? a.siteTitle.localeCompare(b.siteTitle) : b.siteTitle.localeCompare(a.siteTitle));
        break;
      case rubricCreator:
        this._rubrics.sort((a, b) => ascending ? a.creatorDisplayName.localeCompare(b.creatorDisplayName) : b.creatorDisplayName.localeCompare(a.creatorDisplayName));
        break;
      case rubricModified:
        this._rubrics.sort((a, b) => ascending ? a.modified - b.modified : b.modified - a.modified);
    }
    this.requestUpdate("_rubrics");
  }
}
