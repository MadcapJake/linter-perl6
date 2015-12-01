remUnusedLines = (lines) ->
  nextLine = lines.shift()
  if nextLine is undefined
    null
  else if nextLine.match(/^    /)
    remUnusedLines(lines)
  else if nextLine.match(/^$/)
    remUnusedLines(lines)
  else
    lines.unshift(nextLine)
    lines


gatherResults = (textEditor, filePath, lines, results, trace = false) ->
  found = false
  for error in errors
    console.log "Checking #{error.name}"
    if lines[0].match(error.re)
      {lines, results} = error.build(
        textEditor, filePath, lines,
        error.re, ats[error.at_style], trace
      )
      found = true
      break
  if not found
    linenum = textEditor.getLineCount()
    results = [
      {
        range: [
          [lineNum - 1, 1],
          [lineNum - 1, 1]
        ]
        type: if trace then 'Trace' else 'Error'
        text: 'Unknown Error'
        filePath: filePath
      }
    ]
  console.log results
  if lines?[0].match(/.+/)
    gatherResults(textEditor, filePath, lines, results, trace)
  else
    return results


ats =
  simple: /^\s*(?:in block)?\s*at ((?:\/[\w\-]+)*\.(?:p6|pl|pm6|pm|t)):(\d+)/
  used: /^\s*([\w\-]+) used at lines? (\d+(?:, \d+)*)/


