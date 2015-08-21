#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

pegjs -e visingo.parsers.answersettermsToVisjs $DIR/answersetterms-to-visjs.pegjs $DIR/answersetterms-to-visjs.js
pegjs -e visingo.parsers.solverTxtToJson $DIR/solver-txt-to-json.pegjs $DIR/solver-txt-to-json.js
