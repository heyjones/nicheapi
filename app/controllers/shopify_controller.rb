class ShopifyController < ApplicationController

	skip_before_filter :verify_authenticity_token

	def index
 		@orders = ShopifyAPI::Order.find(:all)
 		@styles = Niche.styles.to_hash[:style_feed_response][:style_feed_result][:style]
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
		products = []
 		params[:line_items].each do |line_item|
 			products.push([line_item.sku, line_item.quantity])
 		end
 		person = []
		person['firstName'] = params[:customer][:first_name]
		person['lastName'] = params[:customer][:last_name]
		person['address'] = params[:shipping_address][:address1]
		person['postcode'] = params[:shipping_address][:zip]
		person['suburb'] = params[:shipping_address][:city]
		person['state'] = params[:shipping_address][:province_code]
		person['email'] = params[:email]
		person['phone'] = params[:shipping_address][:phone]
		person['optInMailingList'] = params[:buyer_accepts_marketing]
		person['countryCodeISO3166_A2'] = params[:shipping_address][:country_code]
logger.info person
	end

	def orders
		@orders = ShopifyAPI::Order.find(:all)
		@orders.each do |order|
			
		end
	end

end