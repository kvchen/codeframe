$ ->
  NProgress.configure
    showSpinner: false

  # Set editor settings
  editor = ace.edit "editor"
  editor.setTheme "ace/theme/clouds"
  editor.getSession().setMode "ace/mode/python"
  editor.getSession().setUseWrapMode true
  editor.setFontSize 14

  editor.focus()
  editor.gotoLine 3

  # Set initial runtime settings
  language = "python3"
  running = false

  runSnippet = () ->
    return if running

    NProgress.start()
    running = true

    $("#output-container").text "Running code snippet..."
    params = JSON.stringify
      language: language
      entrypoint: "snippet"
      files: [{
        name: "snippet"
        contents: editor.getValue()
      }]

    $.ajax
      type: "POST"
      contentType: "application/json"
      url: "/api/environment/run"
      dataType:'json'
      data: params
      success: (res) ->
        NProgress.done()
        console.log "finished:"
        console.log res
        $('#output-container').text res.data.output
        running = false
      error: (res) ->
        NProgress.done()
        $('#output-container').text "Code failed to execute!"
        running = false

  editor.commands.addCommand
    name: "runSnippet"
    exec: runSnippet
    bindKey:
      win: "Ctrl-Return"
      mac: "Command-Return"

  $('#run').on 'click', runSnippet

  $(".toggle-python").on "click", (e) ->
    e.preventDefault()
    editor.getSession().setMode "ace/mode/python"
    language = "python3";
    $(this).removeAttr "href"
    $(".toggle-scheme").attr "href", "#"
    $(".toggle-logic").attr "href", "#"

  $(".toggle-scheme").on "click", (e) ->
    e.preventDefault();
    editor.getSession().setMode "ace/mode/scheme"
    language = "scheme"
    $(this).removeAttr "href"
    $(".toggle-python").attr "href", "#"
    $(".toggle-logic").attr "href", "#"

  $(".toggle-logic").on "click", (e) ->
    e.preventDefault();
    editor.getSession().setMode "ace/mode/scheme"
    language = "logic"
    $(this).removeAttr "href"
    $(".toggle-python").attr "href", "#"
    $(".toggle-scheme").attr "href", "#"


