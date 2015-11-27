remUnusedLines = (lines) ->
  nextLine = lines.shift()
  if nextLine.match(/^    /)
    remUnusedLines(lines)
  else if nextLine.match(/^$/)
    remUnusedLines(lines)
  else
    lines.unshift(nextLine)
    lines

module.exports =
  Ats:
    simple: /^at ((?:\/[\w\-]+)*\.(?:p6|pl|pm6|pm|t)):(\d+)/
    used: /^\s*([\w\-]+) used at lines? (\d+)/
  Errors: [
    {
      name: 'X::Undeclared'
      re: /[\S]+ '([\S]+)' is not declared/
      at_style: 'simple'
      build: (textEditor, filePath, re, lines, at_re) ->
        console.log  'X::Undeclared error'
        [message, variable, _] = lines.shift().match(re)
        console.log lines
        lines = remUnusedLines(lines)
        console.log lines
        [_, _, lineNum] = lines.shift().match(at_re)
        lines.shift()
        colstart = textEditor
          .lineTextForBufferRow(lineNum - 1)
          .indexOf(variable)
        colend = colstart + variable.length
        {
          lines: lines
          result:
            range: [
              [lineNum - 1, colstart],
              [lineNum - 1, colend  ]
            ]
            type: 'Error'
            text: message
            filePath: filePath
        }
    }
    {
      name: 'X::Undeclared::Routine'
      re: /(Undeclared routine):/
      at_style: 'used'
      build: (textEditor, filePath, re, lines, at_re) ->
        console.log 'X::Undeclared::Routine error'
        [_, message] = lines.shift().match(re)
        [_, symbol, lineNum] = lines.shift().match(at_re)
        colstart = textEditor
          .lineTextForBufferRow(lineNum - 1)
          .indexOf(symbol)
        colend = colstart + symbol.length
        {
          lines: lines
          result:
            range: [
              [lineNum - 1, colstart],
              [lineNum - 1, colend  ]
            ]
            type: 'Error'
            text: message
            filePath: filePath
        }
    }
    {
      name: 'X::Parameter::Twigil'
      re: /In signature parameter ([^,]+), it is illegal to use the (.) twigil/
      at_style: 'simple'
      build: (textEditor, filePath, re, lines, at_re) ->
        console.log 'X::Parameter::Twigil error'
        [message, variable, _] = lines.shift().match(re)
        [_, _, lineNum] = lines.shift().match(at_re)
        lines.shift()
        colstart = textEditor
          .lineTextForBufferRow(lineNum - 1)
          .indexOf(variable)
        colend = colstart + variable.length
        {
          lines: lines
          result:
            range: [
              [lineNum - 1, colstart],
              [lineNum - 1, colend  ]
            ]
            type: 'Error'
            text: message
            filePath: filePath
        }
    }
    {
      name: 'X::Generic'
      re: /([^:]+)(:)?/
      at_style: 'simple'
      build: (textEditor, filePath, re, lines, at_re) ->
        console.log 'X::Generic error'
        [_, message, colon] = lines.shift().match(re)
        [_, _, lineNum] = lines.shift().match(at_re)
        ar = /^------>\s\x1b\[32m([^\x1b]*)\x1b\[33m(\u23CF)\x1b\[31m([^\x1b]*)/
        [_, green, _, red] = lines.shift().match(ar)
        colstart = green.length - 1
        colend = colstart + red.length + 2
        {
          lines: lins
          result:
            range: [
              [lineNum - 1, colstart],
              [lineNum - 1, colend  ]
            ]
            type: 'Error'
            text: message
            filePath: filePath
        }
    }
  ]