errors = [
  {
    name: 'X::Comp::BeginTime'
    re: /An exception occurred while (.+)/
    at_style: 'simple'
    build: (textEditor, filePath, lines, re, at_re, trace) ->
      console.info 'X::Comp::BeginTime'
      [message, use_case] = lines.shift().match(re)
      [_, _, lineNum] = lines.shift().match(at_re)
      lines.shift() # Exception details:
      results = gatherResults(textEditor, filePath, lines, [], true)
      colend = textEditor.lineTextForBufferRow(lineNum - 1).length
      {
        lines: lines
        results: [
          {
            type: if trace then 'Trace' else 'Error'
            text: message
            filePath: filePath
            range: [
              [lineNum - 1, 0]
              [lineNum - 1, colend]
            ]
            trace: results
          }
        ]
      }
  }
  {
    name: 'X::Syntax::Confused'
    re: /Two terms in a row.*/
    at_style: 'simple'
    build: (textEditor, filePath, lines, re, at_re, trace) ->
      console.info 'X::Syntax::Confused'
      [message, _] = lines.shift().match(re)
      [_, _, lineNum] = lines.shift().match(at_re)
      ar = /^------>\s\x1b\[32m([^\x1b]*)\x1b\[33m(\u23CF)\x1b\[31m([^\x1b]*)/
      [_, green, _, red] = lines.shift().match(ar)
      lines = remUnusedLines(lines)
      cline = textEditor.lineTextForBufferRow(lineNum - 1)
      colstart = cline.match(/\S/).index
      colend = cline.length
      {
        lines: lines
        results: [
          {
            range: [
              [lineNum - 1, colstart],
              [lineNum - 1, colend  ]
            ]
            type: if trace then 'Trace' else 'Error'
            text: message
            filePath: filePath
          }
        ]
      }
  }
  {
    name: 'X::Undeclared'
    re: /[\S]+ '([\S]+)' is not declared/
    at_style: 'simple'
    build: (textEditor, filePath, lines, re, at_re, trace) ->
      console.info  'X::Undeclared'
      [message, variable, _] = lines.shift().match(re)
      lines = remUnusedLines(lines)
      [_, _, lineNum] = lines.shift().match(at_re)
      lines.shift()
      colstart = textEditor
        .lineTextForBufferRow(lineNum - 1)
        .indexOf(variable)
      colend = colstart + variable.length
      {
        lines: lines
        results: [
          {
            range: [
              [lineNum - 1, colstart],
              [lineNum - 1, colend  ]
            ]
            type: if trace then 'Trace' else 'Error'
            text: message
            filePath: filePath
          }
        ]
      }
  }
  {
    name: 'X::Undeclared::Routine'
    re: /(Undeclared routine):/
    at_style: 'used'
    build: (textEditor, filePath, lines, re, at_re, trace) ->
      [_, message] = lines.shift().match(re)
      [_, symbol, lineNums] = lines.shift().match(at_re)
      results = []
      for lineNum in (Number(sn) for sn in lineNums.split(", "))
        console.log "lineNum: #{lineNum}"
        colstart = textEditor
          .lineTextForBufferRow(lineNum - 1)
          .indexOf(symbol)
        colend = colstart + symbol.length
        results.push {
          range: [
            [lineNum - 1, colstart],
            [lineNum - 1, colend  ]
          ]
          type: if trace then 'Trace' else 'Error'
          text: message
          filePath: filePath
        }
      {
        lines: lines
        results: results
      }
  }
  {
    name: 'X::Parameter::Twigil'
    re: /In signature parameter ([^,]+), it is illegal to use the (.) twigil/
    at_style: 'simple'
    build: (textEditor, filePath, lines, re, at_re, trace) ->
      console.info 'X::Parameter::Twigil'
      [message, variable, _] = lines.shift().match(re)
      [_, _, lineNum] = lines.shift().match(at_re)
      lines.shift()
      colstart = textEditor
        .lineTextForBufferRow(lineNum - 1)
        .indexOf(variable)
      colend = colstart + variable.length
      {
        lines: lines
        results: [
          {
            range: [
              [lineNum - 1, colstart],
              [lineNum - 1, colend  ]
            ]
            type: if trace then 'Trace' else 'Error'
            text: message
            filePath: filePath
          }
        ]
      }
  }
  {
    name: 'X::Syntax::Missing'
    re: /Missing \w+/
    at_style: 'simple'
    build: (textEditor, filePath, lines, re, at_re, trace) ->
      console.info 'X::Syntax::Missing'
      [message, _] = lines.shift().match(re)
      [_, _, lineNum] = lines.shift().match(at_re)
      ar = /^------>\s\x1b\[32m([^\x1b]*)\x1b\[33m(\u23CF)\x1b\[31m([^\x1b]*)/
      [_, _, _, red] = lines.shift().match(ar)
      lines = remUnusedLines(lines)
      colstart = textEditor
        .lineTextForBufferRow(lineNum - 1)
        .indexOf(red)
      colend = textEditor
        .lineTextForBufferRow(lineNum - 1)
        .length
      {
        lines: lines
        results: [
          {
            range: [
              [lineNum - 1, colstart],
              [lineNum - 1, colend  ]
            ]
            type: if trace then 'Trace' else 'Error'
            text: message
            filePath: filePath
          }
        ]
      }
  }
  {
    name: 'X::Buf::AsStr'
    re: /Cannot use a Buf as a string, but you called the (\S+) method on it/
    at_style: 'simple'
    build: (textEditor, filePath, lines, re, at_re, trace) ->
      console.info 'X::Buf::AsStr'
      [message, method] = lines.shift().match(re)
      [_, _, lineNum] = lines.shift().match(at_re)
      colstart = textEditor.lineTextForBufferRow(lineNum - 1).indexOf(method)
      colend = colstart + method.length
      {
        lines: lines
        results: [
          {
            type: if trace then 'Trace' else 'Error'
            text: message
            range: [
              [lineNum - 1, colstart],
              [lineNum - 1, colend  ]
            ]
            filePath: filePath
          }
        ]
      }
  }
  {
    name: 'X::Buf::Pack'
    re: /Unrecognized directive '(\S+)'/
    at_style: 'simple'
    build: (textEditor, filePath, lines, re, at_re, trace) ->
      console.info 'X::Buf::Pack'
      [message, directive] = lines.shift().match(re)
      [_, _, lineNum] = lines.shift().match(at_re)
      colstart = textEditor.lineTextForBufferRow(lineNum - 1).indexOf(directive)
      colend = colstart + directive.length
      {
        lines: lines
        results: [
          {
            type: if trace then 'Trace' else 'Error'
            text: message
            range: [
              [lineNum - 1, colstart],
              [lineNum - 1, colend  ]
            ]
            filePath: filePath
          }
        ]
      }
  }
  {
    name: 'X::Buf::Pack::NonASCII'
    re: /non-ASCII character '(.)' while processing an '(.)' template in pack/
    at_style: 'simple'
    build: (textEditor, filePath, lines, re, at_re, trace) ->
      console.info 'X::Buf::Pack::NonASCII'
      [message, char, _] = lines.shift().match(re)
      [_, _, lineNum] = lines.shift().match(at_re)
      colstart = textEditor.lineTextForBufferRow(lineNum - 1).indexOf(char)
      colend = colstart + 1
      {
        lines: lines
        results: [
          {
            type: if trace then 'Trace' else 'Error'
            text: message
            range: [
              [lineNum - 1, colstart],
              [lineNum - 1, colend  ]
            ]
            filePath: filePath
          }
        ]
      }
  }
  {
    name: 'X::Attribute::Undeclared'
    re: /Attribute (\S+) not declared in class (\S+)/
    at_style: 'simple'
    build: (textEditor, filePath, lines, re, at_re, trace) ->
      console.info 'X::Attribute::Undeclared'
      [message, attr, cls] = lines.shift().match(re)
      [_, _, lineNum] = lines.shift().match(at_re)
      lines.shift()
      stepBack = 0
      console.log "lineNum: #{lineNum}"
      while true
        newLN = Number(lineNum) + --stepBack
        console.log "newLN: #{newLN}"
        l = textEditor.lineTextForBufferRow(newLN)
        pos = l.indexOf(attr)
        unless pos is -1
          lineNum  = newLN
          colstart = pos
          colend   = pos + attr.length
          break
      {
        lines: lines
        results: [
          {
            type: if trace then 'Trace' else 'Error'
            text: message
            range: [
              [lineNum, colstart],
              [lineNum, colend  ]
            ]
            filePath: filePath
          }
        ]
      }
  }
  {
    name: 'X::Generic'
    re: /([^:]+)(:)?/
    at_style: 'simple'
    build: (textEditor, filePath, lines, re, at_re, trace) ->
      console.info 'X::Generic'
      [_, message, colon] = lines.shift().match(re)
      [_, _, lineNum] = lines.shift().match(at_re)
      ar = /^------>\s\x1b\[32m([^\x1b]*)\x1b\[33m(\u23CF)\x1b\[31m([^\x1b]*)/
      [_, green, _, red] = lines.shift().match(ar)
      lines = remUnusedLines(lines)
      colstart = green.length - 1
      colend = colstart + red.length + 2
      {
        lines: lines
        results: [
          {
            range: [
              [lineNum - 1, colstart],
              [lineNum - 1, colend  ]
            ]
            type: if trace then 'Trace' else 'Error'
            text: message
            filePath: filePath
          }
        ]
      }
  }
]

module.exports =
  gatherResults: gatherResults
  Errors: errors
