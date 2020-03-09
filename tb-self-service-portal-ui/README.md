# Tranquility Base Self Service Portal UI

You need [Node.js](https://nodejs.org) version >= 10 (One might find [nvm](https://github.com/nvm-sh/nvm) useful for CI use). To make sure packages are installed after getting the code, run `npm install` from the project's root directory.

This project was generated with [Angular CLI](https://github.com/angular/angular-cli) version 7.3.9. Once you have node installed just run `npm install -g @angular/cli` to make it globally available in the PATH. In case you need to have a local-only copy, just run `npm install @angular/cli` from the project's root directory (without the `-g` flag), then the ng executable will be available in `./node_modules/.bin/ng`.

The UI components are based on [Bootstrap CSS framework](https://getbootstrap.com/docs/4.3) version 4.3, using widget code for Angular from [ng-bootstrap](https://ng-bootstrap.github.io).

## Development server

Run `npm start` for a dev server. Navigate to `http://localhost:4200/`. The app will automatically reload if you change any of the source files.

## Fake API

Run `npm run api` in order to launch fake API. This is useful in development mode.

## Code scaffolding

Run `ng generate component component-name` to generate a new component. You can also use `ng generate directive|pipe|service|class|guard|interface|enum|module`.

## Build

Run `npm run build` to build the project. The build artifacts will be stored in the `dist/` directory. Use the `npm run build:prod` for a production build.

## Running unit tests

Run `ng test` to execute the unit tests via [Karma](https://karma-runner.github.io).

## Running end-to-end tests

Run `ng e2e` to execute the end-to-end tests via [Protractor](http://www.protractortest.org/).

## Further help

To get more help on the Angular CLI use `ng help` or go check out the [Angular CLI README](https://github.com/angular/angular-cli/blob/master/README.md).
