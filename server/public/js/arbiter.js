$(document).ready(function() {
	NProgress.configure({ showSpinner: false });
	
	var editor = ace.edit("editor");
	editor.setTheme("ace/theme/clouds");
	editor.getSession().setMode("ace/mode/python");
	editor.getSession().setUseWrapMode(!0);
	editor.setFontSize(14);

	editor.focus();
	editor.gotoLine(3);

	var language = 'python3';

	running = false;
	var runCode = function() {
		if (running) return;

		NProgress.start();
		running = true;

		$('#output-container').text('running code...');
		output = [];
		var params = JSON.stringify({
			language: language, 
			code: editor.getValue()
		});
		$.ajax({
			type: 'POST', 
			url: '/api/', 
			data: params, 
			dataType:'json', 
			success: function (data) {
				running = false;
				NProgress.done();
				console.log(data.contents[0].body);
				$('#output-container').text(data.contents[0].body);
			}, 
			error: function (data) {
				running = false;
				NProgress.done();
				$('#output-container').text("Code failed to execute!");
			}
		});
	}

	editor.commands.addCommand({
		name: 'runCode',
		bindKey: {
			win: 'Ctrl-Return',
			mac: 'Command-Return'
		},
		exec: runCode
	});

	$('#run').on('click', runCode);

	$(".toggle-python").on("click", function(a) {
		a.preventDefault();
		editor.getSession().setMode("ace/mode/python");
		language = 'python3';
		$(this).removeAttr("href");
		$(".toggle-scheme").attr("href", "#");
		$(".toggle-logic").attr("href", "#");
	});

	$(".toggle-scheme").on("click", function(a) {
		a.preventDefault();
		editor.getSession().setMode("ace/mode/scheme");
		language = 'scheme';
		$(this).removeAttr("href");
		$(".toggle-python").attr("href", "#");
		$(".toggle-logic").attr("href", "#");
	});

	$(".toggle-logic").on("click", function(a) {
		a.preventDefault();
		editor.getSession().setMode("ace/mode/scheme");
		language = 'logic';
		$(this).removeAttr("href");
		$(".toggle-python").attr("href", "#");
		$(".toggle-scheme").attr("href", "#");
	});
});