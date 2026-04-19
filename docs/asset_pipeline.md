# Asset Pipeline Setup

## Context

* Timeline: December 2024
* Version: Rails 8.x

## References

* [Adventures with Propshaft - 2023/09/15](https://josegomezr.github.io/blog/programming/rails/2023/09/15/adventures-with-propshaft)
* [How to use ESBuild to load font files for Bootstrap Icons - 2022/11/14](https://www.youtube.com/watch?v=DhM-Wh9Pmd4)
* [Rails Discussion](https://discuss.rubyonrails.org)
* [Hotwire Discussion](https://discuss.hotwired.dev)

## Debugging

* `rails assets:reveal` on local, produces a full list of logical paths
* `rails assets:precompile` on local, compiles assets into `public/assets` directory, Propshaft will use the static resolver (local changes ignored)
* `rails assets:clean` on local, remove older compiled assets
* `rails assets:clobber` on local, removes all files from `public/assets` and forces Propshaft back to the dynamic resolver (local changes acknowledged)

## Notes

```
Propshaft has two ways of finding your assets (called resolvers). When you are developing and running ./bin/dev you are using the dynamic resolver, which looks for your files in app/assets.

When you deploy to your server you will run rails assets:precompile before restarting puma. This tells Propshaft to move all files from app/assets to public/assets and add digests to them so that CDNs can cache them properly. From that moment on, you are using the static resolver, which is much faster. 
```

### Replacing UJS with Turbo for Button Link Methods

```
https://turbo.hotwired.dev/reference/attributes

data-turbo-method changes the link request type from the default GET. Ideally, non-GET requests should be triggered with forms, but data-turbo-method might be useful where a form is not possible.
```

## Approach

* Use [hotwire](https://hotwired.dev), [turbo](https://turbo.hotwired.dev), and [stimulus](https://stimulus.hotwired.dev) for frontend js 
* Uses `yarn 4+` for package management
* Uses the following gems:
  - [cssbundling-rails](https://github.com/rails/cssbundling-rails)
  - [jsbundling-rails](https://github.com/rails/jsbundling-rails)
  - [propshaft](https://github.com/rails/propshaft)
  - [stimulus-rails](https://rubygems.org/gems/stimulus-rails)
  - [turbo-rails](https://rubygems.org/gems/turbo-rails)
* Uses the following packages:
  - [@hotwired/stimulus](https://www.npmjs.com/package/@hotwired/stimulus)
  - [@hotwired/turbo-rails](https://www.npmjs.com/package/@hotwired/turbo-rails)
  - [boostrap-icons](https://www.npmjs.com/package/bootstrap-icons)
  - [bootstrap](https://www.npmjs.com/package/bootstrap)
  - [esbuild](https://esbuild.github.io/)
  - [sass](https://www.npmjs.com/package/sass)
* Creates a single javascript file and a single css file for the admin part of the site
* Creates a single javascript file and a single css file for the public part of the site
* Uses separate stimulus controllers for admin and public sites

## Yarn Config

Add to `.yarnrc.yml` at root:

```yaml
nodeLinker: node-modules
yarnPath: .yarn/releases/yarn-4.5.3.cjs
```

## Install Gems

```ruby
gem "cssbundling-rails"
gem "jsbundling-rails"
gem "propshaft"
gem "stimulus-rails"
gem "turbo-rails"
```

## Install Node Packages

```bash
yarn add @hotwired/stimulus @hotwired/turbo-rails bootstrap bootstrap-icons esbuild sass
```

## Add esbuild Config

Add to `esbuild.config.js` at root:

```javascript
const path = require('path')
const esbuild = require('esbuild')

// Admin bundle
esbuild.build({
  entryPoints: ['app/javascript/admin/index.js'],
  bundle: true,
  outfile: 'app/assets/builds/admin.js',
  plugins: [],
  watch: process.argv.includes("--watch")
}).catch(() => process.exit(1))

// Public bundle
esbuild.build({
  entryPoints: ['app/javascript/public/index.js'],
  bundle: true,
  outfile: 'app/assets/builds/public.js',
  plugins: [],
  watch: process.argv.includes("--watch")
}).catch(() => process.exit(1))
```

## Rails App Config

Update `config/initializers/assets.rb` to include assets from packages:

```ruby
Rails.application.config.assets.paths << Rails.root.join('node_modules/bootstrap-icons/font')
```

## JavaScript Config

Folder structure for `app/javascript` directory:

```
--app
  --javascript
    --admin
      --controllers
        - hello_controller.js
        - index.js
      - index.js
    --controllers
      - application.js
    --public
      --controllers
        - yo_controller.js
        - index.js
      - index.js
```

## CSS Config

File structure:

```
--app
  --assets
    --stylesheets
      - admin.scss
      - public.scss
```

Add to `admin.scss` and `public.scss` files:

```scss
@use "bootstrap/scss/bootstrap";
@use "bootstrap-icons/font/bootstrap-icons";

$bootstrap-icons-font-src: url("bootstrap-icons.woff2") format("woff2"), url("fonts/bootstrap-icons.woff") format("woff") !default;

// Your theme-specific styles here
```

## View Config

For admin layout `app/views/layouts/admin.html.erb`:

```ruby
<%= javascript_include_tag "admin", defer: true %>
<%= stylesheet_link_tag "admin" %>
```

For public layout `app/views/layouts/application.html.erb`:

```ruby
<%= javascript_include_tag "public", defer: true %>
<%= stylesheet_link_tag "public" %>
```

## Node Scripts

Add to `package.json` at root:

```json
  "scripts": {
    "build": "node esbuild.config.js",
    "build:css": "node node_modules/sass/sass.js ./app/assets/stylesheets/admin.scss:./app/assets/builds/admin.css ./app/assets/stylesheets/public.scss:./app/assets/builds/public.css --no-source-map --load-path=node_modules --style=compressed",
    "watch": "node esbuild.config.js --watch",
    "watch:css": "sass --watch ./app/assets/stylesheets/admin.scss:./app/assets/builds/admin.css ./app/assets/stylesheets/public.scss:./app/assets/builds/public.css --no-source-map --load-path=node_modules"
  },
  ```

## Foreman Config

Add to `Procfile.dev.frontend` at root:

```bash
js: yarn build --watch
css: yarn build:css --watch
```

## CI Config

Add to `.github/workflows/ci.yml`:

```yaml
  - name: Setup database
    run: bin/rails db:create db:schema:load

  - name: Build assets
    run: |
      yarn build
      yarn build:css
```
