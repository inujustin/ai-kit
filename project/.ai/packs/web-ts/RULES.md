# Pack: web-ts (TypeScript / JavaScript web apps: React, Vue, Next, Nuxt)

[CI] = checked on changed files by `.ai/check_antipatterns.sh`.
- G-1 [CI] No secrets in code.
- FE-1 [CI] Colors, spacing and fonts come from tokens. No raw hex or rgb() outside the tokens/theme folder.
- FE-2 [CI] No dangerouslySetInnerHTML or v-html.
- FE-3 [CI] No console.log in src/. Use the logger.
- FE-4 [CI] No `any`. Type it or use `unknown` and narrow.
- Validate every external input (forms, API responses, URL params) with a schema at the boundary.
- Server state goes through the query cache. Global client state only for truly global things.
- Every page handles loading, empty and error states.
- Use the locked UI and data libraries of the project; never add another without asking.
