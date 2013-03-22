require "rails_bootstrap_navbar/version"

module RailsBootstrapNavbar
	module ViewHelpers

	  def nav_bar(options={}, &block)
			nav_bar_div(options) do
				navbar_inner_div do
					container_div(options[:brand], options[:brand_link], options[:responsive], options[:fluid]) do
						yield if block_given?
					end
				end
			end
	  end

	  def menu_group(options={}, &block)
			pull_class = " pull-#{options[:pull].to_s}" if options[:pull].present?
			menu_group_class = "nav#{pull_class}"
			menu_group_class = "nav-collapse collapse" if options[:type] == "accordion"
			content_tag(:ul, :class => menu_group_class , &block)
	  end

	  def menu_item(name, path="#", options = {})
		content_tag :li, :id => options[:id], :class => is_active?(path) do
			options[:id] = options[:id] + "_link" if options[:id]
			if options[:icon]
				link_to path, options do
					span1 = content_tag :span, class: "icon" do
						content_tag :i, "", class: options[:icon]
					end
					span2 = content_tag :span, class: "text" do
						name
					end
					"#{span1}#{span2}".html_safe
				end
			else
				link_to name, path, options
			end
		end
	  end

	  def drop_down(name, options = {})
	  	li_class = "dropdown"
	  	li_class = "" if options[:menu_type] == "accordion"
	  	content_tag :li, :class => li_class do
	  		drop_down_link(name, options) + drop_down_list(name, options[:menu_type]) {yield}
	  	end
	  end

	  def drop_down_divider
			content_tag :li, "", :class => "divider"
	  end

	  def drop_down_header(text)
			content_tag :li, text, :class => "nav-header"
	  end

	  def menu_divider
			content_tag :li, "", :class => "divider-vertical"
	  end

	  def menu_text(text=nil, options={}, &block)
			pull = options.delete(:pull)
			pull_class = pull.present? ? "pull-#{pull.to_s}" : nil
			options.append_merge!(:class, pull_class)
			options.append_merge!(:class, "navbar-text")
			content_tag :p, options do
				text || yield
			end
	  end

	  private

	  def nav_bar_div(options, &block)

	  	    position = "static-#{options[:static].to_s}" if options[:static]
	  	    position = "fixed-#{options[:fixed].to_s}"   if options[:fixed]

	  	    css_class_options = {position: position, type: options[:type]};

			content_tag :div, id: options[:id], :class => nav_bar_css_class(css_class_options) do
				yield
			end
	  end

	  def navbar_inner_div(&block)
			content_tag :div, :class => "navbar-inner" do
				yield
			end
	  end

	  def container_div(brand, brand_link, responsive, fluid, &block)
			content_tag :div, :class => "container#{"-fluid" if fluid}" do
				container_div_with_block(brand, brand_link, responsive, &block)
			end
	  end

	  def container_div_with_block(brand, brand_link, responsive, &block)
			output = []
			if responsive == true
				output << responsive_button
				output << brand_link(brand, brand_link)
				output << responsive_div {capture(&block)}
			else
				output << brand_link(brand, brand_link)
				output << capture(&block)
			end
			output.join("\n").html_safe
	  end

	  def nav_bar_css_class(options = {})
			css_class = ["navbar"]
			css_class << "navbar-" + options[:position] if options[:position].present?
			css_class.join(" ")
	  end

	  def brand_link(name, url)
			return "" if name.blank?
			url ||= root_url
			link_to(name, url, :class => "brand")
	  end

	  def responsive_button
			%{<a class="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse">
	        <span class="icon-bar"></span>
	        <span class="icon-bar"></span>
	        <span class="icon-bar"></span>
	      </a>}
	  end

	  def responsive_div(&block)
			content_tag(:div, :class => "nav-collapse", &block)
	  end

	  def is_active?(path)
			"active" if current_page?(path)
	  end

	  def name_and_caret(name, options = {})
	  		if options[:icon]
				span1 = content_tag :span, class: "icon" do
					content_tag :i, "", class: options[:icon]
				end
				span2 = content_tag :span, class: "text" do
					name
				end
				"#{span1}#{span2} #{content_tag(:b, :class => "caret"){}}".html_safe
	  		else
				"#{name} #{content_tag(:b, :class => "caret"){}}".html_safe
			end
	  end

	  def drop_down_link(name, options = {})
	  		link = options[:url]||"#"
	  		link_class = "dropdown-toggle"
	  		data_toggle = "dropdown"

	  		if options[:menu_type] == "accordion"
	  			stripped_name = name.gsub(/[^0-9a-z]/i, '')
	  			link = "#" + stripped_name
	  			link_class = "accordion-toggle collapsed"
		  		data_toggle = "collapse" if options[:menu_type] == "accordion"
		  	end

			link_to(name_and_caret(name, options), link, :class => link_class, "data-hover" => data_toggle)
	  end

	  def drop_down_list(name, menu_type, &block)
	  		tag_class = "dropdown-menu"
	  		tag_class = "secondary collapse" if menu_type == "accordion"

  			stripped_name = name.gsub(/[^0-9a-z]/i, '')

			content_tag :ul, :id => stripped_name, :class => tag_class, &block
	  end
	end
end

class Hash
	# appends a string to a hash key's value after a space character (Good for merging CSS classes in options hashes)
	def append_merge!(key, value)
		# just return self if value is blank
		return self if value.blank?

		current_value = self[key]
		# just merge if it doesn't already have that key
		self[key] = value and return if current_value.blank?
		# raise error if we're trying to merge into something that isn't a string
		raise ArgumentError, "Can only merge strings" unless current_value.is_a?(String)
		self[key] = [current_value, value].compact.join(" ")
	end
end