# Visingo-Web

This is the self-contained Web-UI of Visingo <https://github.com/vukk/visingo>.

The Web-UI is capable of playback visualization by itself.
A live instance is available at <http://users.ics.aalto.fi/kuuranne/visingo-web/>
(possibly not the latest version).

## Installing

Visingo-Web is a fully client-side application. This is achieved by utilizing
WebComponents (Polymer) and JavaScript.

Currently the requirements for installing and serving Visingo-Web are
- A web server capable of serving files
- [bower](http://bower.io/)
- [PEG.js](http://pegjs.org/)

To install Visingo-Web
- Clone the git repository
- Run `bower update` to fetch the web components
- Run `elements/visingo-parsers/gen.sh` to generate the required parsers
- Serve the directory with some web server

For local hosting and developing, `python -m SimpleHTTPServer 8888` might be
useful. This command serves the current working directory on localhost port 8888.
Of course Python must be installed the command above.

## Visualizing answer sets

See the "Getting started" section of the [help](http://users.ics.aalto.fi/kuuranne/visingo-web/help.html).
