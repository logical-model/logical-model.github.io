/* The package README is the only source of the Usage content. */
(() => {
  "use strict";
  const rawBase = "https://raw.githubusercontent.com/YukiAtsusaka/logical/master/";
  const sourceBase = "https://github.com/YukiAtsusaka/logical/blob/master/";
  const content = document.getElementById("readme-content");
  const status = document.getElementById("readme-status");
  const fallback = document.getElementById("readme-fallback");

  async function loadReadme() {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 15000);
    try {
      if (!window.marked || !window.DOMPurify) {
        throw new Error("The Markdown renderer could not be loaded.");
      }
      const response = await fetch(new URL("README.md", rawBase), {
        signal: controller.signal,
        cache: "no-cache",
        credentials: "omit"
      });
      if (!response.ok) throw new Error(`GitHub returned HTTP ${response.status}.`);
      const markdown = (await response.text())
        .replace(/^\uFEFF/, "")
        .replace(/^---[^\S\r\n]*\r?\n[\s\S]*?\r?\n---[^\S\r\n]*(?:\r?\n|$)/, "");
      if (!markdown.trim()) throw new Error("The README is empty.");
      const fragment = DOMPurify.sanitize(marked.parse(markdown, { gfm: true }), {
        RETURN_DOM_FRAGMENT: true,
        USE_PROFILES: { html: true },
        FORBID_TAGS: ["style", "form", "input", "button"],
        FORBID_ATTR: ["srcset"]
      });
      // Both Markdown images and inline HTML images become img elements.
      for (const image of fragment.querySelectorAll("img[src]")) {
        image.setAttribute("src", new URL(image.getAttribute("src"), rawBase).href);
      }
      for (const link of fragment.querySelectorAll("a[href]")) {
        const href = link.getAttribute("href");
        if (!href.startsWith("#")) {
          link.setAttribute("href", new URL(href, sourceBase).href);
        }
      }
      // Give headings stable anchors for links within the README.
      const usedIds = new Set(Array.from(document.querySelectorAll("[id]"), node => node.id));
      for (const heading of fragment.querySelectorAll("h1, h2, h3, h4, h5, h6")) {
        const base = heading.id || heading.textContent.toLowerCase().trim()
          .replace(/[^\p{L}\p{N}_\-\s]/gu, "").replace(/\s/g, "-") || "section";
        let id = base;
        let suffix = 0;
        while (usedIds.has(id)) id = `${base}-${++suffix}`;
        heading.id = id;
        usedIds.add(id);
      }
      content.replaceChildren(fragment);
      status.hidden = true;
      fallback.hidden = true;
      if (location.hash) {
        try { document.getElementById(decodeURIComponent(location.hash.slice(1)))?.scrollIntoView(); }
        catch { /* An invalid fragment must not hide successfully loaded documentation. */ }
      }
    } catch (error) {
      status.textContent = "The README could not be loaded. Please reload the page or read it on GitHub below.";
      console.error("README loading failed:", error);
    } finally {
      clearTimeout(timeout);
      content.setAttribute("aria-busy", "false");
    }
  }
  loadReadme();
})();
