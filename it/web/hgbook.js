$(document).ready(function() {
  $("div.toc>p")
    .toggle(function() { $(this).nextAll().show("normal"); },
	    function() { $(this).nextAll().hide("normal"); })
    .hover(function() { $(this).fadeTo("normal", 0.8); },
	   function() { $(this).fadeTo("normal", 0.35); });
});
