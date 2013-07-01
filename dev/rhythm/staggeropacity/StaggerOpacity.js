(function(){

	// $(".section").each(function(id, el){
	// $(this).hide();
	// });

	$(function(){
		var stagger = 100;
		var time = 500;

		$(".section").each(function(id, el){
			setTimeout(function(){
				$(this).fadeIn(500);
			}.bind(this),stagger*id);
		});
	});

})();