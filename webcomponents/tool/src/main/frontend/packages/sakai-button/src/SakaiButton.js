import { SakaiShadowElement } from "@sakai-ui/sakai-element";
import { css, html } from "lit";
import { ifDefined } from "lit/directives/if-defined.js";

export class SakaiButton extends SakaiShadowElement {

  static properties = {

    primary: { type: Boolean },
    type: { type: String },
    href: { type: String },
  };

  clicked() {

    if (this.href) {
      window.parent.location = this.href;
    }
  }

  focus() {
    this.shadowRoot.querySelector("button").focus();
  }

  render() {

    return html`
      <button
        class="${this.primary ? "primary" : ""} ${this.type ? this.type : ""}"
        @click=${this.clicked}
        title="${ifDefined(this.title)}"
      >
        <slot>
        </slot>
      </button>
    `;
  }

  static styles = css`
    button {
      text-align: center;
      padding: var(--sui-btn-padding);
      border: 1px solid var(--button-border-color);
      border-radius: var(--sui-btn-border-radius);
      background: var(--button-background);
      font-family: var(--sui-btn-font-family);
      font-size: var(--default-font-size);
      font-weight: var(--sui-btn-font-weight);
      line-height: var(--sui-btn-line-height);
      color: var(--button-text-color);
      text-decoration: none;
      text-transform: none;
      cursor: pointer;
      -moz-appearance: none;
      -webkit-appearance: none;
      box-shadow: var(--button-shadow);
    }
    button:hover,
    button:focus {
      color: var(--button-hover-text-color);
      text-decoration: none;
      background: var(--button-hover-background);
      border-color: var(--button-hover-border-color);
      box-shadow: var(--button-hover-shadow);
    }
    button:focus {
      outline: none;
      box-shadow: 0px 0px 0px 3px var(--focus-outline-color);
    }
    button:active {
      outline: 0;
      color: var(--button-active-text-color);
      text-decoration: none;
      background: var(--button-active-background);
      border-color: var(--button-active-border-color);
      box-shadow: var(--button-active-shadow);
    }
    .primary {
      background-color: var(--button-primary-background, #0f4b6f);
      color: var(--primary-text-color, #FFFFFF);
      border: 1px solid var(--button-primary-border-color);
      background: var(--button-primary-background);
      font-weight: 600;
      color: var(--button-primary-text-color);
      text-decoration: none;
      text-transform: none;
      cursor: pointer;
      box-shadow: var(--button-primary-shadow);
    }
    .primary:hover,
    .primary:focus {
      color: var(--button-primary-hover-text-color);
      text-decoration: none;
      background: var(--button-primary-hover-background);
      border-color: var(--button-primary-hover-border-color);
      box-shadow: var(--button-primary-hover-shadow);
    }
    .primary:focus {
      outline: none;
      box-shadow: 0px 0px 0px 3px var(--focus-outline-color);
    }
    .primary:active {
      outline: 0;
      color: var(--button-primary-active-text-color);
      text-decoration: none;
      background: var(--button-primary-active-background);
      border-color: var(--button-primary-active-border-color);
      box-shadow: var(--button-primary-active-shadow);
    }
    .small {
      border-radius: var(--sakai-small-button-border-radius, 4px);
      padding: var(--sakai-small-button-padding, 2px);
    }
  `;
}
