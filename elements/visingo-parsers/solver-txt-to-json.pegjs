/*
 * peg.js potassco solver default text to json parser
 * TODO: cleanup by using $str, add E* to all the things... (even after \n maybe)
 */

/* initializer */

{
  function makeInteger(o) {
    return parseInt(o.join(""), 10);
  }

  function extractList(list, index) {
    var result = [], i;

    for (i = 0; i < list.length; i++) {
      if (list[i][index] !== null) {
        result.push(list[i][index]);
      }
    }

    return result;
  }

  function buildList(first, rest, index) {
    return (first !== null ? [first] : []).concat(extractList(rest, index));
  }
}


// skip until we see line starting with clingo or clasp version
start
  = (!(("clasp" / "clingo") " version") anylinenl)*
    implemented:implemented
    anylinenl* anyline?
  { return implemented; }

anyline
  = [^\r\n]*

anylinenl
  = anyline Nl

/* start, return json */

//start
implemented
  = sl:solververline il:inputline calls:calls result:resultline
    modelsmeta:modelsmeta numcalls:callsmeta timemeta:timemeta
  {
    var m = {
      Solver: sl,
      Input: il
    };
    // clingo will say there is one call if there are none TODO: fix if fixed upstream in clingo
    m['Call'] = (calls.length === 0) ? [{}] : calls;
    m['Result'] = result;
    m['Models'] = modelsmeta;
    m['Calls'] = numcalls;
    m['Time'] = timemeta;
    return m;
  }


/* solver version */

solververline
  = solver:("clingo" / "clasp") txt:" version " ver:[a-z0-9\._\-\(\)\t $:]i+ Nl
  { return solver + txt + ver.join(''); }

/* input  */

// TODO: clasp and clingo should output all files used instead of ...
//       also filenames should be in quotes, otherwise files can't be recognized
//       without using stat on the filesystem, and we can't really do that from
//       the parser reliably
inputline
  = "Reading from " fp:filepath " ..."? Nl { return [fp]; }


/* result */

resultline
  = result:result Nl Nl { return result; }

result
  = "SATISFIABLE" / "UNSATISFIABLE" / "UNKNOWN" / "OPTIMUM FOUND"


/* meta info */

modelsmeta
  = "Models" E* ":" E* num:posinteger more:"+"? E* Nl
    opt:metaoptimumlinenl?
    costs:metaoptimizationlinenl?
  {
    var m = {
      Number: num,
      More: (more === null) ? "no" : "yes"
    };
    if(opt !== null) { m['Optimum'] = opt; m['Optimal'] = 1; } // TODO fix 'Optimal'
    if(opt !== null) m['Costs'] = costs;
    return m;
  }


metaoptimumlinenl "result optimum yes/no line"
  = E* "Optimum" E* ":" E* opt:("yes" / "no") Nl
  { return opt; }

metaoptimizationlinenl "models result optimization line"
  = "Optimization" E* ":" E* first:integer rest:(" " integer)* Nl
  { return buildList(first, rest, 1) }


callsmeta "final amount of calls"
  = "Calls" E* ":" E* num:posinteger Nl { return num; }

timemeta
  = "Time" E* ":" E* total:timedecimal "s" E+ "(" E* "Solving:" E+ solving:timedecimal "s" E+
    "1st Model:" E+ model:timedecimal "s" E+ "Unsat:" E+ unsat:timedecimal "s" E* ")" Nl
    "CPU Time" E* ":" E* cpu:timedecimal "s" Nl?
  {
    return {
      Total: total,
      Solve: solving,
      Model: model,
      Unsat: unsat,
      CPU: cpu
    }
  }


/* multiple (solver) calls */

calls
  = call*

/* single (solver) call */

// "Solving..." then answer sets (models)
call
  = solvingtextnl models:(model*) { return { Witnesses: models }; }

solvingtextnl "Solving..."
  = "Solving..." Nl

/* single model */

model
  = anl:answernumline Nl al:answersetline Nl ol:optimizationlinenl?
  {
    var m = {};
    m['Value'] = al;
    if(ol !== null) m['Costs'] = ol;
    return m;
  }

/* optimization line */

optimizationlinenl "answer optimization line"
  = ol:optimizationline Nl { return ol; }

optimizationline
  = "Optimization: " first:integer rest:(" " integer)*
  { return buildList(first, rest, 1) }

/* answer number line */
answernumline "answer number line"
  = "Answer: " num:posinteger { return num; }
/* a line of predicates, separated by spaces */

answersetline
  = E* first:term? rest:(E+ term)* E*
  { return buildList(first, rest, 1); }

term // tuple is not allowed
  = predicate
  / atom:booleanAtom
  / atom:predicateIdent
  / string:aspstring
  / num:number

/* a single predicate */

predicate "predicate"
  = $(predicateIdent "(" arguments ")")

// must have at least 1 argument (no empty predicates or tuples)
//arguments
//  = first:argument rest:("," S* argument)*
//    { return buildList(first, rest, 1) }

arguments
  = first:argument rest:("," E* argument)*
  {
    return buildList(first, rest, 2);
  }


argument
  = predicate
  / atom:booleanAtom
  / atom:predicateIdent
  / tuple:anontuple
  / string:aspstring
  / num:number


/* tuples */

anontuple
  = "(" E* first:argument rest:("," E* argument)* E* ")"
  {
    return buildList(first, rest, 2);
  }

/* Booleans */
booleanAtom
  = "true" { return true; }
  / "false" { return false; }

/* ASP strings */

aspstring "double quoted string"
  = "\"" str:string "\"" { return str; }

/* numbers */

posinteger "positive integer"
  = digits:[0-9]+ { return makeInteger(digits); }

integer "integer"
  = sign:"-"? digits:([0-9]+) { var d = makeInteger(digits); return (sign === '-') ? -d : d }

timedecimal "positive decimal number"
  = float:$(characteristic:[0-9]+ "." decimal:[0-9]+)
  { return parseFloat(float); }

decimal "decimal"
  = sign:"-"? float:$(characteristic:[0-9]+ "." decimal:[0-9]+)
  {
    var f = parseFloat(float);
    return (sign === '-') ? -f : f;
  }

number "number"
  = decimal
  / integer


/* characters & strings */

// a string, starts with " and ends with "
string "string"
  = str:(stringchar+) { return str.join("") }
//  = str:([^\"\r\n\f]+) { return str.join("") }

stringchar
  = "\\\""
  / [^"]

// prefix allows default negation e.g. '-predicate(X,Y)'
predicateIdent "predicate identifier"
  = prefix:$"-"? start:predicateIdentStart chars:predicateIdentChar* {
      return prefix + start + chars.join("");
    }

// allow "_" on the start of idents, since heuristic predicates might be present in the output
predicateIdentStart
  = [_a-z]i
  / nonascii

predicateIdentChar
  = [_a-z0-9-]i
  / nonascii

nonascii
  = [\x80-\uFFFF]

Nl
  = "\r"? "\n"

E "tab or space"
  = [ \t]

S "whitespace"
  = [ \t\r\n\f]

/* file or other input */

filepath "file path"
  = $([A-Za-z0-9\-_\.\\\/]+)
