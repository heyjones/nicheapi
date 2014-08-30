class Niche
	extend Savon::Model
	client wsdl: 'http://dev8.nicheweb.com.au/feed.asmx?wsdl'
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
		#client.call(:create_order, message: { order: order }, cookies: user)
		client.call(:create_order, message: { order: {:products=>[{:barcode=>"1234500002120", :qty=>1}], :person=>{:firstName=>"Chris", :lastName=>"Jones", :address=>"17 Bull Run", :postcode=>"92620", :suburb=>"Irvine", :state=>"CA", :email=>"chris@heyjones.com", :phone=>"9494131049", :mobile=>"9494131049", :optInMailingList=>false, :countryCodeISO3166_A2=>"US"}, :refNo=>"TEST"} }, cookies: user)
	end
end