// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require_tree .

$(document).ready(function(){
	$('#import').click(function(){
		$.post('/shopify/import', function(data){
			console.log(data);
		});
	});
	$('#order').click(function(){
		$.post('/shopify/order', function(data){
			console.log(data);
		});
	});
	$('#orders').click(function(){
		$.post('/shopify/orders', function(data){
			console.log(data);
		});
	});
});