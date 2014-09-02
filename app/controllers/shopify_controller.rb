class ShopifyController < ApplicationController

	skip_before_filter :verify_authenticity_token

	def index
# 		@orders = ShopifyAPI::Order.find(:all)
# 		@styles = Niche.styles.to_hash[:style_feed_response][:style_feed_result][:style]
# 		@products = Niche.products.to_hash[:product_feed_response][:product_feed_result][:product]
	end

	def import
		@styles = Niche.styles.to_hash[:style_feed_response][:style_feed_result][:style]
		@styles.each do |style|
			# IMAGES
			images = []
			image = {}
			image['src'] = style[:web_main_picture][:zoom_box_url]
			images << image
			# OPTIONS
			options = []
			option = {}
			option['name'] = "Color"
			options << option
			option = {}
			option['name'] = "Size"
			options << option
			# VARIANTS
			variants = []
			variant = {}
			@products = Niche.style_products(style).to_hash[:product_feed_for_style_response][:product_feed_for_style_result][:product]
			@products.each do |product|
				variant = ShopifyAPI::Variant.new(
					:barcode => product[:barcode],
					:grams => product[:weight],
					:fulfillment_service => "manual",
					:inventory_management => "shopify",
					:inventory_quantity => product[:available_stock],
					:option1 => product[:color],
					:option2 => product[:size],
					:price => style[:web_price][:local_unit_price_ex_tax1].to_f.round(2),
					:requires_shipping => true,
					:sku => product[:barcode],
					:taxable => true,
					:title => product[:color] + " - " + product[:size]
				)
				variants << variant
			end
			# PRODUCT
			product = ShopifyAPI::Product.new(
				:title => style[:description],
				:body_html => style[:web_description],
				:product_type => style[:category],
				:vendor => style[:label][:description],
				:images => images,
				:options => options,
				:variants => variants
			)
			product.save
		end
	end

	def order
		@order = ShopifyAPI::Order.find(params[:id])
		#NICHE
 		person = {
			:email => params[:email],
 			:firstName => params[:customer][:first_name],
			:lastName => params[:customer][:last_name],
			:address => params[:shipping_address][:address1],
			:suburb => params[:shipping_address][:city],
			:state => params[:shipping_address][:province_code],
			:postcode => params[:shipping_address][:zip],
			:countryCodeISO3166_A2 => params[:shipping_address][:country_code],
			:phone => params[:shipping_address][:phone],
			:mobile => params[:shipping_address][:phone],
			:optInMailingList => params[:buyer_accepts_marketing].to_s
 		}
 		products = []
 		params[:line_items].each do |line_item|
 			product = {
	 			:Barcode => line_item[:sku],
	 			:qty => line_item[:quantity]
 			}
 			products.push(Product: product)
 		end
		order = {
			:person => person,
			:products => products,
			:refNo => @order.id
		}
		id = Niche.order(order).to_hash[:create_order_response][:create_order_result]
		#SHOPIFY
		notes = []
		note = {
			:name => 'nicheapi',
			:value => id
		}
		notes.push(note)
		@order.note_attributes = notes
		@order.save
		render :status => 200
	end

	def orders
		@orders = ShopifyAPI::Order.find(:all)
		@orders.each do |order|
			
		end
	end

end