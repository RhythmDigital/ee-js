(function(){

	$(".section").each(function(id, el){
		$(this).css("top", "50px");
	});

	$(function(){
		if($(window).width() >= 768) {
			var stagger = 300;
			var time = 450;

			$(".section").each(function(id, el){
				setTimeout(function(){
					
					var next = $(this);
					next.css('display', 'block');
					next.animate({ opacity: 0 }, 0);
					$(this).animate({opacity:1, top: 0}, time);

				}.bind(this),stagger*id);
			});
		} else {
			// don't animate, just show!
			$(".section").each(function(id, el){
				$(this).css("top", "0px");
				$(this).show();
			});
		}
	});

})();