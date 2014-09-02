class Niche
	extend Savon::Model
	client wsdl: 'http://dev8.nicheweb.com.au/feed.asmx?wsdl',
	log: true,
	log_level: :debug,
	convert_request_keys_to: :none,
	pretty_print_xml: true
	def self.login()
		client.call(:log_in, message: { userName: 'staff', password: 'staff' })
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
		login = client.call(:log_in, message: { userName: 'staff', password: 'staff' })
		user = login.http.cookies
		client.call(:create_order, message: { order: order }, cookies: user)
	end
end