# coffeelint: disable=max_line_length

{BufferedProcess, CompositeDisposable} = require 'atom'
path = require 'path'
X = require './errors.coffee'

module.exports = LinterPerl6 =
  config:
    perl6dir:
      default: ""
      type: 'string'
      title: 'Path to directory containing perl6'
  subscriptions: null

  activate: (state) ->
    console.log 'linter-perl6 loaded.'

    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.config.observe 'linter-perl6.perl6dir',
      (perl6dir) => @perl6dir = perl6dir

  deactivate: ->
    @subscriptions.dispose()

  provideLinter: ->
    p6cmd = if @perl6dir? then path.join(@perl6dir, 'perl6') else 'perl6'
    provider =
      grammarScopes: ['source.perl6fe', 'source.perl6']
      scope: 'file'
      lintOnFly: false
      lint: (textEditor) ->
        return new Promise (resolve, reject) ->
          filePath = textEditor.getPath()
          results = []
          process = new BufferedProcess
            command: p6cmd
            args: ['--setting=RESTRICTED', '-c', filePath]
            stderr: (output) ->
              console.info 'stderr was printed to:'
              console.info output
              lines = output.split('\n')
              lines.shift() # remove initial error line
              results = X.gatherResults(textEditor, filePath, lines, results)
            exit: (code) ->
              return resolve [] if code is 0
              return resolve [] unless results?
              resolve results
          process.onWillThrowError ({error, handle}) ->
            atom.notifications.addError 'Failed to run Perl6 syntax-check mode',
              detail: 'Directory containing perl6 is set to ' +
                atom.config.get("linter-perl6.perl6dir")
              dismissable: true
            handle()
            resolve []
