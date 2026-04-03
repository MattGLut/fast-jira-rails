module NavigationHelper
  def nav_link(label, path, icon: nil, active_paths: [], **options)
    active = current_page?(path) || active_paths.any? { |candidate| request.path.start_with?(candidate) }
    classes = [
      "group flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-medium transition",
      active ? "bg-gray-800 text-white shadow-lg shadow-black/20" : "text-gray-300 hover:bg-gray-800/70 hover:text-white"
    ]

    link_to path, options.merge(class: classes.join(" ")) do
      concat(content_tag(:span, icon, class: "text-base leading-none")) if icon.present?
      concat(content_tag(:span, label))
    end
  end
end
