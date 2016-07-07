module ApplicationHelper
  def display_style(condition)
    if condition
      "style='display: block'"
    else
      "style='display: none'"
    end.html_safe
  end

  def add_class_for_path(link_path, klass, klass_prefix = nil)
    "#{klass_prefix} #{klass if current_page?(link_path)}"
  end

  def add_class_for_action(controller_name, action_name, klass, klass_prefix = nil)
    "#{klass_prefix} #{klass if controller.controller_name == controller_name.to_s && controller.action_name == action_name.to_s}"
  end

  def nav_link(link_text, link_path, attrs = {})
    cls = add_class_for_path(link_path, 'active', attrs[:class])
    content_tag(:li, attrs.merge(class: cls)) { link_to link_text, link_path }
  end

  def page_title
    if content_for?(:page_title)
      page_title = content_for(:page_title)
    else
      controller = controller_path.gsub('/', '.')
      page_title = t("#{controller}.#{action_name}.page_title", default: t('default_title'))
    end
    page_title
  end

  def page_description
    if content_for?(:description)
      page_description = content_for(:description)
    else
      controller = controller_path.gsub('/', '.')
      page_description = t("#{controller}.#{action_name}.page_description", default: t('default_description'))
    end
    page_description
  end

  def page_og_image
    if content_for?(:og_image)
      page_og_image = content_for(:og_image)
    else
      controller = controller_path.gsub('/', '.')
      page_og_image = t("#{controller}.#{action_name}.og_image", default: t('default_og_image'))
    end
    page_og_image
  end

  def set_page_title(title)
    content_for :page_title do
      title
    end
  end

  def set_page_description(dsc)
    content_for :description do
      dsc
    end
  end

  def set_canonical_url(value)
    content_for(:canonical_url, value)
  end

  def set_og_tags(title, description)
    set_page_description(description)
    content_for(:og_title, title)
    content_for(:og_description, description)
  end

  def base64_encoded_asset(path)
    asset, content_type = if Rails.env.development?
      asset = Rails.application.assets.find_asset(path)
      content_type = asset.content_type
      [asset, content_type]
    else
      filesystem_path = Rails.application.assets_manifest.assets[path]
      asset = File.read(Rails.root.join('public', 'assets', filesystem_path))
      content_type = Mime::Type.lookup_by_extension(File.extname(path).split('.').last)
      [asset, content_type]
    end
    raise "Could not find asset '#{path}'" if asset.nil?
    puts Rails.application.assets
    base64 = Base64.encode64(asset.to_s).gsub(/\s+/, '')
    "data:#{content_type};base64,#{Rack::Utils.escape(base64)}"
  end

end
