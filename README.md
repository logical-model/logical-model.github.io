# logical-model.github.io

The public documentation site for the
[`logical`](https://github.com/YukiAtsusaka/logical/tree/master) R package and
its model of minority representation.

## Usage content

The homepage fetches `README.md` from `YukiAtsusaka/logical` on the `master`
branch whenever a visitor opens or reloads the page. Marked renders it in the
browser, and DOMPurify sanitizes the rendered HTML. Both libraries are vendored
under `docs/vendor/`, with their versions and licenses included.

Edit and push the package README to update the homepage. The seven static
vignette tabs link to articles built from the package's
[`vignettes/`](https://github.com/YukiAtsusaka/logical/tree/master/vignettes)
directory. No website rebuild or redeployment is needed for README changes.

The loader in `docs/js/readme.js` strips YAML front matter, resolves image URLs
against the package's raw files, resolves relative document links against the
GitHub repository, and adds heading anchors. It preserves README content,
including source typos and badges; it does not execute R code.

The “On this page” panel is generated from README `##` and `###` headings. It
stays visible as a sidebar on wide screens and collapses on smaller screens.

Edit `docs/index.html` for styling and navigation. There is no generated
homepage, Python build step, or local image-copy step. JavaScript and access to
GitHub's raw-content host are required to display the README. A GitHub
documentation link remains available if loading fails or JavaScript is disabled.

## Preview

Serve `docs/` using a local HTTP server (do not open index.html as a file):

```sh
python -m http.server 8765 --bind 127.0.0.1 --directory docs
```

Open <http://127.0.0.1:8765/>.

## Publish

The site can be published directly from the default branch's `docs/` folder
with GitHub Pages. Alternatively, select **GitHub Actions** in **Settings >
Pages > Build and deployment > Source** to use the included **Publish
documentation** workflow. It uploads `docs/` without a build step on website
pushes to the default branch, or on a manual run.
