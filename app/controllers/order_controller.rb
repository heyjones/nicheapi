class OrderController < ApplicationController

	skip_before_filter :verify_authenticity_token

	def create
logger.info 'SUCKSESS'
logger.info params
# 		order = ShopifyAPI::Order.find(params[:id])
# 		products = []
# 		order.line_items.each do |line_item|
# 			products.push([line_item.sku, line_item.quantity])
# 		end
# logger.info products
# 		var Person = new Object();
# 		Person.firstName = req.body.customer.first_name;
# 		Person.lastName = req.body.customer.last_name;
# 		Person.address = req.body.shipping_address.address1;
# 		Person.postcode = req.body.shipping_address.zip;
# 		Person.suburb = req.body.shipping_address.city;
# 		Person.state = req.body.shipping_address.province_code;
# 		Person.email = req.body.email;
# 		Person.phone = req.body.shipping_address.phone;
# 		Person.optInMailingList = req.body.buyer_accepts_marketing;
# 		Person.countryCodeISO3166_A2 = req.body.customer.country_code;
# 
# 		var Order = new Object();
# 		Order.products = Products;
# 		Order.person = Person;
# 		Order.refNo = req.body.id;
# 
# 		var data = JSON.stringify({order: Order});
# 		var headers = {
# 			'Content-Type': 'application/json',
# 			'Content-Length': data.length
# 		};
# 		var options = {
# 			host: 'dev8.nicheweb.com.au',
# 			port: 80,
# 			path: '/feed.asmx/CreateOrderTest',
# 			method: 'POST',
# 			headers: headers
# 		};
# 		var req = http.request(options, function(r){
# 			r.setEncoding('utf-8');
# 			r.on('data', function(data){
# 				orderNo = data;
# 			});
# 			r.on('end', function(){
# 				var Shopify = new shopifyAPI({
# 					shop: 'seedcms.myshopify.com',
# 					shopify_api_key: '89fa1ac4b082c6877427bd553b4f64a1',
# 					shopify_shared_secret: 'efced55c08389299d01b9fba89e6f303',
# 					access_token: 'f4eaa7a2a3da1a3c6d5d808b3737d0b1',
# 					verbose: false
# 				});
# 				var fulfillment = {
# 					'fulfillment': {
# 						'status': 'pending'
# 					}
# 				}
# 				Shopify.post('/admin/orders/'+req.body.id+'/fulfillments.json', fulfillment, function(err, data, headers){
# 				});
# 			});
# 		});
		format.json { render json: final_obj, status: :ok }
	end

	def fulfill
# 		var id = req.params.id;
# 		var post_data = {
# 			'fulfillment': {
# 				'tracking_number': '123456789',
# 				'notify_customer': false
# 			}
# 		}
# 		var Shopify = new shopifyAPI({
# 			shop: 'seedcms.myshopify.com',
# 			shopify_api_key: '89fa1ac4b082c6877427bd553b4f64a1',
# 			shopify_shared_secret: 'efced55c08389299d01b9fba89e6f303',
# 			access_token: 'f4eaa7a2a3da1a3c6d5d808b3737d0b1',
# 			verbose: false
# 		});
# 		Shopify.post('/admin/orders/'+id+'/fulfillments.json', post_data, function(err, data, headers){
# 		});
	end

	def cancel
	end

end