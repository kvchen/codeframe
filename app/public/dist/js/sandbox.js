(function() {
  $(function() {
    var editor, language, runSnippet, running;
    NProgress.configure({
      showSpinner: false
    });
    editor = ace.edit("editor");
    editor.setTheme("ace/theme/clouds");
    editor.getSession().setMode("ace/mode/python");
    editor.getSession().setUseWrapMode(true);
    editor.setFontSize(14);
    editor.focus();
    editor.gotoLine(3);
    language = "python3";
    running = false;
    runSnippet = function() {
      var params;
      if (running) {
        return;
      }
      NProgress.start();
      running = true;
      $("#output-container").text("Running code snippet...");
      params = JSON.stringify({
        language: language,
        contents: editor.getValue()
      });
      return $.ajax({
        type: "POST",
        contentType: "application/json",
        url: "/snippet/run",
        dataType: "json",
        data: params,
        success: function(res) {
          var output;
          NProgress.done();
          output = res.data.output;
          if (output === "") {
            output += "\n\n";
          }
          if (res.data.timedOut) {
            output += "[Process timed out]\n";
          }
          if (res.data.truncated) {
            output += "[Output truncated]\n";
          }
          $('#output-container').text(output);
          return running = false;
        },
        error: function(res) {
          NProgress.done();
          console.log(res);
          $('#output-container').text("Unable to reach server!");
          return running = false;
        }
      });
    };
    editor.commands.addCommand({
      name: "runSnippet",
      exec: runSnippet,
      bindKey: {
        win: "Ctrl-Return",
        mac: "Command-Return"
      }
    });
    $('#run').on('click', runSnippet);
    $(".toggle-python").on("click", function(e) {
      e.preventDefault();
      $(".toggle-python").attr("href", "#");
      $(".toggle-scheme").attr("href", "#");
      $(".toggle-logic").attr("href", "#");
      $(".toggle-hog").attr("href", "#");
      editor.getSession().setMode("ace/mode/python");
      language = "python3";
      return $(this).removeAttr("href");
    });
    $(".toggle-scheme").on("click", function(e) {
      e.preventDefault();
      $(".toggle-python").attr("href", "#");
      $(".toggle-scheme").attr("href", "#");
      $(".toggle-logic").attr("href", "#");
      $(".toggle-hog").attr("href", "#");
      editor.getSession().setMode("ace/mode/scheme");
      language = "scheme";
      return $(this).removeAttr("href");
    });
    $(".toggle-logic").on("click", function(e) {
      e.preventDefault();
      $(".toggle-python").attr("href", "#");
      $(".toggle-scheme").attr("href", "#");
      $(".toggle-logic").attr("href", "#");
      $(".toggle-hog").attr("href", "#");
      editor.getSession().setMode("ace/mode/scheme");
      language = "logic";
      return $(this).removeAttr("href");
    });
    return $(".toggle-hog").on("click", function(e) {
      e.preventDefault();
      $(".toggle-python").attr("href", "#");
      $(".toggle-scheme").attr("href", "#");
      $(".toggle-logic").attr("href", "#");
      $(".toggle-hog").attr("href", "#");
      editor.getSession().setMode("ace/mode/python");
      language = "hog";
      return $(this).removeAttr("href");
    });
  });

}).call(this);
