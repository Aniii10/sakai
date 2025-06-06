import html from "eslint-plugin-html";
import lit from "eslint-plugin-lit";
import wc from "eslint-plugin-wc";
import globals from "globals";
import path from "node:path";
import { fileURLToPath } from "node:url";
import js from "@eslint/js";
import { FlatCompat } from "@eslint/eslintrc";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const compat = new FlatCompat({
  baseDirectory: __dirname,
  recommendedConfig: js.configs.recommended,
  allConfig: js.configs.all
});

export default [
  ...compat.extends("eslint:recommended", "plugin:wc/recommended", "plugin:lit/recommended"),
  {
    plugins: {
      html,
      lit,
      wc,
    },

    languageOptions: {
      globals: {
        ...globals.browser,
        $: "readonly",
        bootstrap: "readonly",
        sakai: "readonly",
        sakaiSessionId: "readonly",
        portal: "readonly",
        profile: "readonly",
        CKEDITOR: "readonly",
        moment: "readonly",
        confirmDatePlugin: "readonly",
        flatpickr: "readonly",
        jQuery: "readonly",
        MathJax: "readonly",
        globalThis: "readonly",
        describe: "readonly",
        it: "readonly",
        beforeEach: "readonly",
        afterEach: "readonly",
        before: "readonly",
        after: "readonly",
        expect: "readonly",
        sinon: "readonly",
      },

      ecmaVersion: 2022,
      sourceType: "module",
    },
    rules: {
      "accessor-pairs": "error",
      "array-bracket-spacing": [ "error", "always" ],
      "array-callback-return": "error",
      "arrow-parens": [ "error", "as-needed" ],
      "arrow-spacing": "error",
      "block-spacing": "error",
      camelcase: "error",
      "comma-spacing": "error",
      curly: [ "error", "multi-line" ],
      "dot-notation": "error",

      indent: [ "error", 2, {
        SwitchCase: 1,
        MemberExpression: "off",
        ImportDeclaration: "off",
        ignoredNodes: [ "TemplateLiteral > *" ],
      } ],

      "keyword-spacing": "error",
      "linebreak-style": 0,
      "no-array-constructor": "error",
      "no-caller": "error",
      "no-cond-assign": "error",
      "no-constructor-return": "error",
      "no-duplicate-imports": "error",
      "no-else-return": "error",

      "no-empty": [ "error", {
        allowEmptyCatch: true,
      } ],

      "no-eval": "error",

      "no-extend-native": [ "error", {
        exceptions: [ "Date" ],
      } ],

      "no-extra-bind": "error",
      "no-implied-eval": "error",
      "no-iterator": "error",
      "no-labels": "error",
      "no-lone-blocks": "error",
      "no-lonely-if": "error",
      "no-loop-func": "error",
      "no-loss-of-precision": "error",
      "no-multi-str": "error",
      "no-multiple-empty-lines": "error",
      "no-new-func": "error",
      "no-new-object": "error",
      "no-new-wrappers": "error",
      "no-octal-escape": "error",
      "no-param-reassign": "error",
      "no-proto": "error",
      "no-redeclare": "error",
      "no-return-await": "error",
      "no-script-url": "error",
      "no-self-compare": "error",
      "no-sequences": "error",

      "no-shadow": [ "error", {
        allow: [ "html" ],
      } ],

      "no-tabs": "error",
      "no-trailing-spaces": "error",
      "no-multi-spaces": "error",
      "no-undef": "error",
      "no-undef-init": "error",
      "no-unmodified-loop-condition": "error",

      "no-unneeded-ternary": [ "error", {
        defaultAssignment: false,
      } ],

      "no-unreachable-loop": "error",
      "no-unused-vars": [ "error" ],
      "no-use-before-define": [ "error", "nofunc" ],
      "no-useless-backreference": "error",
      "no-useless-call": "error",
      "no-useless-computed-key": "error",
      "no-useless-constructor": "error",
      "no-useless-escape": "error",
      "no-useless-rename": "error",
      "no-useless-return": "error",
      "no-var": "error",
      "object-curly-spacing": [ "error", "always" ],
      "object-shorthand": "error",
      "prefer-arrow-callback": "error",
      "prefer-const": "error",
      "prefer-exponentiation-operator": "error",
      "prefer-numeric-literals": "error",
      "prefer-object-spread": "error",
      "prefer-regex-literals": "error",
      "prefer-rest-params": "error",
      "prefer-spread": "error",
      quotes: [ "error", "double" ],
      "require-atomic-updates": "error",
      semi: [ "warn", "always" ],
      "space-infix-ops": "error",
      "space-before-blocks": "error",
      strict: "error",

      yoda: [ "error", "never", {
        onlyEquality: true,
      } ],
    },
  },
];
