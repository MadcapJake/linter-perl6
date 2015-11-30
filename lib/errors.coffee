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


module.exports =
  Ats:
    simple: /^at ((?:\/[\w\-]+)*\.(?:p6|pl|pm6|pm|t)):(\d+)/
    used: /^\s*([\w\-]+) used at lines? (\d+(?:, \d+)*)/
  Errors: [
    {
      name: 'X::Syntax::Confused'
      re: /Two terms in a row.*/
      at_style: 'simple'
      build: (textEditor, filePath, re, lines, at_re) ->
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
              type: 'Error'
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
      build: (textEditor, filePath, re, lines, at_re) ->
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
              type: 'Error'
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
      build: (textEditor, filePath, re, lines, at_re) ->
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
            type: 'Error'
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
      build: (textEditor, filePath, re, lines, at_re) ->
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
              type: 'Error'
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
      build: (textEditor, filePath, re, lines, at_re) ->
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
              type: 'Error'
              text: message
              filePath: filePath
            }
          ]
        }
    }
    {
      name: 'X::Generic'
      re: /([^:]+)(:)?/
      at_style: 'simple'
      build: (textEditor, filePath, re, lines, at_re) ->
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
              type: 'Error'
              text: message
              filePath: filePath
            }
          ]
        }
    }
  ]
