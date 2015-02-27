class Niche
	extend Savon::Model
	client wsdl: 'http://27.111.85.141/feed.asmx?wsdl',
#	log: true,
#	log_level: :debug,
	convert_request_keys_to: :none,
	pretty_print_xml: true
	def self.login()
		client.call(:log_in, message: { userName: 'shopify', password: 'shopify' })
	end
	def self.logout()
		client.call(:log_out)
	end
	def self.styles()
		client.call(:style_feed)
	end
	def self.products()
		client.call(:product_feed)
	end
	def self.style_products(style)
		client.call(:product_feed_for_style, message: { styleCode: style[:code] })
	end
	def self.order(order)
		login = client.call(:log_in, message: { userName: 'shopify', password: 'shopify' })
		user = login.http.cookies
		client.call(:create_order, message: { order: order }, cookies: user)
	end
	def self.order_status(orderNo)
		login = client.call(:log_in, message: { userName: 'shopify', password: 'shopify' })
		user = login.http.cookies
		client.call(:order_status_feed, message: { orderNo: 'R'+orderNo.to_s }, cookies: user)
	end
end